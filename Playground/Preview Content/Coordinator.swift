//
//  Coordinator.swift
//  Playground
//
//  Created by Juan Villa on 12/2/23.
//

import Foundation
import ARKit
import RealityKit
import Combine

class Coordinator: NSObject, ARSessionDelegate, UIGestureRecognizerDelegate {
    
    // This is a comment to test a commit and push
    // This is a second test
    
    weak var view: ARView?
    
    let anchor = AnchorEntity(plane: .horizontal)
    let box1 = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [SimpleMaterial(color: .gray, isMetallic: true)])
    
    var movableEntities = [ModelEntity]()
    
    func buildEnvironment() {
        
        guard let view = view else { return }
        
//        let floor = ModelEntity(mesh: MeshResource.generatePlane(width: 1, depth: 1, cornerRadius: 0.5), materials: [SimpleMaterial(color: .white, isMetallic: true)])
//        floor.generateCollisionShapes(recursive: true)
//        floor.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        box1.generateCollisionShapes(recursive: true)
        //box1.physicsBody = PhysicsBodyComponent(mode: .dynamic)
        
        movableEntities.append(box1)
        
        //anchor.addChild(floor)
        anchor.addChild(box1)
        
        view.scene.addAnchor(anchor)
        
        movableEntities.forEach {
            view.installGestures(.all, for: $0).forEach {
                $0.delegate = self
            }
        }
        
        view.installGestures(.all, for: box1)
        setupGestures()
        
        
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let view = view else {return}
        
        let tapLocation = recognizer.location(in: view)
        
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            
            let newAnchor = AnchorEntity(raycastResult: result)
            
            let newBox = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [SimpleMaterial(color: .gray, isMetallic: true)])
            newBox.generateCollisionShapes(recursive: true)
//            newBox.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .default)
//            newBox.collision = CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])], mode: .trigger, filter: .sensor)
//            newBox.position.y = 0.3
            
            movableEntities.append(newBox)
            if let movableEntity = movableEntities.last {
                view.installGestures(.all, for: movableEntity).forEach {
                    $0.delegate = self
                }
            } else {
                return
            }
            
            newAnchor.addChild(newBox)
            view.installGestures(.all, for: newBox)
            
            view.scene.addAnchor(newAnchor)
        }
        
    }
    
    
    fileprivate func setupGestures() {
        
        guard let view = view else {return}
        let panGestures = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panGestures.delegate = self
        view.addGestureRecognizer(panGestures)
    }
    
    
    @objc func panned(_ sender: UITapGestureRecognizer) {
        
        switch sender.state {
        case .ended, .cancelled, .failed:
            // change physics mode to be dynamic
            movableEntities.compactMap {$0}.forEach {
                $0.physicsBody?.mode = .dynamic
            }
        default:
            return
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let translationGesture = gestureRecognizer as? EntityTranslationGestureRecognizer,
              let entity = translationGesture.entity as? ModelEntity else {
            return true
        }
        
        entity.physicsBody?.mode = .kinematic
        return true
        
    }
}

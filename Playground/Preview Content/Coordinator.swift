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
    
    weak var view: ARView?
    
    let anchor = AnchorEntity(plane: .horizontal)
    let box1 = MovableEntity(size: 0.3, color: .gray, shape: .sphere)
    
    var movableEntities = [MovableEntity]()
    
    func buildEnvironment() {
        
        guard let view = view else { return }
        
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
            
            let newEntity = MovableEntity(size: 0.3, color: .cyan, shape: .sphere)
            
            movableEntities.append(newEntity)
            if let movableEntity = movableEntities.last {
                view.installGestures(.all, for: movableEntity).forEach {
                    $0.delegate = self
                }
            } else {
                return
            }
            
            newAnchor.addChild(newEntity)
            view.installGestures(.all, for: newEntity)
            
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
              let entity = translationGesture.entity as? MovableEntity else {
            return true
        }
        
        entity.physicsBody?.mode = .kinematic
        return true
        
    }
}

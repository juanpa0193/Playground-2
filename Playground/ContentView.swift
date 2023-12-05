//
//  ContentView.swift
//  Playground
//
//  Created by Juan Villa on 12/2/23.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // setup tap gesture recognizer
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        // make sure to initialize the coordinator first in function further down in order to assign the view and run the build env on the coordinator
        context.coordinator.view = arView
        context.coordinator.buildEnvironment()
        
        return arView
        
    }
    
    //initialize the coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}

//
//  FieldSceneCoordinator.swift
//  ThesisApp
//
//  Created by Lisa Wittmann on 17.09.22.
//

import SwiftUI
import SceneKit

class FieldSceneCoordinator: NSObject {
    
    @Binding var selectedPosition: Position?
    private let sceneView: SCNView
    
    init(
        _ sceneView: SCNView,
        selectedPosition: Binding<Position?>
    ) {
        self.sceneView = sceneView
        self._selectedPosition = selectedPosition
        super.init()
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
    
        if hitResults.count > 0 {
            let result = hitResults[0]
            selectedPosition = Converter.position(vector: result.node.position)
            
            let material = result.node.geometry!.materials[(result.geometryIndex)]
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.black
                SCNTransaction.commit()
            }
            material.emission.contents = UIColor(Color.customLightBrown)
            SCNTransaction.commit()
        }
    }
}

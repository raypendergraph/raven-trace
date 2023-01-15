//
//  WaypointAnchor.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/22/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import Foundation
import ARKit
import CoreLocation

class TargetARAnchor: ARAnchor {
    let target: Target
    
    init(target: Target, transform: matrix_float4x4) {
        self.target = target
        super.init(transform: transform)
    }
    
    required convenience init(anchor: ARAnchor) {
        guard let anchor = anchor as? TargetARAnchor else { fatalError("Programmer error.") }
        self.init(target: anchor.target, transform: anchor.transform)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//extension PlacemarkARAnchor {
//    func asPlacemarkSpriteNode(with texture: SKTexture) -> SKNode {
//        let node = SKSpriteNode()
////        node.size.width = 35.0
////        node.size.height = 35.0
////        node.userData = ["placemark": anchor.placemark]
//        node.isHidden = true
//        scene.addChild(node)
//        trackedNodes[anchor.identifier] = node
//
//        return node
//    }
//}


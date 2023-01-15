//
//  Waypoint.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/22/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

class TargetSCNNode: SCNNode {
    let target: Target
    
    init(with target: Target) {
        self.target = target
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



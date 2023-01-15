//
//  ARSession.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/22/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import Foundation
import CoreLocation
import ARKit

extension ARSession {
    func anchorExists(with target: Target) -> Bool {
        guard let anchors = currentFrame?.anchors else { return false }
        return anchors.contains(where: { (a) -> Bool in
            guard let pma = a as? TargetARAnchor else { return false }
            return pma.target == target
        })
    }
}

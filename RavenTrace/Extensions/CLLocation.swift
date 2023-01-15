//
//  CLLocation.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/20/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import CoreLocation

extension CLLocation {
    func forwardAzimuth(to other: CLLocation) -> Radians {
        return self.coordinate.unitAngle(to: other.coordinate)
    }
    
    func unitAngle(to other: CLLocation) -> Radians {
        return self.coordinate.unitAngle(to: other.coordinate)
    }
}

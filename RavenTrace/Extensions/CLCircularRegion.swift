//
//  MKMapRegion.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/20/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

extension CLCircularRegion {
    public func asCoordinateRegion() -> MKCoordinateRegion {
        return MKCoordinateRegion(center: center, latitudinalMeters: radius, longitudinalMeters: radius)
    }
}

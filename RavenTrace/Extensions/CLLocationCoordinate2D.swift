//
//  CLLocationCoordinate2D.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/20/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import Foundation
import CoreLocation
import simd

/*
 An extension to help deal with uncommon geodetic calculations taken from textbooks and the following sources:
 https://www.igismap.com/formula-to-find-bearing-or-heading-angle-between-two-points-latitude-longitude/
 */
extension CLLocationCoordinate2D {
    /*
     A helper extension to find the 'bearing angle' between two coordinates,
     */
    func unitAngle(to other:CLLocationCoordinate2D) -> Radians {
        
        let φ1 = self.latitude.radians
        let φ2 = other.latitude.radians
        let λ1 = self.longitude.radians
        let λ2 = other.longitude.radians
        let y = sin(λ2 - λ1) * cos(φ2);
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(λ2 - λ1);
        
        return Radians(atan2(y, x))
    }
    

    
    func unitForwardAzimuth(to other: CLLocationCoordinate2D) -> Radians {
        let fivePiOverTwo = Float.pi * 5 / 2
        let twoPi = Float.pi * 2
        return (fivePiOverTwo - unitAngle(to: other)).truncatingRemainder(dividingBy: twoPi)
    }
}

extension simd_float4x4 {
    func rotatedAroundY(_ degrees: Degrees) -> simd_float4x4 {
        var matrix = self
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
}

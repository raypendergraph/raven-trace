//
//  Double.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/20/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//
typealias Radians = Float
typealias Degrees = Float

// TODO This doesn't go far enough... create Radian and Degree types instead of FP.
extension FloatingPoint {
    var degrees:  Self {
        get {
            return self * 180 / Self.pi
        }
    }

    var radians: Self {
        get {
            return self * Self.pi / Self(180)
        }
    }

    var bearing: Self {
        get {
            var value = self.degrees + 360
            value.formTruncatingRemainder(dividingBy: Self(360))
            return value
        }
    }
}

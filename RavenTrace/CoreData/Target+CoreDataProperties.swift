//
//  Target+CoreDataProperties.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 1/3/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//
//

import Foundation
import CoreLocation
import CoreData


extension Target {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Target> {
        return NSFetchRequest<Target>(entityName: "Target")
    }

    @NSManaged public var altitude: Double
    @NSManaged public var date: Date
    @NSManaged public var horizontalAccuracy: Double
    @NSManaged public var hudSymbol: Int16
    @NSManaged public var hudText: String?
    @NSManaged public var isTracking: Bool
    @NSManaged public var lastTracked: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var text: String?
    @NSManaged public var timesTracked: Int32
    @NSManaged public var verticalAccuracy: Double
}

extension Target {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude,
                                      longitude: longitude)
    }
    
    var location: CLLocation {
       return CLLocation(coordinate: coordinate,
                         altitude: altitude,
                         horizontalAccuracy: horizontalAccuracy,
                         verticalAccuracy: verticalAccuracy,
                         course: 0.0,
                         speed: 0.0,
                         timestamp: Date.init())
    }
}

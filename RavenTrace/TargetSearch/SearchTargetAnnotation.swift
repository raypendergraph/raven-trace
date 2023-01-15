/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Custom pin annotation for display found places.
*/

import MapKit
import CoreData

class SearchTargetAnnotation: NSObject, MKAnnotation {
    @objc var coordinate: CLLocationCoordinate2D {
        return self.item.placemark.coordinate
    }
    
    var title : String? {
        return self.item.placemark.name
    }
    
    var url:URL? {
        return self.item.url
    }
    
    var subtitle: String? {
        return self.item.placemark.formattedAddress
    }

    let item: MKMapItem
    
    init(representing mapItem: MKMapItem) {
        self.item = mapItem
        super.init()
    }
}

extension SearchTargetAnnotation {
    func asTarget(in context: NSManagedObjectContext) -> Target? {
        let target = Target(context: context)
        guard let location = self.item.placemark.location else { return nil }
        target.altitude = location.altitude
        target.latitude = location.coordinate.latitude
        target.longitude = location.coordinate.longitude
        target.name = self.item.name
        return target
    }
}

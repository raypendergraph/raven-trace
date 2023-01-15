/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Secondary view controller used to display the map and found annotations.
*/

import UIKit
import MapKit
import CoreData

class SearchMapVC: UIViewController {
    
    private enum AnnotationReuseID: String {
        case pin
    }
    
    @IBOutlet private var mapView: MKMapView!
    
    var mapItems: [MKMapItem]?
    var boundingRegion: MKCoordinateRegion?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let region = boundingRegion {
            mapView.region = region
        }
        mapView.delegate = self
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .visible
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: compass)
        mapView.showsCompass = false // Use the compass in the navigation bar instead.
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: AnnotationReuseID.pin.rawValue)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard let mapItems = mapItems else { return }
        
        if mapItems.count == 1, let item = mapItems.first {
            title = item.name
        } else {
            title = NSLocalizedString("TITLE_ALL_PLACES", comment: "All Places view controller title")
        }

        let annotations = mapItems.compactMap { (mapItem) -> SearchTargetAnnotation? in
            guard mapItem.placemark.location != nil else { return nil }
            return SearchTargetAnnotation(representing: mapItem)
        }
        mapView.addAnnotations(annotations)
    }
}

extension SearchMapVC: MKMapViewDelegate {
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Failed to load the map: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? SearchTargetAnnotation else { return nil }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationReuseID.pin.rawValue, for: annotation) as? MKMarkerAnnotationView
        view?.canShowCallout = true
        view?.clusteringIdentifier = "searchResult"
        if annotation.url != nil {
            let infoButton = UIButton(type: .contactAdd)
            view?.rightCalloutAccessoryView = infoButton
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let annotation = view.annotation as? SearchTargetAnnotation else { return }
        let actionController = makeTargetActionAlertController(for: annotation)
        self.present(actionController, animated: true) {
            print("hello")
        }
    }
    
    private func makeTargetActionAlertController(for annotation: SearchTargetAnnotation) -> UIAlertController {
        let title = annotation.title
        
        let message = "What do you want to do with this target?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        if let url = annotation.url {
            let moreInfo = UIAlertAction(title: "Need more info.", style: .default) { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            alertController.addAction(moreInfo)
        }

        
        let track = UIAlertAction(title: "Track it.", style: .default) {_ in

            let managedContext = AppDelegate.current.persistentContainer.viewContext
            _ = annotation.asTarget(in: managedContext)
            AppDelegate.current.saveContext()
        }
        alertController.addAction(track)

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)

        return alertController
    }
}

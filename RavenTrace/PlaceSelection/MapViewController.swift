//
//  MapViewController.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/27/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    let placeListVC = PlaceListViewController()
    let disposeBag = DisposeBag()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        addChild(placeListVC)
        view.addSubview(placeListVC.view)
        placeListVC.didMove(toParent: self)

        let height = view.frame.height
        let width  = view.frame.width
        placeListVC.view.frame = CGRect(x: 0, y: view.frame.maxY, width: width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer.init(target: placeListVC, action: #selector(DrawerSheetViewController.panGesture))
        gesture.delegate = placeListVC
        view.addGestureRecognizer(gesture)
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        AppDelegate.current.locationManager.rx.didUpdateLocations
            .subscribe( onNext: { [weak self] locations in
                guard let location = locations.last else { return }
                self?.mapView.setRegion(MKCoordinateRegion(center: location.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000),
                    animated: true)
            }).disposed(by: disposeBag)
    }
}

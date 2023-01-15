//
//  CLGeocoder+Rx.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/21/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import UIKit
import RxSwift
import CoreLocation

extension Reactive where Base: CLGeocoder {
        func reverseGeocode(location: CLLocation) -> Observable<[CLPlacemark]> {
            return Observable<[CLPlacemark]>.create { observer in
                    geocodeHandler(observer: observer, geocode: { (handler: @escaping ([CLPlacemark]?, Error?) -> Void) in
                        self.base.reverseGeocodeLocation(location, completionHandler: handler)
                    })
                return Disposables.create()
            }
        }
        

        
        func geocodeAddressString(addressString: String) -> Observable<[CLPlacemark]> {
            return Observable<[CLPlacemark]>.create { observer in
                geocodeHandler(observer: observer, geocode: { (handler: @escaping ([CLPlacemark]?, Error?) -> Void) in
                    self.base.geocodeAddressString(addressString, completionHandler: handler)
                })
                return Disposables.create()
            }
        }
        
        func geocodeAddressString(addressString: String, inRegion region: CLRegion?) -> Observable<[CLPlacemark]> {
            return Observable<[CLPlacemark]>.create { observer in
                geocodeHandler(observer: observer, geocode: { (handler: @escaping ([CLPlacemark]?, Error?) -> Void) in
                    self.base.geocodeAddressString(addressString, in: region, completionHandler: handler)
                })
                return Disposables.create()
            }
        }
    }
    
private func geocodeHandler(observer: AnyObserver<[CLPlacemark]>, geocode: @escaping ( @escaping CLGeocodeCompletionHandler) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        waitForCompletionQueue.async() {
            geocode { placemarks, error in
                semaphore.signal()
                if let placemarks = placemarks {
                    observer.onNext(placemarks)
                    observer.onCompleted()
                }
                else if let error = error {
                    observer.onError(error)
                }
                else {
                    observer.onError(RxError.unknown)
                }
            }
            let timeoutTime = DispatchTime(uptimeNanoseconds: UInt64(30 * Double(NSEC_PER_SEC)))
            _ = semaphore.wait(timeout: timeoutTime)
        }
    }
    
private let waitForCompletionQueue = DispatchQueue(__label: "WaitForGeocodeCompletionQueue", attr: nil)
    


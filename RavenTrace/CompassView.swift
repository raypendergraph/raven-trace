//
//  CompassView.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/21/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

let acceptableAccuracies$ = 0.0..<15.0

class CompassView : UIView {
    
    let disposeBag = DisposeBag()
    let fov$ = BehaviorSubject<CGFloat>(value: 45.0);
    let filteredHeading$ = AppDelegate.current.locationManager.rx.didUpdateHeading
        .filter {
            return acceptableAccuracies$.contains($0.headingAccuracy)
            
        }
        .map { CGFloat($0.magneticHeading) }
        
    let dialPath = createDialPath()
    let shapeLayer = CAShapeLayer()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func adjustShapeLayer(for fov: CGFloat, with heading: CGFloat) {
        let at = calculateAffineTransform(frame: self.frame,
                                          fov: fov,
                                          rotation: heading.radians)
        shapeLayer.setAffineTransform(at)
    }
    
    func setup() {
        layer.backgroundColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 0.01
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.path = dialPath.cgPath
        layer.addSublayer(shapeLayer)
        
        Observable.combineLatest(filteredHeading$, fov$)
            .map { ($0, $1) }
            .subscribe(onNext: { [weak self] heading, fov in
                //print("Dial latest \(heading) \(fov)")
                self?.adjustShapeLayer(for: fov, with: heading)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fov$.on(.next(45.0))
    }
}

func calculateAffineTransform(frame: CGRect, fov: CGFloat, rotation: CGFloat) -> CGAffineTransform {
    let a = sin(fov)
    let h = 1 - cos(fov)
    let sx = frame.width / (2 * a)
    let sy = frame.height / h
    return CGAffineTransform
        .identity
        .translatedBy(x: frame.midX,
                      y: frame.height + sy * (1 - h))
        .scaledBy(x: sx , y: sy)
        .rotated(by: rotation)
}

func createDialPath() -> UIBezierPath {
    let path = UIBezierPath()
    path.lineWidth = 0.005
    
    defer {
        path.close()
    }
    
    let numberOfPoints = 360
    let theta = 2.0 * .pi / CGFloat(numberOfPoints)
    let outerRadius = CGFloat(1.0)
    let innerRadius = CGFloat(outerRadius * 0.98)
    let majoRadiusDelta = outerRadius * 0.075
    let minorRadiusDelta = outerRadius * 0.025
    for i in 0..<numberOfPoints {
        let radians = CGFloat(i) * theta
        var radiusDelta = CGFloat(0.0)
        if i % 90 == 0 {
            
            radiusDelta = majoRadiusDelta + 10
        } else if i % 10 == 0 {
            radiusDelta = majoRadiusDelta
        } else if i % 5 == 0 {
            radiusDelta = minorRadiusDelta
        }
        
        let outerPoint = CGPoint(x: cos(radians) * outerRadius,
                                 y: sin(radians) * outerRadius)
        
        let innerPoint = CGPoint(x: cos(radians) * (innerRadius - radiusDelta),
                                 y: sin(radians) * (innerRadius - radiusDelta))
        path.move(to: outerPoint)
        path.addLine(to: innerPoint)
    }
    
    return path
}

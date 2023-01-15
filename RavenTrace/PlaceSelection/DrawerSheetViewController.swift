//
//  ListSheetViewController.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/29/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//

import UIKit

class DrawerSheetViewController : UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let blurEffect = UIBlurEffect.init(style: .extraLight)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height - 200
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
    
    @objc public func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let y = view.frame.minY
        view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
}

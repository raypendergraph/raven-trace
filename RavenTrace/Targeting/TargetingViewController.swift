//
//  ViewController.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 1/1/2023.
//  Copyright © 2023 Raymond Pendergraph. All rights reserved.
//
import ARKit
import CoreData
import CoreLocation
import RxCocoa
import RxSwift
import SceneKit
import UIKit

class TargetingViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var compassView: CompassView!

    dynamic let targets$ = BehaviorRelay<[Target]>(value: [])
    let targetingOverlay = TargetingScene(size: CGSize.zero)
    let disposeBag = DisposeBag()
    let preciseLocaton$ = AppDelegate.current.locationManager.rx.didUpdateLocations
        .filter({
            guard let location = $0.last else { return false}
            // TODO ugh, this need fixing. Move it to to the delegate
            return location.horizontalAccuracy <= 20.0 && location.verticalAccuracy <= 20.0
        })
        .map { $0.last! }
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Target> = {
        let fetchRequest: NSFetchRequest<Target> = Target.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let managedObjectContext = AppDelegate.current.persistentContainer.viewContext
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        return fetchedResultsController
    }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        view.center = self.view.center
        return view
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let camera = sceneView.pointOfView?.camera {
            camera.zFar = 10000
            camera.zNear = 1
            camera.usesOrthographicProjection = false
        }
        
        targetingOverlay.size = sceneView.intrinsicContentSize
        targetingOverlay.scaleMode = .resizeFill
        targetingOverlay.backgroundColor = .clear
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.overlaySKScene = targetingOverlay
        sceneView.showsStatistics = true
        
        AppDelegate.current.locationManager.startUpdatingLocation()
        AppDelegate.current.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        targetingOverlay.view?.addSubview(activityView)
        activityView.startAnimating()
        
        preciseLocaton$.debug()
            .withLatestFrom(targets$.debug()){ ($0, $1) }
            .first()
            .subscribe(onSuccess: { values in
                guard let (here, targets) = values else { return }
                self.activityView.stopAnimating()
                self.activityView.removeFromSuperview()
                    
                for target in targets {
                    let arAnchor = TargetARAnchor(target: target,
                                                      transform: transform(at: here, lookingAt: target))

                    print("Adding target \(target.name) \(arAnchor.identifier)")
                    self.sceneView.session.add(anchor: arAnchor)
                    self.targetingOverlay.add(anchor: arAnchor)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        let options = ARSession.RunOptions(arrayLiteral: [.removeExistingAnchors])
        sceneView.session.run(configuration, options: options)
        
        do {
            try fetchedResultsController.performFetch()
            let fetched = fetchedResultsController.fetchedObjects
            if let fetched = fetched, fetched.count > 0 {
                targets$.accept(fetched)
            }
        } catch {
            print(error)
        }
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    private lazy var sphere: SCNSphere = {
        let sphere = SCNSphere(radius: 20.0)
        sphere.materials = [self.surfaceMaterial]
        return sphere
    }()
    
    private lazy var surfaceMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.specular.contents = UIColor(white: 0.6, alpha: 1.0)
        material.shininess = 0.5
        return material
    }()
    
    func rotateNode(_ angleInRadians: Float, _ transform: SCNMatrix4) -> SCNMatrix4 {
        let rotation = SCNMatrix4MakeRotation(angleInRadians, 0, 1, 0)
        return SCNMatrix4Mult(transform, rotation)
    }
}

// MARK: - ARSessionDelegate
extension TargetingViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
//        print("Mine", cameraNode.transform)
//        print("Frame", frame.camera.transform)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("Did add \(anchors)")
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        print("Did remove \(anchors)")
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        //print("Did update \(anchors)")
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Error: \(error)")
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("Session Interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("Session Interruption stopped.")
    }
}

// MARK: - ARSessionObserver
extension TargetingViewController : ARSessionObserver {
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
      //  print("Camera state --> ", camera)
        
    }
}

// MARK: - ARSCNViewDelegate
extension TargetingViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let targetAnchor = anchor as? TargetARAnchor else { return nil }
        let targetNode = TargetSCNNode(with: targetAnchor.target)
        
        let s = SCNNode(geometry: sphere)
        targetNode.addChildNode(s)
        return targetNode
    }
    
    public func renderer(_ renderer: SCNSceneRenderer,
                         updateAtTime time: TimeInterval) {
        guard let pointOfView = renderer.pointOfView else { return }
        let visiblePlaces = sceneView.scene.rootNode.childNodes { (node, stop) -> Bool in
            guard let targetNode = node as? TargetSCNNode else { return false }
            return renderer.isNode(targetNode, insideFrustumOf:pointOfView)
            
        }
            
        targetingOverlay.updateTargets(from: renderer, with: visiblePlaces)

//        let screenWidth = UIScreen.main.bounds.width
//        let screenHeight = UIScreen.main.bounds.height
//        let leftPoint = CGPoint(x: 0, y: screenHeight/2)
//        let rightPoint = CGPoint(x: screenWidth,y: screenHeight/2)
//        let leftWorldPos = renderer.unprojectPoint(SCNVector3(leftPoint.x, leftPoint.y,0))
//        let rightWorldPos =  renderer.unprojectPoint(SCNVector3(rightPoint.x, rightPoint.y,0))

        
//        for node in visibleWaypoints {
//            guard let waypoint = node as? WaypointNode else { continue }
//            let isVisible = renderer.isNode(waypoint,
//                                            insideFrustumOf: pointOfView)

            
//            let distanceLeft = waypoint.worldPosition.distance(to: leftWorldPos)
//            let distanceRight = waypoint.worldPosition.distance(to: rightWorldPos)

            //let pnt = renderer.projectPoint(node.worldPosition)
            //guard let pnt = renderer.pointOfView!.convertPosition(node.position, to: nil) else {return}
//            print(distanceLeft < distanceRight ? "<<<<<< \(isVisible)" : ">>>>>>\(isVisible)")
//            let dir = (isVisible) ? "visible" : ( (distanceLeft<distanceRight) ? "left" : "right")
            //print("dir" , dir, " ", leftWorldPos , " ", rightWorldPos)
//            lastDir=dir
//            delegate?.nodePosition?(node:node, pos: dir)
                //}
        
    }
}

func transform(at origin: CLLocation, lookingAt target: Target) -> matrix_float4x4 {
    //TODO
    //            let distance = Float(here.distance(from: targetLocation))
    //            let bearing = here.forwardAzimuth(to: targetLocation)
    //            let y = targetLocation.altitude - here.altitude
    let targetLocation = target.location
    let bearing = origin.unitAngle(to: targetLocation)
    let rotation = matrix_identity_float4x4.rotatedAroundY(bearing)
    let distance = origin.distance(from: targetLocation)
    let zero = Float(0)
    let position = vector_float4(zero, zero, Float(-distance), zero)
    var translation = matrix_identity_float4x4
    translation.columns.3 = position
    return simd_mul(rotation, translation)
}


// MARK:- Helper functions

func makeBillboardNode(_ image: UIImage) -> SCNNode {
    let plane = SCNPlane(width: 10, height: 10)
    plane.firstMaterial!.diffuse.contents = image
    let node = SCNNode(geometry: plane)
    node.constraints = [SCNBillboardConstraint()]
    return node
}

@discardableResult
func measure<A>(name: String = "", _ block: () -> A) -> A {
    let startTime = CACurrentMediaTime()
    let result = block()
    let timeElapsed = CACurrentMediaTime() - startTime
    print("Time: \(name) - \(timeElapsed)")
    return result
}

//
//  UIOverlay.swift
//  RavenTrace
//
//  Created by Raymond Pendergraph on 12/29/2022.
//  Copyright © 2022 Raymond Pendergraph. All rights reserved.
//
import CoreData
import SpriteKit
import RxSwift
import ARKit

func spriteNode(like texture: SKTexture, width: CGFloat, height: CGFloat) -> SKSpriteNode {
    let node = SKSpriteNode(texture: texture)
    node.size.width = width
    node.size.height = height
    return node
}

class TargetingScene: SKScene {
    
    let sprites = SKTextureAtlas(named: "overlay.atlas")
    var panLeftIndicator: SKSpriteNode?
    var panRightIndicator: SKSpriteNode?
    var targetIndicator: SKSpriteNode?
    var disposeBag = DisposeBag()
    var trackedNodes = [NSManagedObjectID:SKSpriteNode]()

    override init(size: CGSize) {
        super.init(size: size)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.scaleMode = .resizeFill
        backgroundColor = .clear
        let leftChevron = spriteNode(like: sprites.textureNamed("left-chevron"),
                                     width: 10.0,
                                     height: 10.0)
        let rightChevron = spriteNode(like: sprites.textureNamed("right-chevron"),
                                      width: 10.0,
                                      height: 10.0)
        targetIndicator = spriteNode(like: sprites.textureNamed("target"), width: 50, height: 50)
        
        leftChevron.size = CGSize(width: 30, height: 60)
        leftChevron.position = CGPoint(x: 100, y: 400)
        //addChild(leftChevron)
        panLeftIndicator = leftChevron
        
        rightChevron.size = CGSize(width: 30, height: 60)
        rightChevron.position = CGPoint(x: 200, y: 400)
        //addChild(rightChevron)
        panRightIndicator = rightChevron
        
        targetIndicator?.size = CGSize(width: 75, height: 75)
        targetIndicator?.position = CGPoint(x: 300, y: 300)
        //addChild(targetIndicator!)
    }
    
    func add(anchor: TargetARAnchor) {
        let sprite = self.sprites.textureNamed("target")
        let skNode = spriteNode(like: sprite, width: 50, height: 50)
        trackedNodes[anchor.target.objectID] = skNode
        addChild(skNode)
    }

    func remove(anchor: TargetARAnchor) {
        guard let value = trackedNodes.removeValue(forKey: anchor.target.objectID) else { return }
        removeChildren(in: [value])
    }
    
    func updateTargets(from renderer: SCNSceneRenderer,
                       with targetsInFrustum: [SCNNode]) {
//        for n in children {
//            n.isHidden = true
//        }
        
        for t in targetsInFrustum {
            guard let tn = t as? TargetSCNNode else { continue }
            let id = tn.target.objectID
            guard let skNode = trackedNodes[id] else { continue }
            //skNode.isHidden = false
            let projected = renderer.projectPoint(tn.position)
            let y = size.height - CGFloat(projected.y)
            skNode.position = CGPoint(x: CGFloat(projected.x), y: y)
        }
    }
}



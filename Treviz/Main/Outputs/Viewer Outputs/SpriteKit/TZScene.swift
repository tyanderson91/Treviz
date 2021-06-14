//
//  TZScene.swift
//  Treviz
//
//  Created by Tyler Anderson on 5/25/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: Protocols
class SafeArea: SKNode, ConductorNode {
    var isGrouped = true
    var timeArray: [TimeInterval] = []
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        name = "safeArea"
    }
    override init() {
        super.init()
        name = "safeArea"
    }
}

class TZScene: SKScene, ConductorNode {
    var isGrouped = true
    var background: SKSpriteNode!
    let screenMargin: CGFloat = 0.0
    let safeArea: SafeArea
    var overlays: SKSpriteNode!
    var trajGroups = [SKTrajGroup]()
    /*var startTime: TimeInterval = 0
    var elapsedTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0*/
    var maxSize = CGSize(width: 1, height: 1)
    var vehicleSprites: [SKVehicle] {
        var sprites = [SKVehicle]()
        for g in trajGroups {
            for t in g.trajectories {
                sprites.append(t.vehicleSprite)
            }
        }
        return sprites
    }
    var timeArray: [TimeInterval] = []
    var maxTime: TimeInterval {
        var maxTime: TimeInterval = .leastNormalMagnitude
        for perf in performers {
            guard let curMax = perf.timeArray.last else { continue }
            if curMax > maxTime { maxTime = curMax }
        }
        return maxTime
    }
    var minTime: TimeInterval {
        var minTime: TimeInterval = .greatestFiniteMagnitude
        for perf in performers {
            guard let curMin = perf.timeArray.first else { continue }
            if curMin < minTime { minTime = curMin }
        }
        return minTime
    }
    
    var sceneActions: SKAction {
        var acts = [SKAction]()
        for thisGroup in trajGroups {
            let newAct = SKAction.run {
                thisGroup.run()
            }
            acts.append(newAct)
        }
        return SKAction.sequence([SKAction.group(acts)])
    }
    var playbackController: VisualizerPlaybackController!
    
    override init(size: CGSize) {
        safeArea = SafeArea()
        super.init(size: size)
        self.scaleMode = .resizeFill
        let xmargin = screenMargin/size.width
        let ymargin = screenMargin/size.height
        
        self.anchorPoint = CGPoint(x: xmargin, y: ymargin)
        safeArea.position = self.anchorPoint
        self.addChild(safeArea)
    }
    
    func loadData(data: [State]){
        self.removeAllChildren()
        var xvals = [VarValue](); var yvals = [VarValue]()
        for thisState in data {
            xvals.append(contentsOf: thisState["x"]?.value ?? [])
            yvals.append(contentsOf: thisState["y"]?.value ?? [])
        }
        guard xvals.count > 0, yvals.count > 0 else { return }
        
        let xrange: VarValue = xvals.max()!-xvals.min()!
        let yrange: VarValue = yvals.max()!-yvals.min()!
        
        maxSize = CGSize(width: xrange, height: yrange)
                
        let group1 = SKTrajGroup(data: data)
        let traj = group1.trajectories[0]
        group1.name = "group1"
        group1.trajectories = [traj]
        trajGroups = [group1]
        
        trajGroups.forEach {
            safeArea.addChild($0)
        }
        resizeScene()
        playbackController.reset()
    }
    
    func resizeScene(){
        guard let size = self.view?.bounds.size else { return }
        let xscale = (size.width-2*screenMargin)/maxSize.width
        let yscale = (size.height-2*screenMargin)/maxSize.height
        let sceneScale = [yscale,xscale].min()!
        
        safeArea.setScale(sceneScale)
        vehicleSprites.forEach {$0.setScale(1/sceneScale)}
    }
    
    required init?(coder aDecoder: NSCoder) {
        safeArea = SafeArea()
        super.init(coder: aDecoder)
    }
    
    override func removeAllChildren() {
        safeArea.removeAllChildren()
        trajGroups = []
    }
    
    func runAll() {
        self.resizeScene()
        self.playbackController.reset()
        self.isPaused = false
        self.run(at: 0)
    }
    
    func run(at time: TimeInterval){
        guard time < self.duration else {
            return
        }
        
        let waitTime = self.duration - time
        var act: SKAction
        
        if time > 0 {
            let reducedAction = self.getAction(at: time)
            act = reducedAction
            //act = SKAction.sequence([reducedAction, SKAction.wait(forDuration: waitTime)])
        } else {
            act = self.action
            //act = SKAction.sequence([self.action, SKAction.wait(forDuration: waitTime)])
        }
        /*
        if playbackController.shouldRepeat {
            self.run(act, completion: { self.run(at: 0.0) })
        } else {
            self.run(act, completion: self.postProcess)
        }*/
        self.run(act)
        
        if self.isPaused {
            self.playbackController.pausePlayback()
        } else {
            self.playbackController.continuePlayback()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        playbackController.updatePlaybackPosition(to: currentTime)
    }
}

//
//  TZScene.swift
//  Treviz
//
//  Created by Tyler Anderson on 5/25/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

/**
 Safe Area is all of the 2d area on the screen that trajectory data can occupy
 */
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

/**
 Scene is the SKScene subclass used for the main 2d visualizer playback. Only one TZScene should be created
 */
class TZScene: SKScene, ConductorNode {
    var isGrouped = true
    var background: SKSpriteNode!
    let screenMargin: CGFloat = 15.0
    let safeArea: SafeArea
    var overlays: SKSpriteNode!
    var trajGroups = [SKTrajGroup]()
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
    var backgroundScene: TZScenery!
    var preferences = VisualizerPreferences()
    
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
        backgroundScene = TZScenery(scene: self)
        
        // Finish
        self.anchorPoint = .zero
        safeArea.position = CGPoint(x: xmargin, y: ymargin)
        self.addChild(safeArea)
    }
    
    /**
     Get all run group/run data from the analysis and create all representative nodes and object data
     */
    func loadData(groups: [RunGroup]){
        self.removeAllChildren()
        trajGroups = []
        let cmap: ColorMap = preferences.colorMap ?? .defaultMap
        var xvals = [VarValue](); var yvals = [VarValue]()
        var count = 0
        for thisGroup in groups { // Even if there are no trade groups, the runs should be passed into this function as a single group
            let runData = thisGroup.runs.map({$0.trajData ?? []})
            let trajGroup = SKTrajGroup(data: runData)
            trajGroup.name = thisGroup.groupDescription
            if thisGroup.color == nil { // If no default color is assigned to the group, use value from the colormap
                trajGroup.pathColor = cmap[count, groups.count] ?? NSColor.systemGray.cgColor
            } else {
                trajGroup.pathColor = thisGroup.color!
            }
            trajGroups.append(trajGroup)
            for thisState in runData {
                xvals.append(contentsOf: thisState["x"]?.value ?? [])
                yvals.append(contentsOf: thisState["y"]?.value ?? [])
            }
            count += 1
        }
        guard xvals.count > 0, yvals.count > 0 else { return }
        let xrange: VarValue = xvals.max()!-xvals.min()!
        let yrange: VarValue = yvals.max()!-yvals.min()!
        maxSize = CGSize(width: xrange, height: yrange)
        trajGroups.forEach {
            safeArea.addChild($0)
        }
        resizeScene()
        playbackController?.reset()
    }
    
    /**
     Resets the scene and safe area bounds while keeping the vehicle sprites the same size
     */
    func resizeScene(){
        guard let size = self.view?.bounds.size else { return }
        let xscale = (size.width-2*screenMargin)/maxSize.width
        let yscale = (size.height-2*screenMargin)/maxSize.height
        let sceneScale = [yscale,xscale].min()!
        
        safeArea.setScale(sceneScale)
        safeArea.position = CGPoint(x: screenMargin, y: screenMargin)
        vehicleSprites.forEach {$0.setScale(1/sceneScale)}
        
        backgroundScene?.resize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        safeArea = SafeArea()
        super.init(coder: aDecoder)
    }
    
    override func removeAllChildren() {
        safeArea.removeAllChildren()
        trajGroups = []
    }
    
    /**
     Starts playback of all scene objects from the beginning
     */
    func start() {
        self.isPaused = false
        self.go(to: minTime)
        self.run(at: minTime)
    }
    
    /**
     Gets actions for all child nodes starting from a particular time and plays them through to the end
     */
    func run(at time: TimeInterval){
        guard time < self.maxTime else {
            return
        }
        var act: SKAction
        if time > 0 {
            let reducedAction = self.getAction(at: time)
            act = reducedAction
        } else {
            act = self.action
        }
        self.run(act)
    }
    
    /**
     Run action that updates the current time in the playback controller
     */
    override func update(_ currentTime: TimeInterval) {
        playbackController.updatePlaybackPosition(to: currentTime)
    }
}

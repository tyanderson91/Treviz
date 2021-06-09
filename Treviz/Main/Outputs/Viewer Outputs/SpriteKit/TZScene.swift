//
//  TZScene.swift
//  Treviz
//
//  Created by Tyler Anderson on 5/25/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

protocol VisualizerPlaybackController {
    var scene: TZScene! { get set }
    var speedOptions: [CGFloat] { get }
    var curSpeedOption: Int { get set }
    var playbackSpeed: CGFloat { get }
    var maxTime: VarValue { get set }
    var shouldRepeat: Bool { get set }
    
    func continuePlayback()
    func pausePlayback()
    //var isHidden: Bool { get set }
}
extension VisualizerPlaybackController {
    var playbackSpeed: CGFloat {
        if curSpeedOption < speedOptions.count && curSpeedOption >= 0 {
            return speedOptions[curSpeedOption]
        } else if curSpeedOption >= speedOptions.count {
            let exp = Double(curSpeedOption-speedOptions.count+2)
            return CGFloat(10**exp)
        } else if curSpeedOption < 0 {
            let exp = Double(curSpeedOption-1)
            return CGFloat(10**exp)
        } else {
            return 1.0
        }
    }
}

class TZScene: SKScene {
    var background: SKSpriteNode!
    let screenMargin: CGFloat = 0.0
    let safeArea: SKNode
    var overlays: SKSpriteNode!
    var trajGroups = [SKTrajGroup]()
    var currentTime: VarValue = 0
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
    var isComplete: Bool { return !self.isPaused && !self.isRunning}
    var isRunning: Bool = false
    
    override init(size: CGSize) {
        safeArea = SKNode()
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
        group1.trajectories = [group1.trajectories[0]]
        trajGroups = [group1]
        
        trajGroups.forEach {
            safeArea.addChild($0)
        }
        resizeScene()
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
        safeArea = SKNode()
        super.init(coder: aDecoder)
    }
    
    override func removeAllChildren() {
        safeArea.removeAllChildren()
        trajGroups = []
    }
    
    func runAll() {
        self.resizeScene()

        var completionAct: SKAction
        self.isRunning = true
        let completion: ()->() = { self.postProcess() }
        
        if false {//playbackController.shouldRepeat {
            completionAct = SKAction.run({ self.isRunning = true })
            self.run(self.sceneActions)
        } else {
            completionAct = SKAction.run(completion)
            let newAct = SKAction.sequence([self.sceneActions, completionAct])
            let A = self.isComplete
            self.run(newAct)
        }
        //trajGroups.forEach { $0.run() }
    }
    
    func postProcess(){
        self.isPaused = false
        self.isRunning = false
    }
}

class SKTrajGroup: SKNode {
    var pathColor: CGColor!
    var trajectories = [SKTrajectory]()
    var action: SKAction {
        var acts = [SKAction]()
        for traj in trajectories {
            let newAct = SKAction.run { traj.run() }
            acts.append(newAct)
        }
        return SKAction.group(acts)
    }
    
    init(data: [State]){
        //trajectories = data.map({SKTrajectory(data: $0)})
        trajectories = [SKTrajectory(data: data[0])]
        super.init()
        self.position = CGPoint.zero
        trajectories.forEach {self.addChild($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func run(){
        trajectories.forEach { $0.run() }
    }
    
}

class SKTrajectory: SKNode {
    var showPropagation = false
    var showPath = true
    var trajData: State!
    var vehicleSprite: SKVehicle!
    var action: SKAction { return SKAction.run { self.vehicleSprite.run() } }
    
    init(data: State){
        trajData = data
        super.init()
        vehicleSprite = SKVehicle(trajectory: data)
        vehicleSprite.tzvehicle = Vehicle()
        vehicleSprite.position = CGPoint.zero
        self.addChild(vehicleSprite)
        self.position = CGPoint.zero
        /*
         Make trajectory traces and propagations
        */
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func run(){
        vehicleSprite.run()
    }
}

class SKVehicle: SKNode {
    static let spriteHeight: CGFloat = 60.0

    var tzvehicle: Vehicle! {
        didSet {
            vehicleSprite = SKVehicleBody(imageNamed: self.tzvehicle.imageFile)
            self.resize()
            self.addChild(vehicleSprite)
        }
    }
    
    var vehicleSprite: SKVehicleBody!
    var showPlume = false
    var showShock = false
    var rotateWithVelocity = true
    
    var actions: [SKAction] = []
    
    init(trajectory: State){
        super.init()
        self.position = CGPoint.zero
        
        let times = trajectory["t"]!
        let x: Variable = trajectory["x"]!
        let y: Variable = trajectory["y"]!
        let dx = trajectory["dx"]!
        let dy = trajectory["dy"]!
        
        for idx in 0...(times.value.count)-2 {
            let dt = (times[idx+1]!-times[idx]!)
            let x1 = CGFloat(x[idx]!)
            let y1 = CGFloat(y[idx]!)
            let dx1 = CGFloat(dx[idx]!)
            let dy1 = CGFloat(dy[idx]!)
            let rotation_angle = atan2(dy1, dx1)
            let newPoint = CGPoint(x: x1, y: y1)
            
            let rot = SKAction.rotate(toAngle: rotation_angle, duration: dt)
            let mov = SKAction.move(to: newPoint, duration: dt)
            let act = SKAction.group([rot, mov])
            actions.append(act)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func resize(){
        vehicleSprite.scale(to: SKVehicle.spriteHeight)
    }
    
    func run(){
        let seqAction = SKAction.sequence(self.actions)
        run(seqAction)
    }

}

class SKVehicleBody: SKSpriteNode {
    func scale(to length: CGFloat){
        let s = self.size
        var newSize: CGSize
        if s.width > s.height {
            newSize = CGSize(width: length, height: s.height/s.width*length)
        } else {
            newSize = CGSize(width: s.width/s.height*length, height: length)
        }
        self.size = newSize
    }
}


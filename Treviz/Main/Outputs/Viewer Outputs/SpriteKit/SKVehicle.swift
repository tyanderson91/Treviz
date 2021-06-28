//
//  SKVehicle.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/9/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

class SKVehicle: SKNode, ConductorNode, PerformerNode {
    var states: [SKState] = []
    var isGrouped = false
    static let spriteSize: CGFloat = 1000.0

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
    var action: SKAction { return SKAction.sequence(actions) }
    var actions: [SKAction] = []
    var timeArray: [TimeInterval] = []
    var duration: TimeInterval { return action.duration }
    
    init(trajectory: State){
        super.init()
        self.position = CGPoint.zero
        
        let times = trajectory["t"]!
        let x: Variable = trajectory["x"]!
        let y: Variable = trajectory["y"]!
        let dx = trajectory["dx"]!
        let dy = trajectory["dy"]!
        
        let n = times.value.count - 2
        timeArray = Array(times.value[0...n])
        for idx in 0...n {
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
            states.append(SKState(pos: newPoint, rot: rotation_angle, dt: dt))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func resize(){
        vehicleSprite.scale(to: SKVehicle.spriteSize)
    }
}

class SKVehicleBody: SKSpriteNode {
    func scale(to size: CGFloat){
        let s = self.size
        let totalSize = s.height * s.width
        let scale = (size/totalSize)**0.5
        let newSize = CGSize(width: s.width*scale, height: s.height*scale)
        self.size = newSize
    }
}

//
//  SKTrajectory.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/9/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

class SKTrajectory: SKNode, ConductorNode {
    var isGrouped = true
    var showPropagation = false
    var showPath = true
    var trajData: State!
    var timeArray: [TimeInterval] = []
    var vehicleSprite: SKVehicle!
    var trace: SKTrajectoryTrace!
    
    init(data: State){
        trajData = data
        super.init()
        vehicleSprite = SKVehicle(trajectory: data)
        vehicleSprite.name = "Vehicle"
        vehicleSprite.tzvehicle = Vehicle()
        vehicleSprite.position = CGPoint.zero
        self.addChild(vehicleSprite)
        self.position = CGPoint.zero
        /*
         Make trajectory traces and propagations
        */
        self.trace = SKTrajectoryTrace(trajectory: data)
    
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class SKTrajectoryTrace: SKShapeNode, ConductorNode, PerformerNode {
    var isGrouped: Bool = true
    var timeArray: [TimeInterval] = []
    var actions: [SKAction] = []
    var points: [CGPoint] = []
    var line = CGMutablePath()
    var action: SKAction!
    var states: [SKState] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(trajectory: State){
        super.init()
        
        let times = trajectory["t"]!
        let x: Variable = trajectory["x"]!
        let y: Variable = trajectory["y"]!
        
        let n = times.value.count - 2
        timeArray = Array(times.value[0...n])
        line.move(to: CGPoint(x: x.value[0], y: y.value[0]) )
        
        for idx in 0...n {
            let dt = (times[idx+1]!-times[idx]!)
            let x1 = CGFloat(x[idx]!)
            let y1 = CGFloat(y[idx]!)
            let newPoint = CGPoint(x: x1, y: y1)
            points.append(newPoint)
            line.addLine(to: newPoint)
            states.append(SKState(pos: newPoint, rot: nil, dt: dt))
        }

    }
}

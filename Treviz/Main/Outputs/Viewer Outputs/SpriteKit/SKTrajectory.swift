//
//  SKTrajectory.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/9/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

/** An SKTrajectory contains all the sub-nodes required to render a single trajectory trace, including the vehicle, trajectory path, and any propagation trajectories */
class SKTrajectory: SKNode, ConductorNode {
    var isGrouped = true
    var showPropagation = false
    var showPath = true
    var trajData: State!
    var timeArray: [TimeInterval] = []
    var vehicleSprite: SKVehicle!
    var trace: SKTrajectoryTrace!
    var trajColor: NSColor = .black {
        didSet {
            trace.strokeColor = trajColor
        }
    }
    
    init(data: State){
        trajData = data
        super.init()
        vehicleSprite = SKVehicle(trajectory: data)
        vehicleSprite.name = "Vehicle"
        vehicleSprite.tzvehicle = Vehicle()
        vehicleSprite.position = CGPoint.zero
        self.addChild(vehicleSprite)
        self.position = CGPoint.zero
        
        //Make trajectory traces and propagations
        self.trace = SKTrajectoryTrace(trajectory: data)
        trace.strokeColor = trajColor
        self.addChild(trace)
    
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/** A trajectory trace is a colored line trailing the position of a vehicle through time */
class SKTrajectoryTrace: SKShapeNode, ConductorNode, PerformerNode {
    var isGrouped: Bool = false
    var timeArray: [TimeInterval] = []
    var actions: [SKAction] = []
    var line = CGMutablePath()
    var action: SKAction! { return SKAction.sequence(actions) }
    var states: [SKState] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(trajectory: State){
        super.init()
        
        name = "TrajTrace"
        let times = trajectory["t"]!
        let x: Variable = trajectory["x"]!
        let y: Variable = trajectory["y"]!
        
        let n = times.value.count - 2
        timeArray = Array(times.value[0...n])
        line.move(to: CGPoint(x: x.value[0], y: y.value[0]) )
        
        for idx in 0...n {
            let newTime = times[idx+1]!
            let dt = (newTime-times[idx]!)
            let x1 = CGFloat(x[idx]!)
            let y1 = CGFloat(y[idx]!)
            let newPoint = CGPoint(x: x1, y: y1)
            line.addLine(to: newPoint)
            states.append(SKState(pos: newPoint, rot: nil, dt: dt))
            let newAction = SKAction.run {
                self.move(to: newTime)
            }
            actions.append(SKAction.sequence([SKAction.wait(forDuration: dt), newAction]))
        }
        
        self.lineWidth = 2.0
    }
    
    func move(to time: TimeInterval){
        guard states.count>0 else { return }
        let ind: Int = {
            let tempInd = (timeArray.firstIndex { $0>time } ?? timeArray.count) - 1
            return tempInd >= 0 ? tempInd : 0
        }()
        if ind == 0 {
            self.path = nil
            return
        }
        guard ind < states.count else { return }
        let line = CGMutablePath()
        line.move(to: states.first!.pos)
        for idx in 1...ind {
            line.addLine(to: states[idx].pos)
        }
        self.path = line
    }
}

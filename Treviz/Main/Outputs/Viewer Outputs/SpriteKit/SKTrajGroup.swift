//
//  TrajGroup.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/9/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

/** A Traj Group is a group of several SKTrajectories linked by some common factor, like belonging to the same trade group. They share the same trajectory trace and highlight colors */
class SKTrajGroup: SKNode, ConductorNode {
    var isGrouped = true
    var pathColor: CGColor! {
        didSet {
            trajectories.forEach({$0.trajColor = NSColor(cgColor: pathColor)!})
        }
    }
    var trajectories = [SKTrajectory]()
    var timeArray: [TimeInterval] = []
    
    init(data: [State]){
        trajectories = []
        var tcount = 0
        for d in data {
            let newTraj = SKTrajectory(data: d)
            newTraj.name = "traj\(tcount)"
            newTraj.vehicleSprite.name = "veh\(tcount)"
            newTraj.trace.name = "trace\(tcount)"
            newTraj.trajColor = .controlAccentColor
            trajectories.append(newTraj)
            tcount += 1
        }
        super.init()
        self.position = CGPoint.zero
        self.zPosition = 10
        trajectories.forEach { self.addChild($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

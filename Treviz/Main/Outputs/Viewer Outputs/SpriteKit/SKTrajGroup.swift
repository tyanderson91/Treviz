//
//  TrajGroup.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/9/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

class SKTrajGroup: SKNode, ConductorNode {
    var isGrouped = true
    var pathColor: CGColor!
    var trajectories = [SKTrajectory]()/*
    var action: SKAction {
        var acts = [SKAction]()
        for traj in trajectories {
            let newAct = SKAction.run { traj.run() }
            acts.append(newAct)
        }
        return SKAction.group(acts)
    }*/
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
        trajectories.forEach { self.addChild($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    func run(){
        trajectories.forEach { $0.run() }
    }*/
    
}

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
        //trajectories = data.map({SKTrajectory(data: $0)})
        let traj0 = SKTrajectory(data: data[0])
        traj0.name = "traj0"
        trajectories = [traj0]
        super.init()
        self.position = CGPoint.zero
        trajectories.forEach {self.addChild($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    func run(){
        trajectories.forEach { $0.run() }
    }*/
    
}

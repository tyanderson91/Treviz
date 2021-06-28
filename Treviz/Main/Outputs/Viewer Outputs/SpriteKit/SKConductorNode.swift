//
//  SKConductorNode.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/10/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

protocol ConductorNode {
    var isGrouped: Bool { get }
    var duration: TimeInterval { get }
    var action: SKAction { get }
    var timeArray: [TimeInterval] { get set }
    var scene: SKScene? { get }
    
    // SKNode
    var name: String? { get set }
    var children: [SKNode] { get }
    var performers: [PerformerNode] { get }
    func run()
    func run(_ action: SKAction)
    func removeAllActions()
    
}

struct SKState {
    var pos: CGPoint
    var rot: CGFloat?
    var dt: TimeInterval
}
protocol PerformerNode {
    var actions: [SKAction] { get set }
    var states: [SKState] { get set }
    var timeArray: [TimeInterval] { get set }
    
    //SKNode
    var position: CGPoint { get set }
    var zRotation: CGFloat { get set }
}

extension ConductorNode {
    var childPlayers: [ConductorNode] {
        self.children.compactMap {
            if $0 is ConductorNode { return ($0 as! ConductorNode) }
            else { return nil }
        }
    }
    var performers: [PerformerNode] {
        var performers = [PerformerNode]()
        self.childPlayers.forEach {
            if let thisPerf = $0 as? PerformerNode {
                performers.append(thisPerf)
            }
            else {
                performers.append(contentsOf: $0.performers)
            }
        }
        return performers
    }
    
    var action: SKAction {
        let childActions: [SKAction] = children.compactMap({
            guard let n = $0 as? ConductorNode, n.name != nil else { return nil }
            return SKAction.run(n.action, onChildWithName: n.name!)
        })
        if isGrouped { return SKAction.group(childActions) }
        else { return SKAction.sequence(childActions) }
    }

    var duration: TimeInterval {
        if isGrouped {
            return childPlayers.max(by: { return $0.duration < $1.duration })?.duration ?? 1.23
        } else {
            let allDurations: [TimeInterval] = childPlayers.map({$0.duration})
            return allDurations.reduce(0, +) // Sum all durations
        }
    }
    
    func run(){
        self.run(action)
    }
    
    func getAction(at time: TimeInterval)->SKAction{
        var curActions: [SKAction]
        if let perf = self as? PerformerNode {
            let ind: Int = {
                let tempInd = (perf.timeArray.firstIndex { $0>time } ?? perf.timeArray.count-1)
                return tempInd > 0 ? tempInd : 1
            }()
            guard ind < perf.actions.count else { return action }
            curActions = Array(perf.actions[ind...perf.actions.count-1])
        } else {
            curActions = []
            for thisChild in childPlayers {
                guard thisChild.name != nil else { continue }
                let thisChildAction = thisChild.getAction(at: time)
                curActions.append(SKAction.run(thisChildAction, onChildWithName: thisChild.name!))
            }
        }
        if isGrouped { return SKAction.group(curActions) }
        else { return SKAction.sequence(curActions) }
    }
    
    func go(to time: TimeInterval){
        if var perf = self as? PerformerNode {
            let ind: Int = {
                let tempInd = (perf.timeArray.firstIndex { $0>time } ?? perf.timeArray.count) - 1
                return tempInd >= 0 ? tempInd : 0
            }()
            guard ind < perf.states.count else { return }
            let thisState = perf.states[ind]
            perf.position = thisState.pos
            perf.zRotation = thisState.rot!
        }
        for thisChild in childPlayers {
            thisChild.go(to: time)
        }
        
    }
    
    func stop(){
        removeAllActions()
        childPlayers.forEach {$0.stop()}
    }
}

//
//  SKConductorNode.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/10/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit

/**
 ConductorNode should be applied to any SKNode instance that "Conducts" a number of child nodes or sprites; that is, there should be several children each with their own defined actions for themselves that must move in unison (if isGrouped) or sequentially (if !isGrouped)
 */
protocol ConductorNode {
    var isGrouped: Bool { get }
    var duration: TimeInterval { get }
    var action: SKAction { get }
    var timeArray: [TimeInterval] { get set }
    var scene: SKScene? { get }
    var isPerformer: Bool { get }
    
    // SKNode
    var name: String? { get set }
    var children: [SKNode] { get }
    var performers: [PerformerNode] { get }
    func run()
    func run(_ action: SKAction)
    func removeAllActions()
    
}

/**
 State of a particular SKSpriteNode (position, rotation, and associated dt at a given point in time)
 */
struct SKState {
    var pos: CGPoint
    var rot: CGFloat?
    var dt: TimeInterval
}

/** A PerformerNode should be applied to SpriteNodes that are "Conducted" by Conductor nodes; that is, they contain sets of actions that should be performed at the same time as other performers. A PerformerNode should also be a ConductorNode
 */
protocol PerformerNode {
    var actions: [SKAction] { get set }
    var states: [SKState] { get set }
    var timeArray: [TimeInterval] { get set }
    mutating func move(to time: TimeInterval)
    
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
    
    /** Single action to be performed on the self that should apply to all children */
    var action: SKAction {
        let childActions: [SKAction] = children.compactMap({
            guard let n = $0 as? ConductorNode, n.name != nil else { return nil }
            return SKAction.run(n.action, onChildWithName: n.name!)
        })
        if isGrouped { return SKAction.group(childActions) }
        else { return SKAction.sequence(childActions) }
    }

    /** Total length required to perform all child actions */
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
    
    var isPerformer: Bool { return self is PerformerNode }
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
            perf.move(to: time)
        }
        for thisChild in childPlayers {
            thisChild.go(to: time)
        }
    }
    
    /** Stop all currently running actions */
    func stop(){
        removeAllActions()
        childPlayers.forEach {$0.stop()}
    }
}

extension PerformerNode {
    /** Change the current state to whatever the saved state is at the given time */
    mutating func move(to time: TimeInterval) {
        let ind: Int = {
            let tempInd = (timeArray.firstIndex { $0>time } ?? timeArray.count) - 1
            return tempInd >= 0 ? tempInd : 0
        }()
        guard ind < states.count else { return }
        let thisState = states[ind]
        position = thisState.pos
        zRotation = thisState.rot!
    }
}

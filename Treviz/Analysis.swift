//
//  Analysis.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/5/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class Analysis: NSObject {
    var initialState = State()
    var terminalConditions = TerminalConditionSet([])
    var returnCodes : [Int] = []
    var trajectory : [[Double]] = [] //TODO : allow multiple variable types
    var progressBar : NSProgressIndicator!
    var outputsVC : OutputsViewController!
    //Set up terminal conditions
    
    func runAnalysis() -> [Int] {
        var currentState = initialState.toArray()
        let dt : Double = 0.1
        
        let termCond1 = TerminalCondition(varID: "t", crossing: 100, inDirection: 1) //TODO: make max time a required terminal condition
        let termCond2 = TerminalCondition(varID: "x", crossing: 40, inDirection: 1)
        terminalConditions = TerminalConditionSet([termCond1,termCond2])
        terminalConditions.initState = currentState

        //let newState = VehicleState()
        //var trajIndex = 1
        var analysisEnded = false
        let state = State.stateVarPositions //map of identifiers to positions
        
        self.trajectory.append(currentState)
        while !analysisEnded{
            var newState = State.initAsArray()
            let m = currentState[state["m"]!]
            let x = currentState[state["x"]!]
            let y = currentState[state["y"]!]
            let dx = currentState[state["dx"]!]
            let dy = currentState[state["dy"]!]
            let t = currentState[state["t"]!]

            let F_g = -9.81*m
            let a_y = F_g/m
            let a_x : Double = 0
            
            newState[state["t"]!] = t + dt
            newState[state["dy"]!] = dy + a_y * dt
            newState[state["y"]!] = y+dy*dt
            newState[state["dx"]!] = dx+a_x*dt
            newState[state["x"]!] = x + dx*dt
            newState[state["m"]!] = m
            trajectory.append(newState)
            
            var pctComplete = 0.0
            (returnCodes,analysisEnded,pctComplete) = terminalConditions.checkAllConditions(prevState: currentState, curState: newState)
            
            currentState = newState
            progressBar.doubleValue = pctComplete*100
        }
        return returnCodes
    }
}

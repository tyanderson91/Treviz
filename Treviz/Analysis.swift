//
//  Analysis.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/5/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class terminalCondition {
 //   var previousState = VehicleState() //TODO: make this value only apply to ALL terminal conditions
    var varID : VariableID //statePosition : Int = 99 //Max number of terminal conditions
    var value : Double = 0.0
    var direction = -1
    
    init(varID: VariableID, crossing value: Double, inDirection: Int){
        self.varID = varID
        self.value = value
        self.direction = inDirection
    }
    
    func checkConditions(prevState: [Double], curState : [Double]) -> Int {
        let prevStateValue = prevState[State.stateVarPositions[self.varID]!]
        let curStateValue = curState[State.stateVarPositions[self.varID]!]
        var returnCode = -1
        let statePos = State.stateVarPositions[varID]!
        
        if direction == -1{//Negative crossing TODO: combine into one statement
            returnCode = (curStateValue <= value && prevStateValue > value) ? statePos : -1
            //return returnCode
        }
        else if direction == 1{//Positive crossing
            returnCode = (curStateValue >= value && prevStateValue < value) ? statePos : -1
            //return returnCode
        }
        else if direction == 0{//Either crossing
            returnCode = (curStateValue-value).sign != (prevStateValue-value).sign ? statePos : -1
        }
        else{returnCode = -1
            //return -1
        }
        
        return returnCode
    }
}

class Analysis: NSObject {
    var initialState = State()
    var terminalConditions : [terminalCondition] = []
    var returnCodes : [Int] = []
    var trajectory : [[Double]] = [] //TODO : allow multiple variable types
    //Set up terminal conditions
    
    func runAnalysis() -> [Int] {
        let termCond1 = terminalCondition(varID: "t", crossing: 100, inDirection: 1) //TODO: make max time a required terminal condition
        let termCond2 = terminalCondition(varID: "y", crossing: 0, inDirection: 0)
        terminalConditions = [termCond1,termCond2]
        
        var currentState = initialState.toArray()
        let dt : Double = 0.1
        
        //let newState = VehicleState()
        var trajIndex = 1
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
            
            var returnCodes : [Int] = []
            var i = 0
            for termCond in terminalConditions{
                let curCode = termCond.checkConditions(prevState: currentState, curState: newState)
                returnCodes.insert(curCode, at:i)
                if curCode != -1{
                    analysisEnded = true
                    print("Analysis ended with return code \(curCode)")
                }
                i+=1
            }
            currentState = newState
            trajIndex+=1
        }
        return returnCodes
    }
}

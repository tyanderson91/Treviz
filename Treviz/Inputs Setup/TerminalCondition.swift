//
//  TerminalCondition.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/9/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class TerminalCondition {
    //   var previousState = VehicleState() //TODO: make this value only apply to ALL terminal conditions
    var varID : VariableID //statePosition : Int = 99 //Max number of terminal conditions
    var value : Double = 0.0
    var direction = -1

    
    init(varID: VariableID, crossing value: Double, inDirection: Int){
        self.varID = varID
        self.value = value
        self.direction = inDirection
    }
    
    func checkCondition(prevState: [Double], curState : [Double]) -> Int {
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
    
    func pctComplete(initState: [Double], curState: [Double])->Double{
        let curStateValue = curState[State.stateVarPositions[self.varID]!]
        let initStateValue = initState[State.stateVarPositions[self.varID]!]
        let finalStateValue = self.value
        var pctComplete : Double = 0.0
        let progressType = "linear"
        if progressType == "linear"{
            pctComplete = (curStateValue - initStateValue)/(finalStateValue - initStateValue)
        }
        
        return pctComplete
    }
}

class TerminalConditionSet {
    var pctComplete = 0.0
    var initState: [Double] = []
    var conditions : [TerminalCondition] = []
    var analysisComplete = false
    
    init(_ conditions : [TerminalCondition]){
        self.conditions = conditions
    }
    
    func checkAllConditions(prevState: [Double], curState: [Double])->([Int],Bool,Double){
        var returnCodes : [Int] = Array(repeating:-1, count:self.conditions.count)
        var i = 0
        
        var tempPctComplete = 0 as Double
        for termCond in self.conditions{
            let curCode = termCond.checkCondition(prevState: prevState, curState: curState)
            let curPctComplete = termCond.pctComplete(initState: self.initState, curState: curState)
            
            tempPctComplete = (tempPctComplete < curPctComplete) ? curPctComplete : tempPctComplete
            returnCodes.insert(curCode, at:i)
            if curCode != -1{
                analysisComplete = true
                print("Analysis ended with return code \(curCode)")
            }
            i+=1
        }
        if tempPctComplete < 0{
            tempPctComplete = 0}
        else if tempPctComplete > 1{
            tempPctComplete = 1}

        pctComplete = tempPctComplete
        return (returnCodes,analysisComplete,pctComplete)
    }
}

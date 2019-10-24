//
//  State.swift
//  Treviz
//
//  State is an object containing a collection of Variable objects that combined should fully define the state of a vehicle at any point in time
//  Used to read input state, write output state, parse outputs, and create derived states.
//  Converts into an array of Double values before being processed by the propagator
//
//  Created by Tyler Anderson on 3/3/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

typealias StateArray = Array<Double>

class State: NSObject { //TODO: try to phase this out
    static let stateVarPositions : [VariableID] = //TODO : this can definitely be cleaned up
        ["t","x","y","z","dx","dy","dz","mtot","q0","q1","q2","q3",
         "dq0","dq1","dq2","dq3"]
    
    static func getValue(_ varID : VariableID, state: StateArray)->Double?{
        if let index = stateVarPositions.firstIndex(where: { $0 == varID }){
            return state[index]
        } else {return nil}
    }
    
    var variables : [Variable] = []
    var length : Int {
        var curlen = -1
        for thisVar in variables {
            curlen = max(curlen, thisVar.value.count)
        }
        return curlen
    }
    
    //var varIDs : [VariableID] = []
    
    /*
    func fromVars(_ curVars: [Variable]){
        self.variables = []
        self.varIDs = []
        
        var newVarIndex = 0
        for curVar in curVars{
            curVar.statePosition = newVarIndex
            newVarIndex+=1
            self.varIDs.append(curVar.id)
            self.variables.append(curVar)
        }
        /*
        for curID in Variable.allIdentifiers{
            self.variables.append(curVars[varIDs.firstIndex(of:curID)!])//rearrange the state Items to match with the itemType order
            
            newVarIndex+=1

        }*/
    
    }
    */
    override init() {
        self.variables = []
        super.init()
    }
    
    init(variables: [Variable]) {
        self.variables = variables
        super.init()
    }
    
    subscript(_ varID: VariableID) -> Variable {
        get {
            let thisVar = variables.first(where: {$0.id == varID})!
            return thisVar
        }
    }
    
    subscript(_ varID: VariableID, index: Int) -> Double? {// TODO : see how to get rid of keyword
        get {
            let thisVar = self[varID]
            if let thisVal = thisVar[index] {return thisVal}
            else{return nil}
        }
        set (newVal) {
            let thisVar = self[varID]
            if newVal != nil {thisVar[index] = newVal}
        }
    }
    
    subscript(index: Int) -> [Double] {
        var stateArray = StateArray() //Array.init(repeating: 0, count: State.stateVarPositions.count)
        for thisVarID in State.stateVarPositions {
            if let thisVal = self[thisVarID, index] {
                stateArray.append(thisVal)
            }
        }
        return stateArray
    }
    
    //Subscripts by condition
    subscript(varIDs: [VariableID], condition: Condition) -> [VariableID: [Double]]? {
        // Note that this subscript may take some time to collect, since by default it will evaluate the condition
        var output = [VariableID: [Double]]()
        condition.evaluate(self)
        let conditionIndex = condition.meetsConditionIndex
        
        for thisVarID in varIDs {
            guard self[thisVarID].value.count == condition.meetsCondition?.count else {return nil}
            output[thisVarID] = [Double]()
        }
        for thisIndex in conditionIndex {
            for thisVarID in varIDs {
                let thisVarValue = self[thisVarID].value[thisIndex]
                output[thisVarID]!.append(thisVarValue)
            }
        }
        return output
    }
    subscript(vars: [Variable], condition: Condition)->[VariableID: [Double]]?{
        let varIDs = vars.map{ $0.id }
        let output = self[varIDs, condition]
        return output
    }
    subscript(varID: VariableID, condition: Condition)->[Double]?{
        if let output = self[[varID], condition]{
            return output[varID]}
        else {return nil}
    }
    subscript(variable: Variable, condition: Condition)->[Double]?{
        let varID = variable.id
        return self[varID, condition]
    }
    

}

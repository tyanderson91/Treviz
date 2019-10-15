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

class State: NSObject { //TODO: try to phase this out
    static let stateVarPositions : [VariableID : Int] = //TODO : this can definitely be cleaned up
        ["t":0,"x":1,"y":2,"z":3,"dx":4,"dy":5,"dz":6,"mtot":7,"q0":8,"q1":9,"q2":10,"q3":11,
         "dq0":12,"dq1":13,"dq2":14,"dq3":15] //Dear god, get rid of this
    var variables : [Variable]
    
    
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
    
    subscript(varID: VariableID) -> Variable? {
        get {
            if let thisVar = variables.first(where: {$0.id == varID}){return thisVar}
            else {print("VarID \(varID) not found")
                return nil}
        }
    }
    
    subscript(varID: VariableID, index: Int) -> Double? {
        get {
            if let thisVar = self[varID] {
                if let thisVal = thisVar[index] {return thisVal}
            } else {print("Index \(varID) not found")
                return nil}
            return nil
        }
        
        set (newVal) {
            if let thisVar = self[varID] {
                if newVal != nil {thisVar[index] = newVal}
            }
        }
    }
    
    init(fromInputVars inputs: [Variable]?){
        if inputs != nil {
            var newStateVars = Array(repeating: Variable(""), count: State.stateVarPositions.count) as [Variable]
            for curVar in inputs! {
                if State.stateVarPositions.keys.contains(curVar.id){
                    if let varIndex = State.stateVarPositions[curVar.id]{
                        newStateVars[varIndex] = curVar}
                }
            }
            self.variables = newStateVars
            //self.varIDs = []
        } else {self.variables = []}
    }
    
    func setItemValue(id: VariableID, value: Double){
        if let thisIndex = State.stateVarPositions[id]{
            self.variables[thisIndex].value = [value]}
    }
    
    func getValue(_ id: VariableID)->Double?{// TODO : do not force Double
        if let thisIndex = State.stateVarPositions[id]{
            return self.variables[thisIndex].value[0]}
        else {return nil}
    }
    
    func toArray()->[Double]{
        /*This function takes the object structure of the State and returns as a single array of variable values (in metric)
        If the order is changed, it must also be changed in the Analysis class
 State variables: [t,x,y,z,dx,dy,dz,m,q0,q1,q2,q3,dq0,dq1,dq2,dq3]
        */
        
        //let idMapped = self.varIDs.map {stateVarPositions[$0]}
        var varArray : [Double] = Array<Any>(repeating: 0.0, count:State.stateVarPositions.count) as! [Double]
        for curVar in self.variables{
            var doubleValue = 0.0
            doubleValue = curVar.value[0]
            varArray[State.stateVarPositions[curVar.id]!] = doubleValue
        }
        return varArray
    }
    
    /*
    func fromArray(_ stateArray:[Double?]){
        for curVar in stateArray{
            let thisVar =
        }
    }*/
 
    class func initAsArray()->[Double]{
        let thisArray : [Double] = Array(repeating: 0, count:State.stateVarPositions.count)
        return thisArray
    }
}

//
//  State.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/3/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class State: NSObject {
    static let stateVarPositions : [VariableID : Int] =
        ["t":0,"x":1,"y":2,"z":3,"dx":4,"dy":5,"dz":6,"m":7,"q0":8,"q1":9,"q2":10,"q3":11,
         "dq0":12,"dq1":13,"dq2":14,"dq3":15]
    var variables : [Variable] = []
    var varIDs : [VariableID] = []
    
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
    
    func setItemValue(id: String, value: Double){
        let thisIndex = self.varIDs.firstIndex(of:id)
        self.variables[thisIndex!].value = value
    }
    
    func getValue(_ id: String)->Double{
        let thisIndex = self.varIDs.firstIndex(of:id)
        return self.variables[thisIndex!].value
    }
    
    func toArray()->[Double]{
        /*This function takes the object structure of the State and returns as a single array of variable values (in metric)
        If the order is changed, it must also be changed in the Analysis class
 State variables: [t,x,y,z,dx,dy,dz,m,q0,q1,q2,q3,dq0,dq1,dq2,dq3]
        */
        
        //let idMapped = self.varIDs.map {stateVarPositions[$0]}
        var varArray : [Double] = Array<Any>(repeating: 0.0, count:State.stateVarPositions.count) as! [Double]
        for curVar in self.variables{
            varArray[State.stateVarPositions[curVar.id]!] = curVar.value
        }
        return varArray
    }
    
    /*
    func fromArray(_ stateArray:[Double?]){
        for curVar in stateArray{
            let thisVar =
        }
    }
 */
    class func initAsArray()->[Double]{
        let thisArray : [Double] = Array(repeating: 0, count:State.stateVarPositions.count)
        return thisArray
    }
}

//
//  StateArray.swift
//  Treviz
//
//  Functions related to turning a state object into an array of doubles
//
//  Created by Tyler Anderson on 10/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

typealias StateArray = Array<VarValue>

extension State {
    static let stateVarPositions : [VariableID] = [ //TODO: Find a beter way to take care of this
        "t","x","y","z","dx","dy","dz","mtot","q0","q1","q2","q3",
        "dq0","dq1","dq2","dq3"]
    static var it = 0
    static var ix = 1
    static var iy = 2
    static var iz = 3
    static var idx = 4
    static var idy = 5
    static var idz = 6
    static var imtot = 7
    static var iqo = 8
    static var iq1 = 9
    static var iq2 = 10
    static var iq3 = 11
    static var idq0 = 12
    static var idq1 = 13
    static var idq2 = 14
    static var idq3 = 15
    
    /**
     Sorting algorithm puts variables in their proper position according to StateVarPositions, otherwise throws them to the end. Useful for automatically extracting by position when running analysis
     */
    func sortVarIndices(){
        self.variables = State.sortVarIndices(self.variables)
    }
    static func sortVarIndices(_ varList : [Variable])->[Variable]{
        return varList.sorted { (var1, var2) -> Bool in
            let indexPos1 = State.stateVarPositions.firstIndex(where: {$0 == var1.id} )
            let indexPos2 = State.stateVarPositions.firstIndex(where: {$0 == var2.id} )
            if indexPos1 == nil {return indexPos2 == nil}
            else if indexPos2 == nil {return true}
            else {return indexPos1! < indexPos2!}
        }
        
    }
    
    static func getValue(_ varID : VariableID, _ state: StateArray)->VarValue?{
        if let index = stateVarPositions.firstIndex(where: { $0 == varID }){
            return state[index]
        } else {return nil}
    }/*
    subscript(varID: VariableID) -> [VarValue]? {
        if let index = State.stateVarPositions.firstIndex(where: { $0 == varID }){
            return self[index]
        } else {return nil}
    }*/
    
    subscript(index: Int) -> [VarValue] {
        get {
            var stateArray = StateArray()
            for thisVarID in State.stateVarPositions {
                if let thisVal = self[thisVarID, index] {
                    stateArray.append(thisVal)
                }
            }
            return stateArray
        }
        set (newArray) {
            var i = 0
            for thisValue in newArray {
                let varID = State.stateVarPositions[i]
                var thisVar = self[varID]
                thisVar[index] = thisValue
                self[varID] = thisVar
                i += 1
            }
        }
    }
    
}

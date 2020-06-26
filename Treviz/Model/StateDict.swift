//
//  StateDict.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/25/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa
/*
enum StateError: Error, LocalizedError {
    case UnmatchingVarLength
}

struct StateDictArray : Dictionary<VariableID, Array<VarValue>> {
    init(from state: State) throws {
        var curLen = 0
        for thisVar in state.variables {
            if curLen == 0 { curlen = thisVar.value.count }
            else if curlen != thisVar.value.count { throw StateError.UnmatchingVarLength }
        } // All variables in the input State should have the same number of entries
        let fullIndexSet = IndexSet(integersIn: 0...curLen)
        self.init(from: state, at: fullIndexSet)
    }
    
    init(from state: State, at indices: IndexSet) {
        for thisVar in state.variables {
            // TODO: Once Units are implemented, assert that all input variables use standard metric units
            self[thisVar.id] = thisVar.value[indices]
        }
    }
    init(from state: State, at index: Int) {
        self.init(from: state, at: [index])
    }
}

extension State {
    /**
     Sorting algorithm puts variables in their proper position according to StateVarPositions, otherwise throws them to the end. Useful for automatically extracting by position when running analysis
     */
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
                let thisVar = self[State.stateVarPositions[i]]
                //let varID = State.stateVarPositions[i]
                //let thisVar = self[varID]
                thisVar[index] = thisValue
                //self[varID] = thisVar
                i += 1
            }
        }
    }
    
}
*/

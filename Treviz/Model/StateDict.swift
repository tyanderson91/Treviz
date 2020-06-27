//
//  StateDict.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/25/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

enum StateError: Error, LocalizedError {
    case UnmatchingVarLength
}

typealias StateDictArray = Dictionary<VariableID, Array<VarValue>>
typealias StateDictSingle = Dictionary<VariableID, VarValue>

/**
 A StateDictArray is a dictionary of var values. The Keys are VarIDs, and the values are the values associated with that VarID (in standard metric units). This provides a convenient data structure to pass around trajectory information without the overhead associated with full Variable objects
 */
extension StateDictArray {
    init(from state: State) throws {
        //var curLen : Int?
        self.init()
        for thisVar in state {
            //if curLen == nil { curlen = thisVar.value.count }
            //else if curlen! != thisVar.value.count { throw StateError.UnmatchingVarLength }
            self[thisVar.id] = thisVar.value
        } // All variables in the input State should have the same number of entries
    }
    /*
    init(from state: State, at indices: [Int]) {
        for thisVar in state.variables {
            // TODO: Once Units are implemented, assert that all input variables use standard metric units
            self[thisVar.id] = thisVar
        }
    }*/
    init(from state: State, at index: Int) {
        self.init()
        var i: Int!
        if index == -1 { i = state[0].value.count - 1}
        else { i = index }
        for thisVar in state {
            // TODO: Once Units are implemented, assert that all input variables use standard metric units
            self[thisVar.id] = [thisVar.value[i]]
        }
    }
}

/**
A StateDictSingle is just like a StateDictArray, but only contains data for a single point in a trajectory. This is useful for, say, evaluating a condition at a particular point in the trajectory
*/
extension StateDictSingle {
    init(from state: State, at index: Int) {
        self.init()
        var i: Int!
        if index == -1 { i = state[0].value.count - 1}
        else { i = index }
        for thisVar in state {
            // TODO: Once Units are implemented, assert that all input variables use standard metric units
            self[thisVar.id] = thisVar.value[i]
        }
    }
    init(lastestFromState state: State) {
        self.init()
        let index = state[0].value.count - 1
        for thisVar in state {
            // TODO: Once Units are implemented, assert that all input variables use standard metric units
            self[thisVar.id] = thisVar.value[index]
        }
    }
}

extension State {
    subscript(index: Int) -> StateDictSingle {
        get {
            return StateDictSingle(from: self, at: index)
        }
        set (newDict) {
            var i = 0
            for (thisKey, thisVal) in newDict {
                if let thisVar = self.first(where: { $0.id == thisKey }){
                    thisVar[index] = thisVal
                    i += 1
                }
            }
        }
    }
    
}

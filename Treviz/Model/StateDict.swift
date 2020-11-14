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

/**
 A StateDictArray is a dictionary of var values. The Keys are VarIDs, and the values are the values associated with that VarID (in standard metric units). This provides a convenient data structure to pass around trajectory information without the overhead associated with full Variable objects
 */
struct StateDictArray: Collection, ExpressibleByDictionaryLiteral {
    //MARK: Stardard Dictionary functions
    typealias DictionaryType = Dictionary<ParamID, [VarValue]>
    typealias Index = DictionaryType.Index
    typealias Element = DictionaryType.Element
    typealias Key = ParamID
    typealias Value = [VarValue]
    
    private var variables = DictionaryType()
    var startIndex: Index { return variables.startIndex }
    var endIndex: Index { return variables.endIndex }
    
    subscript(index: Index) -> Element {
        get { return variables[index] }
    }
    subscript(varid: ParamID) -> [VarValue]? {
        mutating get {
            if variables.keys.contains(varid) { return variables[varid] ?? nil }
            else {
                guard let thisVarCalc = phase?.varCalculationsMultiple[varid] else {return nil}
                let varValue = thisVarCalc(&self)
                self[varid] = varValue
                return varValue
            }
        }
        set { variables[varid] = newValue }
    }
    func index(after i: DictionaryType.Index) -> DictionaryType.Index {
        return variables.index(after: i)
    }
    
    init(dictionaryLiteral elements: (ParamID, [VarValue])...) {
        for (varid, varval) in elements {
            variables[varid] = varval
        }
    }
    
    //MARK: Custom behavior
    var phase: TZPhase?
    var stateLen: Int {
        for thisVar in self.variables {
            let thisCount = thisVar.value.count
            if thisCount > 0 { return thisCount }
        }
        return 0
    }
    init(){
        variables = DictionaryType()
    }
    init(from state: State) {//throws
        //var curLen : Int?
        self.init()
        for thisVar in state {
            //if curLen == nil { curlen = thisVar.value.count }
            //else if curlen! != thisVar.value.count { throw StateError.UnmatchingVarLength }
            self[thisVar.id] = thisVar.value
        } // All variables in the input State should have the same number of entries
    }

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
    
    subscript(_ index: Int)->StateDictSingle {
        get {
            var returnDict = StateDictSingle()
            for (thisVarID, thisVarVal) in self {
                // TODO: Once Units are implemented, assert that all input variables use standard metric units
                returnDict[thisVarID] = thisVarVal[index]
            }
            return returnDict
        }
        set (newState) {
            for (thisVarID, _) in self {
                self[thisVarID, index] = newState[thisVarID]
            }
        }
    }
    subscript(_ varid: ParamID, index: Int)->VarValue? {
        mutating get {
            guard let thisVar = self[varid] else { return nil }
            if index < thisVar.count { return thisVar[index] }
            else { return nil }
        }
        set {
            guard newValue != nil else {return}
            if index < self[varid]?.count ?? 0 {
                self[varid]?[index] = newValue!
            }
            /*guard let thisVar = self[varid] else {return}
            if index < thisVar.count {
                self[varid]!.insert(newValue!, at: index)
            }*/
        }
    }
    
    mutating func append(_ newState: StateDictSingle) {
        for (thisVarID, _) in self {
            if let matchingVar = newState[thisVarID] {
                self[thisVarID]!.append(matchingVar)
            }
        }
    }
}

/**
A StateDictSingle is just like a StateDictArray, but only contains data for a single point in a trajectory. This is useful for, say, evaluating a condition at a particular point in the trajectory
*/
struct StateDictSingle: Collection, ExpressibleByDictionaryLiteral {
    // MARK: Standard Dictionary functions
    typealias DictionaryType = Dictionary<ParamID, VarValue>
    typealias Index = DictionaryType.Index
    typealias Element = DictionaryType.Element
    typealias Key = ParamID
    typealias Value = VarValue
    
    private var variables = DictionaryType()
    var startIndex: Index { return variables.startIndex }
    var endIndex: Index { return variables.endIndex }
    
    subscript(index: Index) -> Element {
        get { return variables[index] }
    }
    subscript(varid: ParamID) -> VarValue? {
        get { return variables[varid] ?? nil }
        set { variables[varid] = newValue }
    }
    func index(after i: DictionaryType.Index) -> DictionaryType.Index {
        return variables.index(after: i)
    }
    
    init(dictionaryLiteral elements: (ParamID, VarValue)...) {
        for (varid, varval) in elements {
            variables[varid] = varval
        }
    }
    
    //MARK: Custom behaviors
    var phase: TZPhase?
    init(from state: State, at index: Int) {
        self.init()
        var i: Int!
        if index == -1 { i = state[0].value.count - 1}
        else { i = index }
        for thisVar in state {
            // TODO: Once Units are implemented, assert that all input variables use standard metric units
            if thisVar is StateCalcVariable { continue }
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

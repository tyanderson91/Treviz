//
//  CalculatedVariable.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/2/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 This is a subclass of the Variable object that uses a State to calculate the variable values. This is the base type for any derived variables
 */
class StateCalcVariable: Variable {
    let temppid: String = "here"
    var singleStateCalculation: (inout StateDictSingle)->VarValue = {_ in return VarValue()}
    var multiStateCalculation: (inout StateDictArray)->[VarValue] = {_ in return [VarValue]()}
    func calculate(from input: State) {
        //do {
            var array = StateDictArray(from: input)
            value = multiStateCalculation(&array)
        //} catch {}
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    init(_ idIn: VariableID, named nameIn: String = "", symbol symbolIn: String = "", units unitsIn: String = "", calculation calcIn: @escaping (inout StateDictSingle)->VarValue) {
        super.init(idIn, named: nameIn, symbol: symbolIn, units: unitsIn)
        singleStateCalculation = calcIn
        multiStateCalculation = { (stateIn: inout StateDictArray) in
            let len = stateIn.stateLen
            var newArray = Array(repeating: VarValue(0), count: len)
            for i in 0...stateIn.stateLen - 1 {
                var curState = stateIn[i]
                newArray[i] = self.singleStateCalculation(&curState)
            }
            return newArray
        }
    }
    init(_ idIn: VariableID, named nameIn: String = "", symbol symbolIn: String = "", units unitsIn: String = "", calculation calcIn: @escaping (inout StateDictArray)->[VarValue]) {
        super.init(idIn, named: nameIn, symbol: symbolIn, units: unitsIn)
        multiStateCalculation = calcIn
    }
    
    override func copyToPhase(phaseid: String)->StateCalcVariable {
        var newID: VariableID = ""
        if !self.id.contains(".") {
            newID = phaseid + "." + self.id
        } else {
            newID = phaseid + "." + self.id.baseVarID()
        }
        let newVar = StateCalcVariable(newID, named: name, symbol: symbol, units: units, calculation: singleStateCalculation)
        newVar.value = value
        return newVar
    }
    override func stripPhase()->Variable {
        var newID: VariableID = ""
        if self.id.contains(".") {
            newID = self.id.baseVarID()
        } else {
            newID = self.id
        }
        let newVar = StateCalcVariable(newID, named: name, symbol: symbol, units: units, calculation: singleStateCalculation)
        newVar.value = value
        return newVar
    }
}

class AggregateCalcVariable: Variable {
    var calculation: ([TZPhase])->[VarValue] = {_ in return [VarValue]()}
    func calculate(varid: VariableID, in phases: [TZPhase]){
        var value = [VarValue]()
        for thisPhase in phases {
            if let matchingVar = thisPhase.varList.first(where: {$0.id.baseVarID() == varid}) {
                value.append(contentsOf: matchingVar.value)
            }
        }
    }
}

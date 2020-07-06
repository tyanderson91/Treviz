//
//  CalculatedVariable.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/2/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa
/*
class CalculatedVariable: Variable {
    var calculation: (Any)->[VarValue] = {_ in return [VarValue]()}
    func calculate(from input: Any) {
        value = calculation(input)
    }
}*/
/**
 This is a subclass of the Variable object that uses a State to calculate the variable values. This is the base type for any derived variables
 */
class StateCalcVariable: Variable {
    var calculation: (State)->[VarValue] = {_ in return [VarValue]()}
    func calculate(from input: State) {
        value = calculation(input)
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

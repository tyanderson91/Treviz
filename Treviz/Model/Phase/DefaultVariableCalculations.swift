//
//  DefaultCalculatedVariables.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/6/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

func defaultMultiStateCalc(_ singleCalc: @escaping (inout StateDictSingle)->VarValue)-> ((inout StateDictArray)->[VarValue]) {
    let calc: (inout StateDictArray)->[VarValue] = { (stateIn: inout StateDictArray) in
        let len = stateIn.stateLen
        var newArray = Array(repeating: VarValue(0), count: len)
        for i in 0...stateIn.stateLen - 1 {
            var curState = stateIn[i]
            newArray[i] = singleCalc(&curState)
        }
        return newArray
    }
    return calc
}

extension TZPhase {
    
func loadVarCalculations(){ //TODO: make dependent on physics type
    //MARK: Single-state vars (Variables that can be calculated only with the value of other state variables at that single instance in time)
    var calcs = varCalculationsSingle
    var mcalcs = varCalculationsMultiple
    
    calcs["v"] = { (_ s: inout StateDictSingle) -> VarValue in
        let x = s["dx"]!
        let y = s["dy"]!
        let z = s["dz"]!
        return (x**2 + y**2 + z**2)**0.5
    }
    self.varCalculationsSingle = calcs
    
    
    //MARK: Multi-state vars (Variables that can need multiple points along the trajectory to be calculated
    mcalcs["a"] = { (_ s: inout StateDictArray) -> [VarValue] in
        let len = s.stateLen
        var newArray = Array(repeating: VarValue(0), count: len)
        guard let v = s["v"] else { return [] }
        guard let t = s["t"] else { return [] }
        for i in 1...s.stateLen - 1 {
            newArray[i] = (v[i] - v[i-1])/(t[i]-t[i-1])
        }
        newArray[0] = newArray[1]
        return newArray
    }
    
    for varid in self.varCalculationsSingle.keys {
        if !mcalcs.keys.contains(varid) {
            //mcalcs[varid] = defaultMultiStateCalc(varid)
            let singleCalc = varCalculationsSingle[varid]
            mcalcs[varid] = defaultMultiStateCalc(singleCalc!)
        }
    }
    
    varCalculationsMultiple = mcalcs
}
}

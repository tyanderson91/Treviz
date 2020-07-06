//
//  PhaseYaml.swift
//  Treviz
//
//  This file contains an extension to Phase that handles all operations with Yaml file reading and writing

//  Created by Tyler Anderson on 6/30/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension TZPhase {

    convenience init(yamlDict: [String: Any], analysis: Analysis) {
        if let phasename = yamlDict["Name"] as? String {
            self.init(id: phasename)
        } else { self.init(id: "default") }
        self.analysis = analysis
        
        loadVars(from: "InitVars")
        if let inputList = yamlDict["Initial Variables"] as? [String: Any] {
            for (curVarID, curVarVal) in inputList {
                guard let thisVar = self.varList.first(where: { $0.id == curVarID}) else {
                    analysis.logMessage("Could not set value for unknown variable '\(curVarID)'")
                    continue
                }
                if let intVal = curVarVal as? Int { thisVar.value = [VarValue(intVal)] }
                else if let floatval = curVarVal as? VarValue { thisVar.value = [floatval] }
            }
        }
        varList = varList.compactMap({$0.copyToPhase(phaseid: self.id)})
        
        if let terminalConditionName = yamlDict["Terminal Condition"] as? String {
            if let cond = analysis.conditions.first(where: { $0.name == terminalConditionName }) {
                terminalCondition = cond
            }
        }
    }
    
    
}

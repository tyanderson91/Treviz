//
//  TZPhase.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/26/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

enum PropagatorType: String {
    case explicit
    case rungeKutta4
}


enum ReturnCode: Int {
    case NotStarted = 0
    case Success = 1
    case Failure = 2
}
/**
 A TZPhase is a defined section of an Analysis. It contains an initial condition (or delta-initial condition from the previous phase), a terminal condition, and all vehicle and runtime settings required to propagate
 */
class TZPhase: Codable {
    var id: String
    var vehicle : Vehicle!
    var propagatorType : PropagatorType = .explicit
    var defaultTimestep : VarValue = 0.1
    var inputSettings : [Parameter] = []
    var initState: StateDictSingle { return StateDictSingle(from: varList, at: 0) }
    weak var terminalCondition : Condition!
    var traj: StateDictArray!
    var requiredVarIDs: [VariableID] = []
    var requestedVarIDs: [VariableID] = ["v", "a"]
    var progressReporter: AnalysisProgressReporter?
    var isRunning = false
    var returnCode : ReturnCode = .NotStarted
    var runMode : AnalysisRunMode = .parallel
    var analysis: Analysis!
    var varList: [Variable]!
    var varCalculationsSingle = Dictionary<VariableID,(inout StateDictSingle)->VarValue>()
    var varCalculationsMultiple = Dictionary<VariableID,(inout StateDictArray)->[VarValue]>()
    var initStateGroups : InitStateHeader!

    init(id idIn: String){
        id = idIn
        setupConstants()
    }
    
    // MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case id
        case propagatorType
        case inputSettings
        case vehicleID
        case terminalCondition
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        propagatorType = try PropagatorType(rawValue: container.decode(String.self, forKey: .propagatorType))!
        setupConstants()
        
        let tempInputSettings = try container.decode(Array<Variable>.self, forKey: .inputSettings)
        tempInputSettings.forEach( { (thisParam: Parameter) in
            if let thisVar = thisParam as? Variable {
                let thisVar = thisVar.copyToPhase(phaseid: self.id)
                let matchingVar = self.varList.first(where: {$0.id == thisVar.id})
                matchingVar?[0] = thisVar.value[0]
            }
        } )
        inputSettings = varList // TODO: When more settings are introduced, expand this
        /*
        do {
            let terminalConditionName = try container.decode(String.self, forKey: .terminalCondition)
            terminalCondition = analysis.conditions.first { $0.name == terminalConditionName }
        }*/
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(propagatorType.rawValue, forKey: .propagatorType)
        try container.encode(terminalCondition.name, forKey: .terminalCondition)
        if let nonzerovars = (varList)?.filter({$0.value[0] != 0 || $0.isParam}) {
            let baseVars = nonzerovars.compactMap({$0.stripPhase()})
            try container.encode(baseVars, forKey: .inputSettings)
        }
        //try container.encode(vehicle.id, forKey: .vehicleID)
    }
    
    // MARK: Yaml initiation
    convenience init(yamlDict: [String: Any], analysis: Analysis) {
        if let phasename = yamlDict["Name"] as? String {
            self.init(id: phasename)
        } else { self.init(id: "default") }
        self.analysis = analysis
        
        setupConstants()
        if let inputList = yamlDict["Initial Variables"] as? [String: Any] {
            for (curVarID, curVarVal) in inputList {
                guard let thisVar = self.varList.first(where: { $0.id == curVarID.atPhase(self.id)}
                    ) else {
                    analysis.logMessage("Could not set value for unknown variable '\(curVarID)'")
                    continue
                }
                if let startVal = VarValue(numeric: curVarVal) { thisVar.value = [startVal] }
            }
        }
        inputSettings = varList // TODO: When more settings are introduced, expand this
        
        if let terminalConditionName = yamlDict["Terminal Condition"] as? String {
            if let cond = analysis.conditions.first(where: { $0.name == terminalConditionName }) {
                terminalCondition = cond
            }
        }
    }
}

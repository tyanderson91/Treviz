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

extension Variable {
    func copyToPhase(phaseid: String)->Variable {
        var newID: VariableID = ""
        if !self.id.contains(".") {
            newID = phaseid + "." + self.id
        } else {
            newID = phaseid + "." + self.id.baseVarID()
        }
        let newVar = Variable(newID, named: name, symbol: symbol, units: units)
        newVar.value = value
        return newVar
    }
    func stripPhase()->Variable {
        var newID: VariableID = ""
        if self.id.contains(".") {
            newID = self.id.baseVarID()
        } else {
            newID = self.id
        }
        let newVar = Variable(newID, named: name, symbol: symbol, units: units)
        newVar.value = value
        return newVar
    }
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
    var initState: StateDictSingle { return traj[0] }
    weak var terminalCondition : Condition!
    var traj: State!
    var requiredVarIDs: [VariableID] = []
    var requestedVarIDs: [VariableID] = []
    var progressReporter: AnalysisProgressReporter?
    var isRunning = false
    var returnCode : ReturnCode = .NotStarted
    var analysis: Analysis!
    var varList: [Variable]!
    var initStateGroups : InitStateHeader!

    init(id idIn: String){
        id = idIn
        setVars(physicsModel: "") // TODO: Replace with actual physics-based lookup
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
        let tempInputSettings = try container.decode(Array<Variable>.self, forKey: .inputSettings)
        inputSettings = tempInputSettings.compactMap({$0.copyToPhase(phaseid: self.id)})
        setupConstants()
        do {
            let terminalConditionName = try container.decode(String.self, forKey: .terminalCondition)
            terminalCondition = analysis.conditions.first { $0.name == terminalConditionName }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(propagatorType.rawValue, forKey: .propagatorType)
        try container.encode(terminalCondition.name, forKey: .terminalCondition)
        let nonzerovars = (inputSettings as? [Variable])?.filter({$0.value[0] != 0 || $0.isParam})
        try container.encode(nonzerovars, forKey: .inputSettings)
        try container.encode(vehicle.id, forKey: .vehicleID)
    }
}

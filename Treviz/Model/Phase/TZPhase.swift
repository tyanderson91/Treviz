//
//  TZPhase.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/26/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

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
    var inputSettings : [Parameter] = []
    let runSettings : TZRunSettings
    var initState: StateDictSingle { return StateDictSingle(from: varList, at: 0) }
    weak var terminalCondition : Condition!
    var traj: StateDictArray!
    var requiredVarIDs: [ParamID] = []
    var requestedVarIDs: [ParamID] = ["v", "a"]
    var progressReporter: AnalysisProgressReporter?
    var isRunning = false
    var returnCode : ReturnCode = .NotStarted
    var runMode : AnalysisRunMode = .parallel
    var analysis: Analysis!
    var parentRun: TZRun!
    var varList: [Variable]!
    var varCalculationsSingle = Dictionary<ParamID,(inout StateDictSingle)->VarValue>()
    var varCalculationsMultiple = Dictionary<ParamID,(inout StateDictArray)->[VarValue]>()
    var initStateGroups : InitStateHeader!
    var allParams: [Parameter] = []
    let physicsSettings: PhysicsSettings
    //var simpleIO: Bool = true
    //var physicsModelParam = EnumGroupParam(id: "physicsModel", name: "Physics Model", enumType: PhysicsModel.self, value: PhysicsModel.flat2d, options: PhysicsModel.allPhysicsModels)
    //var usesVehicleInertiaParam = BoolParam(id: "usesMOI", name: "Use MOI", value: false)
    
    init(id idIn: String){
        id = idIn
        runSettings = TZRunSettings()
        physicsSettings = PhysicsSettings()
        setupConstants()
        gatherParams()
    }
    init(id idIn: String, runSettings runSettingsIn: TZRunSettings, physicsSettingsIn: PhysicsSettings){
        id = idIn
        runSettings = runSettingsIn
        physicsSettings = physicsSettingsIn
        setupConstants()
        gatherParams()
    }
    
    // MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case id
        case inputSettings = "Initial Variables"
        case vehicle
        case terminalCondition = "Terminal Condition"
        case runSettings = "Run Settings"
        case physicsSettings = "Physics Settings"
    }

    required init(from decoder: Decoder) throws {
        let simpleIO : Bool = decoder.userInfo[.simpleIOKey] as? Bool ?? false
        let deepCopy : Bool = decoder.userInfo[.deepCopyKey] as? Bool ?? false

        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? "default"
        
        if container.contains(.runSettings) {
            runSettings = try container.decode(TZRunSettings.self, forKey: .runSettings)
        } else { runSettings = TZRunSettings() }
        
        if container.contains(.physicsSettings) {
            physicsSettings = try container.decode(PhysicsSettings.self, forKey: .physicsSettings)
        } else { physicsSettings = PhysicsSettings() }
        setupConstants()
        
        if simpleIO {
            let tempInputSettings = try container.decode([String: VarValue].self, forKey: .inputSettings)
            for (thisVarID, thisVarVal) in tempInputSettings {
                if let thisVar = self.varList.first(where: {thisVarID == $0.id}) {
                    thisVar.value = [thisVarVal]
                }
            }
        } else {
            let tempInputSettings = try container.decode(Array<Variable>.self, forKey: .inputSettings)
            tempInputSettings.forEach( { (thisParam: Parameter) in
                if let thisVar = thisParam as? Variable {
                    let thisVar = thisVar.copyToPhase(phaseid: self.id)
                    let matchingVar = self.varList.first(where: {$0.id == thisVar.id})
                    matchingVar?[0] = thisVar.value[0]
                }
            } )
            
            if deepCopy {
                if container.contains(.terminalCondition) { terminalCondition = try container.decode(Condition.self, forKey: .terminalCondition) }
                vehicle = try container.decode(Vehicle.self, forKey: .vehicle)
            }
        }
        
        inputSettings = varList // TODO: When more settings are introduced, expand this
        gatherParams()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let simpleIO : Bool = encoder.userInfo[.simpleIOKey] as? Bool ?? false
        let deepCopy : Bool = encoder.userInfo[.deepCopyKey] as? Bool ?? false
        
        let nonzerovars = (varList)?.filter({
            guard $0.value.count > 0 else { return false }
            return ($0.value[0] != 0 || $0.isParam)
        }) ?? []
        let baseVars = nonzerovars.compactMap({$0.copyWithoutPhase()})
        if simpleIO {
            var initVarsDict = [String: VarValue]()
            for thisVar in baseVars { initVarsDict[thisVar.id] = thisVar.value[0] }
            try container.encode(initVarsDict, forKey: .inputSettings)
        } else {
            try container.encode(id, forKey: .id)
            try container.encode(baseVars, forKey: .inputSettings)
        }
        if terminalCondition != nil {
            try container.encode(terminalCondition.name, forKey: .terminalCondition)
        }
        
        if deepCopy {
            if terminalCondition != nil { try container.encode(terminalCondition, forKey: .terminalCondition) }
            try container.encode(vehicle, forKey: .vehicle)
        }
        try container.encode(runSettings, forKey: .runSettings)
        try container.encode(physicsSettings, forKey: .physicsSettings)
        //try container.encode(vehicle.id, forKey: .vehicleID)
    }
}


extension TZPhase {
    func gatherParams() {
        allParams = []
        varList.moveToPhase(self.id)
        allParams.append(contentsOf: varList)
        
        var runSetParams = runSettings.allParams as Array<Parameter>
        for i in runSetParams.indices { runSetParams[i].moveToPhase(self.id) }
        allParams.append(contentsOf: runSetParams)
        
        var physicsParams = physicsSettings.allParams
        for i in physicsParams.indices { physicsParams[i].moveToPhase(self.id) }
        allParams.append(contentsOf: physicsParams)
    }
}

//
//  TZRunSettings.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/6/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

enum PropagatorType: String {
    case explicit
    case rungeKutta4
}

enum TZRunSettingError: Error, LocalizedError {
case minMaxError
case negativeNumberError

public var errorDescription: String? {
    switch self {
        case .minMaxError:
            return NSLocalizedString("Maximum timestep must be greater than minimum", comment: "")
        case .negativeNumberError:
            return NSLocalizedString("Negative timesteps are not allowed", comment: "")
        }
    }
}

class TZRunSettings: Codable {
    var runMode: AnalysisRunMode!// Set automatically by the parent analysis
    var propagatorType: PropagatorType = .explicit
    var useAdaptiveTimestep = BoolParam(id: "adaptivedt", name: "Adaptive Timestep", value: false)
    private(set) var defaultTimestep = NumberParam(id: "dt", name: "Timestep", value: 0.1)
    private(set) var minTimestep = NumberParam(id: "dtmin", name: "Min Timestep", value: 0.0)
    private(set) var maxTimestep = NumberParam(id: "dtmax", name: "Max Timestep", value: 100)
    var allParams: [Parameter] { return [self.defaultTimestep, self.minTimestep, self.maxTimestep]}

    init() {
        runMode = .parallel
    }
    
    //MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case propagatorType
        case defaultTimestep
        case useAdaptiveTimestep
        case minTimestep
        case maxTimestep
    }
    func setMinTimeStep(_ minStep: VarValue) throws {
        guard minStep >= 0.0 else { throw TZRunSettingError.negativeNumberError }
        guard minStep < maxTimestep.value else { throw TZRunSettingError.minMaxError }
        minTimestep.value = minStep
    }
    func setMaxTimeStep(_ maxStep: VarValue) throws {
        guard maxStep > 0.0 else { throw TZRunSettingError.negativeNumberError }
        guard maxStep > minTimestep.value else { throw TZRunSettingError.minMaxError }
        maxTimestep.value = maxStep
    }
    func setDefaultTimeStep(_ defaultStep: VarValue) throws {
        guard defaultStep > 0.0 else { throw TZRunSettingError.negativeNumberError }
        defaultTimestep.value = defaultStep
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        propagatorType = try PropagatorType(rawValue: container.decode(String.self, forKey: .propagatorType))!
        defaultTimestep.value = try container.decode(VarValue.self, forKey: .defaultTimestep)
        let adaptiveTimestep = try container.decode(Bool.self, forKey: .useAdaptiveTimestep)
        useAdaptiveTimestep.value = adaptiveTimestep
        if adaptiveTimestep {
            let minTimestepIn = try container.decode(VarValue.self, forKey: .minTimestep)
            let maxTimestepIn = try container.decode(VarValue.self, forKey: .maxTimestep)
            try setMaxTimeStep(maxTimestepIn)
            try setMinTimeStep(minTimestepIn)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(propagatorType.rawValue, forKey: .propagatorType)
        try container.encode(defaultTimestep.value, forKey: .defaultTimestep)
        try container.encode(useAdaptiveTimestep.value, forKey: .useAdaptiveTimestep)
        if useAdaptiveTimestep.value {
            try container.encode(minTimestep.value, forKey: .minTimestep)
            try container.encode(maxTimestep.value, forKey: .maxTimestep)
        }
    }

    //MARK: YAML init
    init(yamlDict: [String: Any]) throws {
        if let propagator = yamlDict["propagator"] as? String {
            propagatorType = PropagatorType(rawValue: propagator) ?? PropagatorType.explicit
        }
        if let adaptiveTimeStepIn = yamlDict["adaptive timestep"] as? Bool {
            useAdaptiveTimestep.value = adaptiveTimeStepIn
        }
        if let timestepIn = yamlDict["timestep"] as? VarValue {
            try setDefaultTimeStep(timestepIn)
        }
        if let minTimeStepIn = yamlDict["min timestep"] as? VarValue {
            try setMinTimeStep(minTimeStepIn)
        }
        if let maxTimeStepIn = yamlDict["max timestep"] as? VarValue {
            try setMaxTimeStep(maxTimeStepIn)
        }
    }
    
}

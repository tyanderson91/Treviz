//
//  TZRunSettings.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/6/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

/**Algorithm used for propagation of the state*/
enum PropagatorType: String, StringValue, CaseIterable {
    case explicit = "Explicit"
    case rungeKutta4 = "Runge-Kutta"
    
    init?(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
    var valuestr: String { return self.rawValue }
}

enum TZRunSettingError: Error, LocalizedError {
    case minMaxError
    case negativeNumberError
    case IOError

    public var errorDescription: String? {
        switch self {
            case .minMaxError:
                return NSLocalizedString("Maximum timestep must be greater than minimum", comment: "")
            case .negativeNumberError:
                return NSLocalizedString("Negative timesteps are not allowed", comment: "")
            case .IOError:
                return NSLocalizedString("Error in run settings I/O", comment: "")
        }
    }
}

/**
 A collection of settings that control the simulation engine, such a how to treat timesteps
 */
class TZRunSettings: Codable {
    var runMode: AnalysisRunMode!// Set automatically by the parent analysis
    var propagatorType: EnumGroupParam = EnumGroupParam(id: "propagatorType", name: "Propagator", enumType: PropagatorType.self, value: PropagatorType.explicit, options: PropagatorType.allCases)
    var useAdaptiveTimestep = BoolParam(id: "adaptivedt", name: "Adaptive Timestep", value: false)
    private(set) var defaultTimestep = NumberParam(id: "dt", name: "Timestep", value: 0.1)
    private(set) var minTimestep = NumberParam(id: "dtmin", name: "Min Timestep", value: 0.0)
    private(set) var maxTimestep = NumberParam(id: "dtmax", name: "Max Timestep", value: 100)
    var allParams: [Parameter] { return [self.useAdaptiveTimestep, self.defaultTimestep, self.minTimestep, self.maxTimestep]}

    init() {
        runMode = .parallel
    }
    
    //MARK: Setters
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
    
    //MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case propagator
        case timestep
        case useAdaptiveTimestep
        case minTimestep
        case maxTimestep
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.propagator) {
            let propagatorName = try container.decode(String.self, forKey: .propagator)
            propagatorType.setValue(to: propagatorName)
        }
        defaultTimestep.value = try container.decode(VarValue.self, forKey: .timestep)
        let adaptiveTimestep = (try? container.decode(Bool.self, forKey: .useAdaptiveTimestep)) ?? false
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
        try container.encode(propagatorType.stringValue, forKey: .propagator)
        try container.encode(defaultTimestep.value, forKey: .timestep)
        try container.encode(useAdaptiveTimestep.value, forKey: .useAdaptiveTimestep)
        if useAdaptiveTimestep.value {
            try container.encode(minTimestep.value, forKey: .minTimestep)
            try container.encode(maxTimestep.value, forKey: .maxTimestep)
        }
    }    
}

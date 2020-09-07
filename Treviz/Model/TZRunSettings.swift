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

class TZRunSettings: Codable {
    var runMode: AnalysisRunMode!// Set automatically by the parent analysis
    var propagatorType: PropagatorType = .explicit
    var defaultTimestep: VarValue = 0.1
    var useAdaptiveTimestep: Bool = false
    var minTimestep: VarValue = 0
    var maxTimestep: VarValue = 100
    
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        propagatorType = try PropagatorType(rawValue: container.decode(String.self, forKey: .propagatorType))!
        defaultTimestep = try container.decode(VarValue.self, forKey: .defaultTimestep)
        let adaptiveTimestep = try container.decode(Bool.self, forKey: .useAdaptiveTimestep)
        useAdaptiveTimestep = adaptiveTimestep
        if adaptiveTimestep {
            minTimestep = try container.decode(VarValue.self, forKey: .minTimestep)
            maxTimestep = try container.decode(VarValue.self, forKey: .maxTimestep)
        }
    }
    
    //MARK: YAML init
    init(yamlDict: [String: Any]) {
        if let propagator = yamlDict["propagator"] as? String {
            propagatorType = PropagatorType(rawValue: propagator) ?? PropagatorType.explicit
        }
        if let adaptiveTimeStepIn = yamlDict["adaptive timestep"] as? Bool {
            useAdaptiveTimestep = adaptiveTimeStepIn
        }
        if let timestepIn = yamlDict["timestep"] as? VarValue {
            defaultTimestep = timestepIn
        }
        if let minTimeStepIn = yamlDict["min timestep"] as? VarValue {
            minTimestep = minTimeStepIn
        }
        if let maxTimeStepIn = yamlDict["max timestep"] as? VarValue {
            maxTimestep = maxTimeStepIn
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(propagatorType.rawValue, forKey: .propagatorType)
        try container.encode(defaultTimestep, forKey: .defaultTimestep)
        try container.encode(useAdaptiveTimestep, forKey: .useAdaptiveTimestep)
        if useAdaptiveTimestep {
            try container.encode(minTimestep, forKey: .minTimestep)
            try container.encode(maxTimestep, forKey: .maxTimestep)
        }
    }

}

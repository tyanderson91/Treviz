//
//  PhysicsModel.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/12/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation
import Cocoa

struct PhysicsModel {
    
    var valuestr: String
    let id: String
    let icon: NSImage?
    
    init(id: String, name: String) {
        self.id = id
        self.valuestr = name
        if let fullImage = NSImage(named: id) {
            self.icon = fullImage
        } else { self.icon = nil }
    }

    static let flat2d = PhysicsModel(id: "flat2d", name: "Flat Surface, planar")
    static let flat3d = PhysicsModel(id: "flat3d", name: "Flat Surface, 3D")
    static let round2dSingle = PhysicsModel(id: "round2dSingle", name: "Round Body, planar")
    static let round3dSingle = PhysicsModel(id: "round3dSingle", name: "Round Body, 3D")
    static let round2dMulti = PhysicsModel(id: "round2dMulti", name: "Multi-Body, planar")
    static let round3dMulti = PhysicsModel(id: "round3dMulti", name: "Multi-Body, 3D")
    
    static let allPhysicsModels: [PhysicsModel] = [.flat2d, .flat3d, .round2dSingle, .round3dSingle, .round2dMulti, .round3dMulti]
}

class PhysicsSettings: Codable {
    var physicsModelParam = EnumGroupParam(id: "physicsModel", name: "Physics Model", enumType: PhysicsModel.self, value: PhysicsModel.flat2d, options: PhysicsModel.allPhysicsModels)
    var vehiclePointMassParam = BoolParam(id: "vehiclePointMass", name: "Treat Vehicle as Point Mass", value: true)
    var centralBodyParam = EnumGroupParam(id: "centralBody", name: "Central Body", enumType: CelestialBody.self, value: "Earth", options: CelestialBody.allBodies)
    var allParams: [Parameter] { return [physicsModelParam, vehiclePointMassParam, centralBodyParam] }
    
    //MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case physicsModel
        case vehiclePointMass
        //case centralBody
    }
    init(){}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let physicsModelName = try? container.decode(String.self, forKey: .physicsModel) {
            physicsModelParam.setValue(to: physicsModelName)
        }
        if let usePointMass = try? container.decode(Bool.self, forKey: .vehiclePointMass) {
            vehiclePointMassParam.value = usePointMass
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(physicsModelParam.value.valuestr, forKey: .physicsModel)
        try container.encode(vehiclePointMassParam.value, forKey: .vehiclePointMass)
        //try container.encode(physicsModelParam.value, forKey: .physicsModel)
    }
}

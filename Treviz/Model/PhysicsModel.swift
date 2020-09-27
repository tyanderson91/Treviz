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

/*
class PhysicsModelParam: Parameter {
    var curModel: PhysicsModel = .flat2d
    var id = "physicsModel"
    var name: String { return curModel.valuestr }
    var isParam = false
    static var paramConstructor: (_ param: Parameter)->RunVariant? = EnumGroupRunVariant.init(param: )
}*/

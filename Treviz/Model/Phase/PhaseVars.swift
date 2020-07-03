//
//  PhaseVars.swift
//  Treviz
//
//  This extension implements functions for populating the required vars of a phase based on the physics model
//
//  Created by Tyler Anderson on 7/1/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa


extension TZPhase {

    func setVars(physicsModel: String) {
        requiredVarIDs = ["t", "x", "y", "z", "dx", "dy", "dz", "mtot"] 
    }
    
}

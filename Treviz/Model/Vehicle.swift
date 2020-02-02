//
//  Vehicle.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class Vehicle: NSObject {
    var mass : Double = 0
    override init() {
        mass = 10
        super.init()
    }
}

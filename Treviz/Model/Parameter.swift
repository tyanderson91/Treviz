//
//  Parameter.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

protocol Parameter {
    var id: VariableID {get}
    var name: VariableID {get}
    var isParam : Bool {get set}
}

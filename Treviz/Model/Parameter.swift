//
//  Parameter.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 This protocol is adopted by every class used as a input parameter or plotting variable. The standard Variable class adopts this protocol for all numerical variable, but it can also be adopted by categorical parameters, such as integrator type, or physics model
 */
protocol Parameter: Codable {
    //associatedtype VarType
    
    var id: VariableID {get}
    var name: String {get}
    var isParam : Bool {get set} // Defines whether the parameter is used as a 'parameter' in the current analysis; that is, whether it is varied as an input across multiple analysis runs
    //var value: VarType {get set}
}

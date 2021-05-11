//
//  StringValueProtocol.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/26/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

/**
 StringValue is a protocol adopted by the underlying value of Parameters. This allows values to be set by a string, which allows setting a wide variety of Parameters and Run Variants through a text-based interface
 */
protocol StringValue {
    var valuestr: String {get}
    init?(stringLiteral: String)
}

extension String: StringValue {
    var valuestr: String { return self }
    init(from strval: String) { self = strval.valuestr }
}

extension VarValue: StringValue {
    var valuestr: String { return String(format: "%g", self)}
    init?(stringLiteral: String) {
        self.init(stringLiteral)
    }
}

extension Int: StringValue {
    var valuestr: String { return String(format: "%i", self)}
    init?(stringLiteral: String) {
        self.init(stringLiteral)
    }
}

extension Bool: StringValue {
    var valuestr: String {
        if self == true {
            return "true"
        } else { return "false" }
    }
    init?(stringLiteral: String) {
        switch stringLiteral {
        case "True","true","On":
            self.init(true)
        case "False","false","Off":
            self.init(false)
        default:
            return nil
        }
    }
}

extension PhysicsModel: StringValue {
    init?(stringLiteral: String) {
        if let match = PhysicsModel.allPhysicsModels.first(where: {$0.valuestr == stringLiteral}) {
            self = match
        } else { return nil }
    }
}

//
//  StringValueProtocol.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/26/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

protocol StringValue {
    var valuestr: String {get}
    init?(stringLiteral: String)
}

extension String: StringValue {
    var valuestr: String { return self }
    init(from strval: StringValue) { self = strval.valuestr }
}

extension VarValue: StringValue {
    var valuestr: String { return String(format: "%g", self)}
    init?(stringLiteral: String) {
        self.init(stringLiteral)
    }
}

extension PhysicsModel: StringValue {
    init?(stringLiteral: String) {
        if let match = PhysicsModel.allPhysicsModels.first(where: {$0.valuestr == stringLiteral}) {
            self = match
        } else { return nil }
    }
}

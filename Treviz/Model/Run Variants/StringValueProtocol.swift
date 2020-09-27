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
    init?(rawValue: String)
}

extension String: StringValue {
    var valuestr: String { return self }
    init(from strval: StringValue) { self = strval.valuestr }
    init?(rawValue: String){
        self = rawValue
    }
}

extension VarValue: StringValue {
    var valuestr: String { return String(format: "%g", self)}
    init?(rawValue: String) {
        self.init(rawValue)
    }
}

extension PhysicsModel: StringValue {
    init?(rawValue: String) {
        if let match = PhysicsModel.allPhysicsModels.first(where: {$0.valuestr == rawValue}) {
            self = match
        } else { return nil }
    }
}



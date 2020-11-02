//
//  ParameterID.swift
//  Treviz
//
//  Created by Tyler Anderson on 11/1/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

typealias ParamID = String

struct StringCodingKey: CodingKey {
    init?(stringValue: String) {
        varID = stringValue
    }
    var stringValue: String { return self.varID }
    var intValue: Int?
    
    init?(intValue: Int) {
        return nil
    }
    var varID : ParamID
}

extension ParamID {
    /**
     Return the part of the varID that describes its function (i.e. t, x, y) by removing phase and vehicle information
     */
    func baseVarID()->ParamID {
        let strparts = self.split(separator: ".")
        return String(strparts[strparts.count-1])
    }
    func phasename()->String {
        let strparts = self.split(separator: ".")
        return strparts.count >= 2 ? String(strparts[0]) : ""
    }
    func atPhase(_ phase: String)->String {
        return phase + "." + self
    }
}

/*
struct VariableID: CodingKey, Equatable, StringValue, Codable {
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        stringValue = ""
    }
    
    var valuestr: String { return stringValue}
    
    init?(stringLiteral: String) {
        self.stringValue = stringLiteral
    }
}*/

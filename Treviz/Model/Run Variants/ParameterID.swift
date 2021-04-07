//
//  ParameterID.swift
//  Treviz
//
//  Created by Tyler Anderson on 11/1/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

/**
 ParamID is the identifier for a parameter. Each parameter should use a unique ID. IDs should be short, preferable a single lowercase word
 */
enum ParamIDError: Error, LocalizedError {
    case UnknownParamID(_ idIn: String)
    public var errorDescription: String? {
        switch self {
        case let .UnknownParamID(idIn):
            return "unknown parameter id '\(idIn)'"
        }
    }
}

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
    /**Return the part of the varID that describes its function (i.e. t, x, y) by removing phase and vehicle information*/
    func baseVarID()->ParamID {
        let strparts = self.split(separator: ".")
        return String(strparts[strparts.count-1])
    }
    /**Extract the phase name from the beginning of the paramID, if it exists*/
    func phasename()->String {
        let strparts = self.split(separator: ".")
        return strparts.count >= 2 ? String(strparts[0]) : ""
    }
    /**Make a new paramID defined at a new phase*/
    func atPhase(_ phase: String)->String {
        return phase + "." + self.baseVarID()
    }
}

extension Parameter {
    mutating func moveToPhase(_ phaseid: String) {
        if !id.contains(".") {
            id = phaseid + "." + self.id
        } else {
            id = phaseid + "." + self.id.baseVarID()
        }
    }
    
    mutating func stripPhase() {
        if id.contains(".") {
            id = id.baseVarID()
        }
    }
}

extension Array where Element: Parameter {
    mutating func moveToPhase(_ phaseid: String) {
        for i in self.indices {
            var curParam = self[i]
            curParam.moveToPhase(phaseid)
        }
    }
}

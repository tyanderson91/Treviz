//
//  Variable.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/6/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import simd

typealias VarValue = Double
extension VarValue {
    init?(numeric input: Any){
        if input is Int { self.init(integerLiteral: Int64(input as! Int))}
        else if input is Double { self.init(exactly: input as! Double) }
        else if input is Float { self.init(exactly: input as! Float) }
        else { return nil }
    }
}

/**
Variable is a class that defines a single changeable numerical property of a vehicle, including name, unit information, and value. Used to display input state and output information
 */
class Variable : Parameter, Codable, Hashable {
    let id: ParamID
    let name: String
    let symbol: String!
    var units: String //TODO: Turn units into a separate type
    var value: [VarValue] = []
    var isValid: Bool = true
    var hasParams: Bool {return isParam}
    var isParam: Bool = false
    static let paramConstructor : (Parameter) -> RunVariant? = VariableRunVariant.init(param: )

    func setValue(to string: String) {
        if let varVal = VarValue(string){ value[0] = varVal }
    }
    static func ==(lhs: Variable, rhs: Variable) -> Bool {
        return lhs.id == rhs.id && lhs.units == rhs.units && lhs.value == rhs.value
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(units)
        hasher.combine(value)
    }
    init(_ idIn: ParamID, named nameIn:String = "", symbol symbolIn: String = "", units unitsIn: String = "", value: [VarValue] = []){
        id = idIn
        name = nameIn
        symbol = symbolIn
        units = unitsIn
    }
    
    // Subscripts to get value data
    subscript(index: Int)->VarValue?{
        get {
            if index >= 0 && index < value.count{
                return value[index]
            } else {return nil}
        }
        set (newVal) {
            if newVal != nil {value.insert(newVal!, at: index)}
        }
    }
    
    func copyToPhase(phaseid: String)->Variable {
        var newID: ParamID = ""
        if !self.id.contains(".") {
            newID = phaseid + "." + self.id
        } else {
            newID = phaseid + "." + self.id.baseVarID()
        }
        let newVar = Variable(newID, named: name, symbol: symbol, units: units)
        newVar.value = value
        return newVar
    }
    
    func stripPhase()->Variable {
        var newID: ParamID = ""
        if self.id.contains(".") {
            newID = self.id.baseVarID()
        } else {
            newID = self.id
        }
        let newVar = Variable(newID, named: name, symbol: symbol, units: units)
        newVar.value = value
        return newVar
    }
}

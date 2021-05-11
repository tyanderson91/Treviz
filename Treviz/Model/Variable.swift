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
    var id: ParamID
    let name: String
    let symbol: String!
    var units: Unit
    var value: [VarValue] = []
    var stringValue: String { return value[0].valuestr }

    var isValid: Bool = true
    var hasParams: Bool {return isParam}
    var isParam: Bool = false
    static let paramConstructor : (Parameter) -> RunVariant? = VariableRunVariant.init(param: )

    func setValue(to string: String) {
        if let varVal = VarValue(string){ value[0] = varVal }
    }
    func valueSetter(string: String) -> StringValue? {
        if let varVal = VarValue(string){ return varVal }
        else { return nil }
    }
    static func == (lhs: Variable, rhs: Variable) -> Bool {
        return lhs.id == rhs.id && lhs.units == rhs.units && lhs.value == rhs.value
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(units)
        hasher.combine(value)
    }
    init(_ idIn: ParamID, named nameIn:String, symbol symbolIn: String, units unitsIn: Unit, value valIn: [VarValue] = []){
        id = idIn
        name = nameIn
        symbol = symbolIn
        units = unitsIn
        value = valIn
    }
    convenience init(_ idIn: ParamID, named nameIn:String = "", symbol symbolIn: String = "", unitSymbol unitsIn: String = "", value: [VarValue] = []) {
        let unit = Unit.fromString(stringSymbol: unitsIn) ?? Unit(symbol: unitsIn)
        self.init(idIn, named: nameIn, symbol: symbolIn, units: unit, value: value)
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
    
    func copyWithoutPhase()->Variable {
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
    
    // Codable
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case units
        case value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        let unitsSymbol = try container.decode(String.self, forKey: .units)
        units = Unit.fromString(stringSymbol: unitsSymbol) ?? Unit(symbol: unitsSymbol)
        value = try container.decode([VarValue].self, forKey: .value)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(units.symbol, forKey: .units)
        try container.encode(value, forKey: .value)
    }
    
}

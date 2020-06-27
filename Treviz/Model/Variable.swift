//
//  Variable.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/6/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import simd

typealias VariableID = String
typealias VarValue = Float

/**
Variable is a class that defines a single changeable numerical property of a vehicle, including name, unit information, and value. Used to display input state and output information
 */
class Variable : Parameter, Codable, Hashable {
    
    let id: VariableID
    let name: String
    let symbol: String!
    var units: String //TODO: Turn units into a separate type
    var value: [VarValue] = []
    var isValid: Bool = true
    var hasParams: Bool {return isParam}
    var isParam: Bool = false

    static func ==(lhs: Variable, rhs: Variable) -> Bool {
        return lhs.id == rhs.id && lhs.units == rhs.units && lhs.value == rhs.value
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(units)
        hasher.combine(value)
    }
    init(_ idIn: VariableID, named nameIn:String = "", symbol symbolIn: String = "", units unitsIn: String = ""){
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
    
    subscript(condition: Condition)->[VarValue]?{
        var output : [VarValue] = []
        let conditionIndices = condition.meetsConditionIndex
        guard self.value.count == conditionIndices.count else {return nil}
        for thisIndex in conditionIndices {
            output.append(self.value[thisIndex])
        }
        return output
    }
}

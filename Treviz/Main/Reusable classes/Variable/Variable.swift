//
//  Variable.swift
//  Treviz
//
//  Variable is a class that defines a single changeable numerical property of a vehicle, including name, unit information, and value
//  Used to display input state and output information
//
//  Created by Tyler Anderson on 3/6/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
//import Foundation
import simd

typealias VariableID = String

enum VarValueType : String {
    case double = "double"
    case vector = "vector"
}

class Variable : NSObject, Parameter, InitStateCheck, NSCopying {
    
    let id: VariableID
    let name: String
    let symbol: String!
    var units: String //TODO: Turn units into a separate type
    var value: [Double] = []
    
    var isValid: Bool = true
    var hasParams: Bool {return isParam}
    var children: [InitStateCheck] { return [] }
    
    var isParam: Bool = false
    
    init(_ idIn: VariableID, named nameIn:String = "", symbol symbolIn: String = "", units unitsIn: String = ""){
        id = idIn
        name = nameIn
        symbol = symbolIn
        units = unitsIn
        super.init()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newVar = Variable(id, named: name, symbol: symbol, units: units)
        newVar.value = self.value
        newVar.isValid = self.isValid
        newVar.isParam = self.isParam
        return newVar
    }
    func copyAtIndex(_ index: Int) -> Variable?{
        guard index < self.value.count else {return nil}
        let newVar = Variable(id, named: name, symbol: symbol, units: units)
        newVar.value = [self[index]!]
        newVar.isValid = self.isValid
        newVar.isParam = self.isParam
        return newVar
    }
    
    // Subscripts to get value data
    subscript(index: Int)->Double?{
        get {
            if index >= 0 && index < value.count{
                return value[index]
            } else {return nil}
        }
        set (newVal) {
            if newVal != nil {value.insert(newVal!, at: index)}
        }
    }
    
    subscript(condition: Condition)->[Double]?{
        var output : [Double] = []
        let conditionIndices = condition.meetsConditionIndex
        guard self.value.count == conditionIndices.count else {return nil}
        for thisIndex in conditionIndices {
            output.append(self.value[thisIndex])
        }
        return output
    }
}

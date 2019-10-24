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

class Variable : NSObject, Parameter, InitStateCheck {
    // TODO: maybe this should be a struct?
    //static var allIdentifiers : [VariableID] = []
    let id: VariableID
    let name: String
    let symbol: String!
    var units: String //TODO: Turn units into a separate type
    var value: [Double] = []
    
    var isValid: Bool = true
    var hasParams: Bool {return isParam}
    var children: [InitStateCheck] = []
    
    var isParam: Bool = false
    //var statePosition : Int //Position of the variable in the state vector
    
    init(_ id:VariableID, named name:String = "", symbol:String = ""){
        //if Variable.allIdentifiers.contains(id){
         //   print("State item with id \(id) already exists!")//TODO: make error
        //} else {
        //    Variable.allIdentifiers.append(id)
        //}
        self.id = id
        self.name = name
        self.symbol = symbol
        self.units = ""
        
        super.init()
        //self.statePosition = -1
    }
    
    convenience init(_ id: VariableID, named inputName:String = "", symbol inputSymbol:String = "", units inputUnits:String = ""){
        self.init(id,named: inputName, symbol: inputSymbol)
        units = inputUnits
    }
    
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
    // Sequence overrides
}

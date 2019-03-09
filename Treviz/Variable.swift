//
//  Variable.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/6/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
typealias VariableID = String

class Variable : NSObject{
    static var allIdentifiers : [VariableID] = []
    
    let id : VariableID
    let name : String
    let symbol : String
    var units : String //TODO: Turn units into a separate type
    var isParam = false
    var value : Double = 0 //TODO: all different types
    var statePosition : Int //Position of the variable in the state vector
    
    init(_ id:VariableID, named name:String = "", symbol:String = "", units:String = "", value: Double = 0){
        if id == ""{
            //return
        }
        else if Variable.allIdentifiers.contains(id){
            print("State item with id \(id) already exists!")//TODO: make error
        } else {
            Variable.allIdentifiers.append(id)
        }
        self.id = id
        self.name = name
        self.symbol = symbol
        self.value = value
        self.units = units
        self.statePosition = -1
        
    }
}

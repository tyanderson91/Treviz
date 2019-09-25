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
typealias VariableID = String

class Variable : NSObject{
    //static var allIdentifiers : [VariableID] = []
    
    let id : VariableID
    let name : String
    let symbol : String
    var units : String //TODO: Turn units into a separate type
    var value : Double? //TODO: all different types
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
        self.value = nil
        //self.statePosition = -1
    }
    
    convenience init(_ id: VariableID, named inputName:String = "", symbol inputSymbol:String = "", units inputUnits:String = "", value inputValue:Double?){
        self.init(id,named: inputName, symbol: inputSymbol)
        if inputValue != nil {
            value = inputValue
        }
        units = inputUnits
    }
    
    static func initVars(filename : String) -> [Variable] {
        //Method initializes a list of variables for input state from a file
        //TODO: Move this to InputState or somewhere more apppropriate
        //NSMutableArray<AnalysisInput *> *inputs= [NSMutableArray array];
        guard let inputList = NSArray.init(contentsOfFile: filename)
            else {return []}//return empty if filename not found
        var initVars : [Variable] = []
        for thisVar in inputList {
            let dict = thisVar as! NSDictionary //TODO: error check the type, return [] if not a dictionary
            let newVar = Variable(dict["id"] as! VariableID, named: dict["name"] as! String,
                                  symbol: dict["symbol"] as! String, units: dict["units"] as! String, value: dict["value"] as? Double)
            
            //Below code is meant to initialize as an example
            
            if newVar.id == "dx" || newVar.id == "dy" || newVar.id == "mtot" {
                newVar.value = 10
            }
 
            initVars.append(newVar)
        }
        return initVars
    }
    
    static func getVariable(_ id : String, inputList: [Variable])->Variable?{
        for thisVar in inputList {//TODO: turn all variable input into dictionary
            if thisVar.id == id {return thisVar}
        }
        return nil
    }
    
    static func getVar(fromName name : String, inputList: [Variable])->Variable?{//TODO : determine whether both of these are needed
        for thisVar in inputList {//TODO: turn all variable input into dictionary
            if thisVar.name == name {return thisVar}
        }
        return nil
    }
}

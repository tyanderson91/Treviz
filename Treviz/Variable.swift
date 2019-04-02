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
    var value : Double? //TODO: all different types
    var statePosition : Int //Position of the variable in the state vector
    
    init(_ id:VariableID){
        self.id = id
        self.name = ""
        self.symbol = ""
        self.units = ""
        self.statePosition = -1
    }
    
    init(_ id:VariableID, named name:String = "", symbol:String = "", units:String = ""){
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
        self.units = units
        self.statePosition = -1
        
    }
    
    static func initVars(filename : String) -> [Variable] {
        //NSMutableArray<AnalysisInput *> *inputs= [NSMutableArray array];
        guard let inputList = NSArray.init(contentsOfFile: filename)
            else {
                return []}
        var initVars : [Variable] = []
        for thisVar in inputList {
            let dict = thisVar as! NSDictionary
            let newVar = Variable(dict.value(forKey: "id") as! VariableID, named: dict.value(forKey: "name") as! String,
                                  symbol: dict.value(forKey: "symbol") as! String, units: dict.value(forKey:"units") as! String)
            newVar.value = dict.value(forKey: "value") as? Double
            
            //Below code is meant to initialize as an example
            if newVar.id == "dx" || newVar.id == "dy" || newVar.id == "mtot" {
                newVar.value = 10
            }
 
            initVars.append(newVar)
        }
        return initVars
    }
    
    static func recursPopulateList(input: NSArray)->[InputStateVariable]{ //fixit: for some reason, inputs are getting initialized twice
        var output : [InputStateVariable] = []
        for curProps in input {
            let curPropDict = curProps as! NSDictionary
            let curInput : InputStateVariable = InputStateVariable.init(withDictionary: curPropDict)
            if !(curInput.itemType=="variable") {
                let curOutput : [InputStateVariable] = recursPopulateList(input: curPropDict.value(forKey: "items") as! NSArray)
                curInput.children = curOutput
            }
            output.append(curInput)
        }
        return output
    }
    
    static func getVariable(_ id : String, inputList: [Variable])->Variable?{
        for thisVar in inputList {//TODO: turn all variable input into dictionary
            if thisVar.id == id{return thisVar}
        }
        return nil
    }
}

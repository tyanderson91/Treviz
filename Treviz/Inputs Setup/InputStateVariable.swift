//
//  InitState.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/27/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class InputStateVariable: NSObject {
    static var varInputList : [Variable] = []
    var children : [InputStateVariable] = []
    var isValid : Bool = false
    var itemType : String = ""
    var id : String = ""
    var name : String = ""
    var variable : Variable? = nil
    var isParam : Bool = false
    
    init(withDictionary dict : NSDictionary){
        super.init()
        let id = dict["id"] as! String
        let itemType = dict["itemType"] as! String
        if itemType == "var"{
            //self.name = "thisName"
            self.variable = Variable.getVariable(id, inputList: InputStateVariable.varInputList)
            self.isParam = dict["isParam"] as! Bool
        } else {
            self.name = dict["name"] as! String
            self.isParam = false
            self.isValid = false
        }
        self.id = id
        self.itemType = itemType
        return
    }
    
    static func inputList(filename : String) -> [InputStateVariable] {
    //NSMutableArray<AnalysisInput *> *inputs= [NSMutableArray array];
        guard let inputList = NSArray.init(contentsOfFile: filename) else {return []}
        let inputs = recursPopulateList(input: inputList)
        
        for thisState in inputs{
            thisState.setParams()
        }
        return inputs
    }
    
    static func recursPopulateList(input: NSArray)->[InputStateVariable]{ //fixit: for some reason, inputs are getting initialized twice
        var output : [InputStateVariable] = []
        for curProps in input {
            let curPropDict = curProps as! NSDictionary
            let curInput : InputStateVariable = InputStateVariable.init(withDictionary: curPropDict)
            if !(curInput.itemType=="var") {
                let curOutput : [InputStateVariable] = recursPopulateList(input: curPropDict.value(forKey: "items") as! NSArray)
                curInput.children = curOutput
            }
            output.append(curInput)
        }
        return output
    }
    
    func setParams(){//Sets param status for headers and subheaders
        if self.itemType == "header" || self.itemType == "subHeader"{
            var hasParams = false
            for curChild in self.children{
                curChild.setParams()
                hasParams = hasParams || curChild.isParam
            }
            self.isParam = hasParams
        }
    }
}

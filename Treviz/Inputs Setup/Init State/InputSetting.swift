//
//  InitState.swift
//  Treviz
//
//  This class defines a single instance of an anaysis input setting
//  All inputs that can accept values, be parameterized, etc. are instances of this class
//  Example include planet name/planetary properties, run settings, vehicle and guidance settings, and all input states
//
//  Created by Tyler Anderson on 3/27/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class InputSetting: Variable {
    static var varInputList : [Variable] = []
    var children : [InputSetting] = []//If this setting is just a header or subheader, it must have children settings
    var isValid : Bool = false
    var itemType : String = ""
    var isParam : Bool = false
    var heading : InputSetting?
    
    init(withDictionary dict : NSDictionary){
        let curid = dict["id"] as! String
        itemType = dict["itemType"] as! String
        if itemType == "var"{
            //self.name = "thisName"
            isParam = dict["isParam"] as! Bool
            if let curvariable = Variable.getVariable(curid, inputList: InputSetting.varInputList){
                super.init(curid,named: curvariable.name, symbol:curvariable.symbol)
                self.units = curvariable.units
                self.value = curvariable.value
            } else {super.init("")}
        } else {
            let curname = dict["name"] as! String
            isParam = false
            isValid = false
            super.init(curid,named: curname, symbol:"")
        }
    }
    
    static func inputList(filename : String) -> [InputSetting] {
    //NSMutableArray<AnalysisInput *> *inputs= [NSMutableArray array];
        guard let inputList = NSArray.init(contentsOfFile: filename) else {return []}
        let inputs = recursPopulateList(input: inputList)
        
        for thisState in inputs{
            thisState.setParams()
        }
        return inputs
    }
    
    static func recursPopulateList(input: NSArray)->[InputSetting]{ //fixit: for some reason, inputs are getting initialized twice
        var output : [InputSetting] = []
        for curProps in input {
            let curPropDict = curProps as! NSDictionary
            let curInput : InputSetting = InputSetting.init(withDictionary: curPropDict)
            if !(curInput.itemType=="var") {
                let curOutput : [InputSetting] = recursPopulateList(input: curPropDict.value(forKey: "items") as! NSArray)
                for output in curOutput{
                    output.heading = curInput
                }
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

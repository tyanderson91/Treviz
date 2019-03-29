//
//  InitState.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/27/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class InitState: Variable {

    var children : [InitState] = []
    var checkValid : Bool = false
    var isValid : Bool = false
    var itemType : String = ""
    
    init(withDictionary dict : NSDictionary){
        let id = dict["ID"] as! String
        let itemType = dict["itemType"] as! String
        let name = dict["DisplayName"] as! String
        if itemType == "variable"{
            let cursymbol = dict["Symbol"] as! String
            let curvalue = dict["Value"] as! Double
            let curunits = dict["Units"] as! String
            super.init(id, named : name, symbol : cursymbol, units : curunits)
            self.value = curvalue
            self.isParam = dict["isParam"] as! Bool
            self.children = []
        } else {
            let cursymbol = "--"
            let curunits = "--"
            super.init(id, named : name, symbol : cursymbol, units : curunits)
            self.isParam = false
        }
        self.itemType = itemType
        self.checkValid = dict["checkValid"] as! Bool
        
        return
    }
    
    static func inputList(filename : String) -> [InitState] {
    //NSMutableArray<AnalysisInput *> *inputs= [NSMutableArray array];
        guard let inputList = NSArray.init(contentsOfFile: filename) else {return []}
        let inputs = recursPopulateList(input: inputList)
        return inputs
    }
    
    static func recursPopulateList(input: NSArray)->[InitState]{ //fixit: for some reason, inputs are getting initialized twice
        var output : [InitState] = []
        for curProps in input {
            let curPropDict = curProps as! NSDictionary
            let curInput : InitState = InitState.init(withDictionary: curPropDict)
            if !(curInput.itemType=="variable") {
                let curOutput : [InitState] = recursPopulateList(input: curPropDict.value(forKey: "items") as! NSArray)
                curInput.children = curOutput
            }
            output.append(curInput)
        }
        return output
    }
    
    func hasParams()->Bool{
        if self.itemType == "variable"{
            return self.isParam
        }
        else if self.itemType == "header" || self.itemType == "subHeader"{
            var hasParams = false
            for curChild in self.children{
                hasParams = hasParams || curChild.hasParams()
            }
            return hasParams
        }
        return false
    }
    
}

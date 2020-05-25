//
//  AnalysisFactoryInits.swift
//  Treviz
//
//  This file contains initializers for components of analysis that reference other components
//  Used when initializing an analysis from file and all you have is ID references to existing components (such as Conditions)
//
//  Created by Tyler Anderson on 5/17/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension Analysis {
    func setupConstants(){
        var initVars = loadVars(from: "InitVars")
        initVars = State.sortVarIndices(initVars)
        varList = initVars
        loadVarGroups(from: "InitStateStructure")
    }
    
    func loadVars(from plist: String)->[Variable] {
        guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return []}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return []}//return empty if filename not found
        var initVars = Array<Variable>()
        for thisVar in inputList {
            guard let dict = thisVar as? NSDictionary else {return []}
            let newVar = Variable(dict["id"] as! VariableID, named: dict["name"] as! String, symbol: dict["symbol"] as! String)
            newVar.units = dict["units"] as! String
            newVar.value = [0]
            initVars.append(newVar)
        }
        return initVars
    }
    
    /**
     This function reads in the current physics model and pre-populates all the required initial states with 0 values
     */
    func defaultInitSettings()->[Variable] { //TODO: vary depending on the physics type
        var varList = [Variable]()
        for thisVar in varList {
            guard let newVar = thisVar.copy() as? Variable else {continue}
            varList.append(newVar)
        }
        return varList
    }
    
    func loadVarGroups(from plist: String){
         guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
         guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return} //return empty if filename not found
         initStateGroups = InitStateHeader(id: "default")
         loadVarGroupsRecurs(input: initStateGroups, withList: inputList as! [NSDictionary])
     }
     
     private func loadVarGroupsRecurs(input: InitStateHeader, withList list: [NSDictionary]){
         for dict in list {
             guard let itemType = dict["itemType"] as? String else { return }
             guard let itemID = dict["id"] as? VariableID else { return }
             let name = dict["name"] as? String
             
             if itemType == "var"{
                 if let newVar = inputSettings.first(where: {$0.id == itemID}) as? Variable {
                    input.variables.append(newVar)
                 }
                 continue
             } else {
                 var newHeader = InitStateHeader(id: "")
                 if itemType == "header" {
                     newHeader = InitStateHeader(id: itemID)}
                 else if itemType == "subHeader" {
                     newHeader = InitStateSubHeader(id: itemID)}
                 else {return}
                 newHeader.name = name!
                 input.subheaders.append(newHeader)
                 if let children = dict["items"] as? NSArray {
                     loadVarGroupsRecurs(input: newHeader, withList: children as! [NSDictionary])
                 }
             }
         }
     }
}

extension Condition {
    convenience init?(decoder: Decoder, referencing analysis: Analysis) {
        do {
            try self.init(from: decoder)
            let container = try decoder.container(keyedBy: Condition.CodingKeys.self)
            let conditionNames = try container.decode(Array<String>.self, forKey: .Conditions)
            for thisConditionName in conditionNames {
                if let thisCondition = analysis.conditions.first(where: {$0.name == thisConditionName} ) {
                    self.conditions.append(thisCondition)
                } else {
                    let logmessage = String(format: "Could not find constituent condition '%s' of condition '%s'", thisConditionName, self.name) // TODO: Make sure that conditions can be read in any order so that an error is not thrown for referencing a condition to be read later
                    analysis.logMessage(logmessage)
                }
            }
        } catch {
            analysis.logMessage("Error when reading condition")
            return nil
        }
    }
}

extension TZOutput {
    convenience init?(decoder: Decoder, referencing analysis: Analysis) {
        do {
            try self.init(from: decoder)
            let container = try decoder.container(keyedBy: TZOutput.CodingsKeys.self)
            
            if true {
                let var1ID = try container.decode(String.self, forKey: .var1)
                var1 = analysis.varList.first(where: {$0.id == var1ID})
            }
            if plotType.nAxis >= 2 {
                let var2ID = try container.decode(String.self, forKey: .var2)
                var2 = analysis.varList.first(where: {$0.id == var2ID})
            }
            if plotType.nAxis >= 3 {
                let var3ID = try container.decode(String.self, forKey: .var3)
                var3 = analysis.varList.first(where: {$0.id == var3ID})
            }
            if (plotType.nVars > plotType.nAxis) && (plotType.id != "contour2d ") {
                //let categoryVarID = try container.decode(String.self, forKey: .catVar)
                //categoryVar = analysis.varList.first(where: {$0.id == categoryVarID}) // TODO: Make a way of accessing this
            }
            
            if self.plotType.requiresCondition {
                let conditionName = try container.decode(String.self, forKey: .condition)
                if let thisCondition = analysis.conditions.first(where: {$0.name == conditionName}) {
                    self.condition = thisCondition
                } else {
                    let logmessage = String(format: "Could not find condition '%s' referenced in output '%s'", conditionName, self.title)
                    analysis.logMessage(logmessage)
                }
            }
        } catch {
            analysis.logMessage("Error when reading output")
            return nil
        }
    }
}


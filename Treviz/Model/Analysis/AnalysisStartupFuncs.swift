//
//  AnalysisStartupFuncs.swift
//  Treviz
//
//  Various functions called during the analysis setup process
//
//  Created by Tyler Anderson on 6/2/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension Analysis {
    func setupConstants(){
        varList = loadVars(from: "InitVars")
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
    /*
    func defaultInitSettings()->[Variable] { //TODO: vary depending on the physics type
        var varList = [Variable]()
        for thisVar in varList {
            let newVar = thssVar.copy() as? Variable else {continue}
            varList.append(newVar)
        }
        return varList
    }*/
    
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
                 } else if let defaultVar = varList.first(where: {$0.id == itemID}) {
                    input.variables.append(defaultVar)
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

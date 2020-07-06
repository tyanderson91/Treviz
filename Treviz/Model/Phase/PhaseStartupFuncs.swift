//
//  PhaseStartupFuncs.swift
//  Treviz
//
//  Various functions called during the analysis setup process
//
//  Created by Tyler Anderson on 6/2/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension TZPhase {
    func setupConstants(){
        loadVars(from: "InitVars")
        varList = varList.compactMap({$0.copyToPhase(phaseid: self.id)})
        loadVarGroups(from: "InitStateStructure")
    }
    
    func loadVars(from plist: String) {
        guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else { return }
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else { return }//return empty if filename not found
        var tempVarList = Array<Variable>()
        for thisVar in inputList {
            guard let dict = thisVar as? NSDictionary else { return }
            guard let varid = dict["id"] as? VariableID else { continue }
            if requiredVarIDs.contains(varid) {
                let newVar = Variable(varid, named: dict["name"] as! String, symbol: dict["symbol"] as! String)
                newVar.units = dict["units"] as! String
                newVar.value = [0]
                tempVarList.append(newVar)
            }
        }
        varList = tempVarList
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

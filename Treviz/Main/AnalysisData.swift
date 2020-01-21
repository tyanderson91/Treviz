//
//  AnalysisData.swift
//  Treviz
//
//  Input/ Output functions for analysis-specific data and config options
//
//  Created by Tyler Anderson on 3/30/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//
import Foundation
import Cocoa
import Yams

enum PropagatorType {
    case explicit
    case rungeKutta4
}

typealias YamlString = String
/**
 Structure for reading and writing initial variable values
 params id: Variable ID
 param isParam: Whether the variable is to be used as a parameter in the analysis
 param value: Initial value
 */
struct InitStateSetting {
    let id: VariableID
    let isParam: Bool
    let value: Double
}

extension Analysis {

    func read(from data: Data) {
    }

    @objc func initReadData(_ notification: Notification){ //TODO: override with persistent data, last opened analysis, etc.
        // For now, this is just a test configuration
        
        self.name = "Test Analysis"
        self.defaultTimestep = 0.1
        self.vehicle = Vehicle()
        
        // Read all inputs
        self.inputSettings = self.varList.compactMap { ($0.copy() as! Parameter) } // TODO: Bettor way to copy?
        readSettings(from: "AnalysisSettings")
        if var tvar = self.inputSettings.first(where: {$0.id == "t"}) {tvar.isParam = true}
        
        loadVarGroups(from: "InitStateStructure")
        
        traj = State(variables: varList)
        for thisVar in self.inputSettings {
            traj[thisVar.id, 0] = (thisVar as! Variable)[0]
        }
        traj["mtot",0] = 10.0

        NotificationCenter.default.post(name: .didLoadAnalysisData, object: nil)
    }
    
    /**
     Read initial state variable info from a given yaml file
     Should be an array of dictionaries, and each dictionary should contain:
     * VariableID
     * Initial value (Double)
     * IsParam (Bool)
     */
    /*
    func readInitVars(from file: String){
        let inputList = getYamlObject(from: file) as! [[String:Any]]
        
        for thisVar in inputList {
            let thisVarID = thisVar["id"] as! VariableID
            let curVar = self.initVars.first(where: { $0.id == thisVarID})!
            // assert(curVar.value.count == 0)
            let val = thisVar["value"]
            if val is Int {
                curVar.value = [Double(val as! Int)]
            } else if val is Double {
                curVar.value = [val as! Double]
            }
            curVar.isParam = thisVar["isParam"] as! Bool
            inputSettings.append(curVar)
        }
    }*/
    
    /**
       Returns a variable described by the yaml input key using the value(s) in the yaml value
       - Parameter yamlObj: a Dictionary of the type [String: Any] read from a yaml file.
       */
    func initVar(varID: VariableID, varStr: Any) -> Variable? {
        guard let thisVar = self.inputSettings.first(where: { $0.id == varID}) as? Variable else {return nil}
        if let val = varStr as? NSNumber {
            thisVar.value = [VarValue(truncating: val)]
            return thisVar
        } else {return nil}
    }
    
    /**
     Creates a single Output from a Dictionary of the type that a yaml file can read. keys can include name (plot name), variable (variable id), type (plot type), condition, and output type (Plot by default)
     - Parameter yamlObj: a Dictionary of the type [String: Any] read from a yaml file.
     */
    func initOutput(fromYaml yamlObj: [String: Any]) -> TZOutput? {
        var outputDict = yamlObj
        if let plotTypeStr = yamlObj["plot type"] as? String{
            outputDict["plot type"] = self.appDelegate.plotTypes.first(where: {$0.name == plotTypeStr}) ?? ""
        }
        if let idInt = yamlObj["id"] as? Int {
            outputDict["id"] = idInt
        } else {
            let newID = ((self.plots.compactMap {$0.id}).max() ?? 0) + 1
            outputDict["id"] = newID
        }
        if let varstr = yamlObj["variable"] as? VariableID{
            outputDict["variable"] = self.appDelegate.initVars.first(where: {$0.id == varstr}) ?? ""
        }
        if let condstr = yamlObj["condition"] as? String{
            if condstr == "terminal" {
                outputDict["condition"] = self.terminalConditions
            } else if let thisCondition = self.conditions.first(where: {$0.name == condstr}) {
                outputDict["condition"] = thisCondition
            }
        }
        
        if let outputTypeStr = yamlObj["output type"] as? String{
            switch outputTypeStr {
            case "plot":
                return TZPlot(with: outputDict)
            case "text":
                return TZTextOutput(with: outputDict)
            default:
                return nil
            }
        } else {
            return TZPlot(with: outputDict)
        }
    }
    
    
    func readSettings(from file: String){
        guard let yamlDict: [String:Any] = getYamlObject(from: file) as? [String : Any] else {return}
        
        //if let inputList = try yamlListDict["Initial Variables"] as? [String: Int] {return}
        //guard let yamlList: [[String:Any]] = getYamlObject(from: file) as? [[String : Any]] else {return}
        //for thisYaml in yamlList {
        
        if let inputList = yamlDict["Initial Variables"] as? [String: Any] {
            for (curVarID, curVarVal) in inputList {
                //let thisVar =  self.initVars.first(where: { $0.id == curVarID})!
                //let val = inputList[thisVarID]
                //thisVar.value = [Double(truncating: val!)]
                if let thisVar = initVar(varID: curVarID, varStr: curVarVal) { inputSettings.append(thisVar) }
            }
        }
        
        /*
        if let inputList = yamlDict["Parameters"] as? [String: Any] {
            for (curVarID, curVarVal) in inputList {
                let thisVar =  self.varList.first(where: { $0.id == curVarID})!
                thisVar.value = [VarValue(truncating: curVarVal as! NSNumber)]
                thisVar.isParam = true
            }
        }*/
        
        if let conditionList = yamlDict["Conditions"] as? [[String: Any]] {
            // self.conditions = []
            for thisConditionDict in conditionList {
                if let newCond = Condition(fromYaml: thisConditionDict, inputConditions: conditions) {
                    //initCondition(fromYaml: thisConditionDict) {
                    conditions.append(newCond)
                } // TODO: else print error
            }
        }
        if let terminalConditionDict = yamlDict["Terminal Condition"] as? [String: Any] {
            if let newCond = Condition(fromYaml: terminalConditionDict, inputConditions: conditions) {
                newCond.name = "Terminal"
                conditions.append(newCond)
                self.terminalConditions = newCond
            }
        }
        if let outputList = yamlDict["Outputs"] as? [[String: Any]] {
            self.plots = []
            for thisOutputDict in outputList {
                if let newOutput = initOutput(fromYaml: thisOutputDict) {
                    //plots.append(newOutput)
                    self.viewController.mainSplitViewController.outputSetupViewController.addOutput(newOutput)
                }
            }
        }
    }
    
    /**
     This function reads in the current physics model and pre-populates all the required initial states with 0 values
     */
    func defaultInitSettings()->[Variable] { //TODO: vary depending on the physics type
        var varList = [Variable]()
        for thisVar in self.varList {
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

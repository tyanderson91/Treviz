//
//  AnalysisDocYaml.swift
//  
//  This file contains an extension to Analysis that handles all operations with Yaml file reading and writing
//  Created by Tyler Anderson on 2/18/20.
//

import Foundation
import Yams

//typealias YamlString = String

extension Analysis {

    func readFromYaml(data: Data){
        var yamlObj: Any?
        do {
            let stryaml = String(data: data, encoding: String.Encoding.utf8)
            yamlObj = try Yams.load(yaml: stryaml!)
        } catch {
            return
        }
        
        guard let yamlDict = yamlObj as? [String: Any] else { return }
        //if let inputList = try yamlListDict["Initial Variables"] as? [String: Int] {return}
        //guard let yamlList: [[String:Any]] = getYamlObject(from: file) as? [[String : Any]] else {return}
        //for thisYaml in yamlList {
        
        if let conditionList = yamlDict["Conditions"] as? [[String: Any]] {
            // self.conditions = []
            for thisConditionDict in conditionList {
                if let newCond = Condition(fromYaml: thisConditionDict, inputConditions: conditions) {
                    conditions.append(newCond)
                } else {
                    self.logMessage("Error initiating condition")
                }
            }
        }
        
        phases = []
        if let phaseList = yamlDict["Phases"] as? [[String: Any]] {
            for curPhaseDict in phaseList {
                let newPhase = TZPhase.init(yamlDict: curPhaseDict, analysis: self)
                phases.append(newPhase)
            }
        } else { // If no phase information is input, assume only 1 phase
            let curPhaseDict = yamlDict
            let newPhase = TZPhase.init(yamlDict: curPhaseDict, analysis: self)
            phases.append(newPhase)
        }
        
        
        if let inputList = yamlDict["Parameters"] as? [[String: Any]] {
            for paramSet in inputList {
                for (thisKey, thisVal) in paramSet {
                    let curVarID = self.phases.count == 1 ? thisKey.atPhase(self.phases[0].id) : thisKey
                    let curSettings = inputSettings
                    guard let thisVarIndex = curSettings.firstIndex(where: { $0.id == curVarID }) else { continue }
                    if let thisVar = inputSettings[thisVarIndex] as? Variable {
                        guard let startVal = VarValue(numeric: thisVal) else { continue }
                        thisVar.isParam = true
                        thisVar.value[0] = startVal
                    }
                }
            }
        }
        
        if let outputList = yamlDict["Outputs"] as? [[String: Any]] {
            plots = []
            for thisOutputDict in outputList {
                if let newOutput = initOutput(fromYaml: thisOutputDict) {
                    plots.append(newOutput)
                }
            }
        }
        
        traj = State(varList)
    }
    
    /**
       Returns a variable described by the yaml input key using the value(s) in the yaml value
       - Parameter yamlObj: a Dictionary of the type [String: Any] read from a yaml file.
       */
    /*
    func initVar(varID: VariableID, varStr: Any) -> Variable? {
        //guard var thisVar = inputSettings.first(where: { $0.id == varID}) as? Variable else {return nil}
        //TODO: convert inputSettings to just a reference to varList for variables
        guard let thisVarIndex = inputSettings.firstIndex(where: { $0.id == varID}) else {return nil}
        guard let thisVar = inputSettings[thisVarIndex] as? Variable else {return nil}
        if let val = varStr as? NSNumber {
            thisVar.value = [VarValue(truncating: val)]
            //inputSettings[thisVarIndex] = thisVar
            return thisVar
        } else {return nil}
    }*/

    /**
     Creates a single Output from a Dictionary of the type that a yaml file can read. keys can include name (plot name), variable (variable id), type (plot type), condition, and output type (Plot by default)
     - Parameter yamlObj: a Dictionary of the type [String: Any] read from a yaml file.
     */
    func initOutput(fromYaml yamlObj: [String: Any]) -> TZOutput? {
        var outputDict = yamlObj
        if let plotTypeStr = yamlObj["plot type"] as? String{
            outputDict["plot type"] = TZPlotType.allPlotTypes.first(where: {$0.name == plotTypeStr}) ?? ""
        }
        if let idInt = yamlObj["id"] as? Int {
            outputDict["id"] = idInt
        } else {
            let newID = ((plots.compactMap {$0.id}).max() ?? 0) + 1
            outputDict["id"] = newID
        }
        if let titlestr = yamlObj["title"] as? String{
            outputDict["title"] = titlestr
        }
        if let varstr = yamlObj["variable1"] as? VariableID{
            outputDict["variable1"] = varList.first(where: {$0.id == varstr}) ?? ""
        }
        else if let varstr = yamlObj["variable"] as? VariableID{
            outputDict["variable1"] = varList.first(where: {$0.id == varstr}) ?? ""
        }
        if let varstr = yamlObj["variable2"] as? VariableID{
            outputDict["variable2"] = varList.first(where: {$0.id == varstr}) ?? ""
        }
        if let varstr = yamlObj["variable3"] as? VariableID{
            outputDict["variable3"] = varList.first(where: {$0.id == varstr}) ?? ""
        }
        if let condstr = yamlObj["condition"] as? String{
            if condstr == "terminal" {
                outputDict["condition"] = terminalCondition
            } else if let thisCondition = conditions.first(where: {$0.name == condstr}) {
                outputDict["condition"] = thisCondition
            }
        }
        
        if let outputType = yamlObj["output type"] as? String {
            switch TZOutput.OutputType(rawValue: outputType) {
            case .plot:
                return TZPlot(with: outputDict)
            case .text:
                return TZTextOutput(with: outputDict)
            default:
                return TZPlot(with: outputDict)
            }
        } else {
            return TZPlot(with: outputDict)
        }
    }
}

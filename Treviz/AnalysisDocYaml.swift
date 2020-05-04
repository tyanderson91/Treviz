//
//  AnalysisDocYaml.swift
//  
//  This file contains an extension to AnalysisDoc that handles all operations with Yaml file reading and writing
//  Created by Tyler Anderson on 2/18/20.
//

import Foundation
import Yams

//typealias YamlString = String

extension AnalysisDoc {

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
        
        if let inputList = yamlDict["Initial Variables"] as? [String: Any] {
            for (curVarID, curVarVal) in inputList {
                //let thisVar =  self.initVars.first(where: { $0.id == curVarID})!
                //let val = inputList[thisVarID]
                //thisVar.value = [Double(truncating: val!)]
                _ = initVar(varID: curVarID, varStr: curVarVal)// { inputSettings.append(thisVar) }
            }
        }
        
        if let inputList = yamlDict["Parameters"] as? [[String: Any]] {
            for paramSet in inputList {
                for thisKey in paramSet.keys { //TODO: better way to do this
                    let curVarID = thisKey
                    let thisVar =  analysis.inputSettings.first(where: { $0.id == curVarID }) as! Variable
                    thisVar.value = [VarValue(truncating: paramSet[curVarID] as! NSNumber)]
                    thisVar.isParam = true
                }
            }
        }
        
        if let conditionList = yamlDict["Conditions"] as? [[String: Any]] {
            // self.conditions = []
            for thisConditionDict in conditionList {
                if let newCond = Condition(fromYaml: thisConditionDict, inputConditions: analysis.conditions) {
                    //initCondition(fromYaml: thisConditionDict) {
                    analysis.conditions.append(newCond)
                } // TODO: else print error
            }
        }
        if let terminalConditionName = yamlDict["Terminal Condition"] as? String {
            if let cond = analysis.conditions.first(where: { $0.name == terminalConditionName }) {
                analysis.terminalCondition = cond
            }
            /*
            if let newCond = Condition(fromYaml: terminalConditionDict, inputConditions: analysis.conditions) {
                newCond.name = "Terminal"
                analysis.conditions.append(newCond)
                analysis.terminalCondition = newCond
            }*/
        }
        if let outputList = yamlDict["Outputs"] as? [[String: Any]] {
            analysis.plots = []
            for thisOutputDict in outputList {
                if let newOutput = initOutput(fromYaml: thisOutputDict) {
                    analysis.plots.append(newOutput)
                }
            }
        }
        analysis.traj = State(variables: analysis.varList)
    }
    
    /**
       Returns a variable described by the yaml input key using the value(s) in the yaml value
       - Parameter yamlObj: a Dictionary of the type [String: Any] read from a yaml file.
       */
    func initVar(varID: VariableID, varStr: Any) -> Variable? {
        guard let thisVar = analysis.inputSettings.first(where: { $0.id == varID}) as? Variable else {return nil}
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
            outputDict["plot type"] = TZPlotType.allPlotTypes.first(where: {$0.name == plotTypeStr}) ?? ""
        }
        if let idInt = yamlObj["id"] as? Int {
            outputDict["id"] = idInt
        } else {
            let newID = ((analysis.plots.compactMap {$0.id}).max() ?? 0) + 1
            outputDict["id"] = newID
        }
        if let titlestr = yamlObj["title"] as? String{
            outputDict["title"] = titlestr
        }
        if let varstr = yamlObj["variable1"] as? VariableID{
            outputDict["variable1"] = initVars.first(where: {$0.id == varstr}) ?? ""
        }
        else if let varstr = yamlObj["variable"] as? VariableID{
            outputDict["variable1"] = initVars.first(where: {$0.id == varstr}) ?? ""
        }
        if let varstr = yamlObj["variable2"] as? VariableID{
            outputDict["variable2"] = initVars.first(where: {$0.id == varstr}) ?? ""
        }
        if let varstr = yamlObj["variable3"] as? VariableID{
            outputDict["variable3"] = initVars.first(where: {$0.id == varstr}) ?? ""
        }
        if let condstr = yamlObj["condition"] as? String{
            if condstr == "terminal" {
                outputDict["condition"] = analysis.terminalCondition
            } else if let thisCondition = analysis.conditions.first(where: {$0.name == condstr}) {
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

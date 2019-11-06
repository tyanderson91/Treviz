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
        // TODO: Allow reading multiple configurations from a single yaml file
        
        self.name = "Test Analysis"
        self.defaultTimestep = 0.001
        self.vehicle = Vehicle()
        
        // Initialize var values
        //readSettings(from: "InitVarSettings")
        readInitVars(from: "AnalysisSettings")

        traj = State(variables: initVars)
        for thisVar in self.inputSettings {
            traj[thisVar.id, 0] = (thisVar as! Variable)[0]
        }
        traj["mtot",0] = 10.0

        
        // Initialize conditions
        let termCond1 = Condition("t", lowerBound : 10)
        termCond1.name = "Final time"
        let termCond2 = Condition("y", upperBound : -0.10)
        termCond2.name = "Ground Impact"
        let terminalConditions = Condition(conditions: [termCond1, termCond2], unionType: .or, name: "Terminal Conditions", isSinglePoint: true)
        self.conditions.append(contentsOf: [termCond1, termCond2, terminalConditions])
        self.terminalConditions = terminalConditions
        
        //Plots
        let testVarX = self.initVars.first(where: { $0.id == "x"} )!
        let newOutput = TZTextOutput(id: 1, vars: [testVarX], plotType: self.plotTypes.first(where: {$0.name == "Single Value"})!)
        newOutput.condition = terminalConditions
        newOutput.curTrajectory = self.traj
        plots.append(newOutput)
        
        NotificationCenter.default.post(name: .didLoadAnalysisData, object: nil)
    }
    
    /**
     Get the object associated with a given yaml file
     */
    func getYamlObject(from file: String)->Any?{
        var outputList: Any?
        if let yamlFilePath = Bundle.main.path(forResource: file, ofType: "yaml"){
            do {
                let stryaml = try String(contentsOfFile: yamlFilePath, encoding: String.Encoding.utf8)
                outputList = try (Yams.load(yaml: stryaml))
            } catch {
                outputList = nil }
        }
        return outputList
    }
    
    /**
     Read initial state variable info from a given yaml file
     Should be an array of dictionaries, and each dictionary should contain:
     * VariableID
     * Initial value (Double)
     * IsParam (Bool)
     */
    func readSettings(from file: String){
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
    }
    
    /**
     Read setup for plots and text outputs from a given yaml file
     Should be an array of dictionaries, and each dictionary should contain:
     * VariableID
     * Initial value (Double)
     * IsParam (Bool)
     */
    func readOutput(from file: String){
        var outputList: [[String:Any]] = []
        if let yamlFilePath = Bundle.main.path(forResource: file, ofType: "yaml"){
            do {
                let stryaml = try String(contentsOfFile: yamlFilePath, encoding: String.Encoding.utf8)
                outputList = try (Yams.load(yaml: stryaml) as! [[String : Any]])
            } catch {
                outputList = [] }
        }
        
        for thisVar in outputList {
            let thisVarID = thisVar["id"] as! VariableID
            let curVar = self.initVars.first(where: { $0.id == thisVarID})!
            assert(curVar.value.count == 0)
            let val = thisVar["value"]
            if val is Int {
                curVar.value.append(Double(val as! Int))
            } else if val is Double {
                curVar.value.append(val as! Double)
            }
            curVar.isParam = thisVar["isParam"] as! Bool
            inputSettings.append(curVar)
        }
        
    }
    func readInitVars(from file: String){
        let yamlList: [String:Any] = getYamlObject(from: file) as! [String : Any]
        let inputList = try yamlList["Initial Variables"] as? [String: Int] ?? [:]
        for thisVarID in inputList.keys {
            let thisVar =  self.initVars.first(where: { $0.id == thisVarID})!
            let val = inputList[thisVarID]
            thisVar.value = [Double(val!)]
            inputSettings.append(thisVar)
        }
    }
    
}

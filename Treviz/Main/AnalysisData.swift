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

enum PropagatorType {
    case explicit
    case rungeKutta4
}

extension Analysis {

    func read(from data: Data) {
    }

    @objc func initReadData(_ notification: Notification){ //TODO: override with persistent data, last opened analysis, etc.
        // For now, this is just a test configuration
        
        self.name = "Test Analysis"
        self.defaultTimestep = 0.001
        self.vehicle = Vehicle()
        // Initialize var values
        readSettings(from: "InitVarSettings")
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
     Read initial state variable info from a given plist file
     plist should be an array of dictionaries, and each dictionary should contain:
     * VariableID
     * Initial value (Double)
     * IsParam (Bool)
     */
    func readSettings(from file: String){
        guard let varFilePath = Bundle.main.path(forResource: file, ofType: "plist") else {return}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) as? Array<NSDictionary> else {return}
        for thisVar in inputList {
            let thisVarID = thisVar["id"] as! VariableID
            let curVar = self.initVars.first(where: { $0.id == thisVarID})!
            curVar.value.append(thisVar["value"] as! Double) // TODO: make sure this is the first element
            curVar.isParam = thisVar["isParam"] as! Bool
            inputSettings.append(curVar)
        }
    }
    
}

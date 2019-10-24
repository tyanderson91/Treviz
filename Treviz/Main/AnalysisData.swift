//
//  AnalysisData.swift
//  Treviz
//
//  This object does the main job of reading, writing, and storing analysis document data
//
//  Created by Tyler Anderson on 3/30/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//
import Foundation
import Cocoa

class AnalysisData: NSObject {
    
    var initState = State()
    var inputSettings : [Parameter] = []
    var plots : [TZOutput] = []
    var analysis : Analysis!
    
    func read(from data: Data) {
    }
    
    func data() -> Data? {
        return nil//contentString.data(using: .utf8)
    }
    
    init(analysis: Analysis){
        //This function runs the default loading sub-methods
        //TODO: expand the number of read sourcess
        //self.loadVars(from: "InitialVars")
        super.init()
        self.analysis = analysis
        NotificationCenter.default.addObserver(self, selector: #selector(self.initReadData(_:)), name: .didLoadAppDelegate, object: nil)
        
        NotificationCenter.default.post(name: .didLoadAnalysisData, object: nil)
    }
    
    @objc func initReadData(_ notification: Notification){
        // Initialize var values
        guard let varFilePath = Bundle.main.path(forResource: "InitVarSettings", ofType: "plist") else {return}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return}
        
        for thisVarElement in inputList {
            let thisVar = thisVarElement as! NSDictionary
            let initVars = analysis.initVars
            let thisVarID = thisVar["id"] as! VariableID
            let curVar = initVars!.first(where: { $0.id == thisVarID})!
            curVar.value.append(thisVar["value"] as! Double) // TODO: make sure this is the first element
            curVar.isParam = thisVar["isParam"] as! Bool
            inputSettings.append(curVar)
        }
        
        // Init conditions
        let termCond1 = Condition("t", lowerBound : 10) //TerminalCondition(varID: "t", crossing: 100, inDirection: 1) //TODO: make max time a required terminal condition
        termCond1.name = "Final time"
        let termCond2 = Condition("y", upperBound : -0.10) //TerminalCondition(varID: "y", crossing: 0, inDirection: -1)
        termCond2.name = "Ground Impact"
        let terminalConditions = Condition()
        terminalConditions.conditions = [termCond1, termCond2]
        terminalConditions.unionType = .or
        terminalConditions.name = "Terminal Conditions"
        terminalConditions.isSinglePoint = true
        analysis.conditions.append(contentsOf: [termCond1, termCond2, terminalConditions])
        
        //Plots
        let testVarX = analysis.initVars.first(where: { $0.id == "x"} )!
        let newOutput = TZTextOutput(id: 1, vars: [testVarX], plotType: analysis.appDelegate.plotTypes.first(where: {$0.name == "Single Value"})!)
        newOutput.condition = terminalConditions //terminalConditions
        newOutput.curTrajectory = analysis.traj
        plots.append(newOutput)
        // analysis.viewController.mainSplitViewController.outputSetupViewController.addOutput(newOutput)
    }
    
    
}

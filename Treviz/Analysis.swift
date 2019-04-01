//
//  Analysis.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class Analysis: NSDocument {//TODO: possibly subclass NSPersistentDocument if using CoreData
    var ouputsViewController : OutputsViewController? = nil //TODO: Initialize like input view controller
    var ouputsSetupViewController : OutputSetupViewController? = nil //TODO: Initialize like input view controller
    @objc var analysisData = AnalysisData(fromPlist: "InitialVars")
    
    var initVars : [Variable] = []
    var initialState = State()
    var terminalConditions = TerminalConditionSet([])
    var returnCodes : [Int] = []
    var trajectory : [[Double]] = [] //TODO : allow multiple variable types
    var progressBar : NSProgressIndicator!
    var outputsVC : OutputsViewController!
    //Set up terminal conditions
    
    /*var inputsViewController: InputsViewController? {
        if let mainViewController = windowControllers[0].contentViewController as? MainViewController{
            //let inputViewController = mainViewController.mainSplitViewController?.inputsViewController
            //inputViewController?.mainAnalysis = self
            //return inputViewController}
            mainViewController.mainAnalysis = self}
        else {return nil}
    }*/
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        //let A = self.analysisData
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Analysis Window Controller")) as! MainWindowController
        self.addWindowController(windowController)
        windowController.contentViewController?.representedObject = analysisData
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        analysisData.read(from: data)
    }
    
    /// - Tag: writeExample
    override func data(ofType typeName: String) throws -> Data {
        return analysisData.data()!
    }
    
    func runAnalysis() -> [Int] {
        var currentState = initialState.toArray()
        let dt : Double = 0.1
        
        let termCond1 = TerminalCondition(varID: "t", crossing: 100, inDirection: 1) //TODO: make max time a required terminal condition
        let termCond2 = TerminalCondition(varID: "x", crossing: 40, inDirection: 1)
        terminalConditions = TerminalConditionSet([termCond1,termCond2])
        terminalConditions.initState = currentState
        
        //let newState = VehicleState()
        //var trajIndex = 1
        var analysisEnded = false
        let state = State.stateVarPositions //map of identifiers to positions
        
        self.trajectory.append(currentState)
        while !analysisEnded{
            var newState = State.initAsArray()
            let m = currentState[state["m"]!]
            let x = currentState[state["x"]!]
            let y = currentState[state["y"]!]
            let dx = currentState[state["dx"]!]
            let dy = currentState[state["dy"]!]
            let t = currentState[state["t"]!]
            
            let F_g = -9.81*m
            let a_y = F_g/m
            let a_x : Double = 0
            
            newState[state["t"]!] = t + dt
            newState[state["dy"]!] = dy + a_y * dt
            newState[state["y"]!] = y+dy*dt
            newState[state["dx"]!] = dx+a_x*dt
            newState[state["x"]!] = x + dx*dt
            newState[state["m"]!] = m
            trajectory.append(newState)
            
            var pctComplete = 0.0
            (returnCodes,analysisEnded,pctComplete) = terminalConditions.checkAllConditions(prevState: currentState, curState: newState)
            
            currentState = newState
            progressBar.doubleValue = pctComplete*100
        }
        return returnCodes
    }
}

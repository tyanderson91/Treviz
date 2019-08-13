//
//  Analysis.swift
//  Treviz
//
//  This class is the subclass of NSDocument that controls all the anlaysis document information and methods
//  Data reading and writing occurs in AnalysisData and is passed to this class
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class Analysis: NSDocument {//TODO: possibly subclass NSPersistentDocument if using CoreData
    //var ouputsViewController : OutputsViewController? = nil //TODO: Initialize like input view controller
    //var ouputsSetupViewController : OutputSetupViewController? = nil //TODO: Initialize like input view controller
    var analysisData : AnalysisData!
    
    //var initVars : [Variable] = []
    var initialState = State()
    var terminalConditions = TerminalConditionSet([])
    var returnCodes : [Int] = []
    var trajectory : [[Double]] = [] //TODO : allow multiple variable types
    var progressBar : NSProgressIndicator!
    var windowController : MainWindowController!//Implicit optional, should always be assigned after initialization
    var viewController : MainViewController!
    var conditions : [Condition]?
    //var outputsVC : OutputsViewController!
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
        
        analysisData = AnalysisData()
        // Add your subclass-specific initialization here.
        //let A = self.analysisData
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        self.windowController = (storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Analysis Window Controller")) as! MainWindowController)
        self.addWindowController(windowController)
        self.viewController = (windowController.contentViewController as! MainViewController)
        viewController.representedObject = self
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        //let fileContents = self.analysisData
        //analysisData.read(from: data)
    }
    
    /// - Tag: writeExample
    override func data(ofType typeName: String) throws -> Data {
        return analysisData.data()!
    }
    
    func runAnalysis() -> [Int] {//TODO: break this method into several phases to make it more manageable
        // Initial State
        self.viewController.mainSplitViewController.inputsViewController.collectInitialState()
        
        // Setup
        var currentState = initialState.toArray()
        let dt : Double = 0.1
        
        let termCond1 = TerminalCondition(varID: "t", crossing: 100, inDirection: 1) //TODO: make max time a required terminal condition
        let termCond2 = TerminalCondition(varID: "x", crossing: 40, inDirection: 1)
        let termCond3 = TerminalCondition(varID: "y", crossing: 0, inDirection: -1)

        terminalConditions = TerminalConditionSet([termCond1,termCond2,termCond3])
        terminalConditions.initState = currentState
        
        //let newState = VehicleState()
        //var trajIndex = 1
        var analysisEnded = false
        let state = State.stateVarPositions //map of identifiers to positions
        
        //Run
        self.trajectory.append(currentState)
        while !analysisEnded{
            var newState = State.initAsArray()
            let m = currentState[state["mtot"]!]
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
            newState[state["mtot"]!] = m
            trajectory.append(newState)
            
            var pctComplete = 0.0
            (returnCodes,analysisEnded,pctComplete) = terminalConditions.checkAllConditions(prevState: currentState, curState: newState)
            
            currentState = newState
            if let progressBar = viewController.analysisProgressBar{
                progressBar.doubleValue = pctComplete*100
            }
        }
        
        //Outputs
        self.viewController.mainSplitViewController.outputsViewController.processOutputs()
        return returnCodes
    }
}

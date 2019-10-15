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
    var appDelegate : AppDelegate!
    
    var variables : [Variable] = []
    var name : String = ""
    var initialState = State()
    var terminalConditions = TerminalConditionSet([])
    var returnCodes : [Int] = []
    var trajectory : [[Double]] = [] //TODO : allow multiple variable types
    var progressBar : NSProgressIndicator!
    var windowController : MainWindowController!//Implicit optional, should always be assigned after initialization
    var viewController : MainViewController!
    var conditions : [Condition]?
    var initVars : [Variable]! = nil
    var initStateGroups : InitStateHeader! = nil
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
        
        name = "Test Analysis"
        conditions = []
        if let delegate = appDelegate {
            self.variables = delegate.initVars
        }
        loadVars(from: "InitVars")
        loadVarGroups(from: "InitStateStructure")
        analysisData = AnalysisData(analysis: self)
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
        self.viewController.representedObject = self        
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        //let fileContents = self.analysisData
        //analysisData.read(from: data)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        return analysisData.data()!
    }
    
    func loadVars(from plist: String){
        guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return}//return empty if filename not found
        initVars = []
        for thisVar in inputList {
            let dict = thisVar as! NSDictionary //TODO: error check the type, return [] if not a dictionary
            let newVar = Variable(dict["id"] as! VariableID, named: dict["name"] as! String, symbol: dict["symbol"] as! String)
            newVar.units = dict["units"] as! String
            initVars.append(newVar)
        }
    }
    
    func loadVarGroups(from plist: String){
        guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return}//return empty if filename not found
        initStateGroups = InitStateHeader(id: "default")
        loadVarGroupsRecurs(input: initStateGroups, withList: inputList as! [NSDictionary])
    }
    
    private func loadVarGroupsRecurs(input: InitStateHeader, withList list: [NSDictionary]){
        for dict in list {
            //let dict = thisItem as! NSDictionary //TODO: error check the type, return [] if not a dictionary
            guard let itemType = dict["itemType"] as? String else { return }
            guard let itemID = dict["id"] as? VariableID else { return }
            let name = dict["name"] as? String
            
            if itemType == "var"{
                if let newVar = initVars.first(where: {$0.id == itemID}){
                    input.variables.append(newVar)}
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
    
    func runAnalysis() -> [Int] {//TODO: break this method into several phases to make it more manageable
        // Initial State
        //self.viewController.mainSplitViewController.inputsViewController.getState()
        
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

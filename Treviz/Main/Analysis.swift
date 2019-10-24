//
//  Analysis.swift
//  Treviz
//
//  This class is the subclass of NSDocument that controls all the anlaysis document information and methods
//  Data reading and writing occurs in AnalysisData and is passed to this class
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.

import Cocoa

class Analysis: NSDocument {//TODO: possibly subclass NSPersistentDocument if using CoreData
    //var ouputsViewController : OutputsViewController? = nil //TODO: Initialize like input view controller
    //var ouputsSetupViewController : OutputSetupViewController? = nil //TODO: Initialize like input view controller
    var analysisData : AnalysisData!
    var appDelegate : AppDelegate!
    
    var variables : [Variable] = []
    var name : String = ""
    var terminalConditions : Condition!
    var traj: State!
    var returnCode : Int = 0
    var progressBar : NSProgressIndicator!
    var windowController : MainWindowController!//Implicit optional, should always be assigned after initialization
    var viewController : MainViewController!
    var conditions : [Condition] = []
    var initVars : [Variable]! = nil
    var initStateGroups : InitStateHeader! = nil
    var isRunning = false
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
    
    
    func runAnalysis() {//TODO: break this method into several phases to make it more manageable
        // Initial State
        //self.viewController.mainSplitViewController.inputsViewController.getState()
        
        // Setup
        traj = State(variables: initVars)
        traj["mtot",0] = 10.0
        //traj["dy",0] = 10.0
        //traj["dx",0] = 10.0

        
        let dt : Double = 0.001
        //terminalConditions = TerminalConditionSet([termCond1,termCond2,termCond3])
        
        //let newState = VehicleState()
        //var trajIndex = 1
        
        let terminalConditions = conditions.first(where: {$0.name == "Terminal Conditions"})!
        let progressBar = viewController.analysisProgressBar!
        progressBar.usesThreadedAnimation = true
        //}
        //Run
        let outputTextView = (self.viewController.mainSplitViewController.outputsViewController.outputSplitViewController?.textOutputSplitViewItem.viewController as! TextOutputsViewController).textView!
        self.windowController.runButton.title = "■"
        // self.windowController.runButton.font?.setValue(20, forKeyPath: "PointSize")

        DistributedNotificationCenter.default.addObserver(self, selector: #selector(self.completeAnalysis), name: .didFinishRunningAnalysis, object: nil)

        isRunning = true
        DispatchQueue.global().async {
            var i = 0
            while self.isRunning {
                let x = self.traj["x", i]!
                let y = self.traj["y", i]!
                let dx = self.traj["dx", i]!
                let dy = self.traj["dy", i]!
                let t = self.traj["t", i]!
                let m = self.traj["mtot", i]!

                let F_g = -9.81*m
                let a_y = F_g/m
                let a_x : Double = 0
                
                i += 1
                self.traj["t", i] = t + dt
                self.traj["dy", i] = dy + a_y * dt
                self.traj["y", i] = y+dy*dt
                self.traj["dx", i] = dx+a_x*dt
                self.traj["x", i] = x + dx*dt
                self.traj["mtot", i] = m
                
                // var pctComplete = 0.0
                self.isRunning = !terminalConditions.evaluate(self.traj[i]) || i == 100000
                if !self.isRunning {
                    self.returnCode = 1
                }
                let pctcomp = pctComplete(cond: terminalConditions, initState: self.traj[0], curState: self.traj[i-1])
                
                DispatchQueue.main.async {
                    outputTextView.string="t: \(String(format: "%.5f", t)), "
                    outputTextView.string += "X: \(String(format: "%.5f", x)), "
                    outputTextView.string += "Y: \(String(format: "%.5f", y))\n"
                    // outputTextView.string.append(String(describing: pctcomp))

                    progressBar.doubleValue = pctcomp
                }
            }
            DistributedNotificationCenter.default.post(name: .didFinishRunningAnalysis, object: nil)
        }
    }
    
    @objc func completeAnalysis(notification: Notification){
        self.isRunning = false
        let progressBar = viewController.analysisProgressBar!
        progressBar.doubleValue = 0
        self.windowController.runButton.title = "►"
        if returnCode > 0 {
            self.viewController.mainSplitViewController.outputsViewController.processOutputs()}
    }
}

func pctComplete(cond: Condition, initState :StateArray, curState: StateArray)->Double{
    var tempPctComplete = 0.0
    for thisCond in cond.conditions {
        var curPctComplete = 0.0
        if let thisCond1 = thisCond as? SingleCondition {
            let thisVar = State.getValue(thisCond1.varID, state: curState)!
            let initVar = State.getValue(thisCond1.varID, state: initState)!
            let finalVar = thisCond1.ubound != nil ? thisCond1.ubound! : thisCond1.lbound!
            curPctComplete = (thisVar-initVar) / (finalVar-initVar)
        } else { curPctComplete = pctComplete(cond: thisCond as! Condition, initState: initState, curState: curState) }
    
        tempPctComplete = (tempPctComplete < curPctComplete) ? curPctComplete : tempPctComplete
        if tempPctComplete < 0{
            tempPctComplete = 0}
        else if tempPctComplete > 1{
            tempPctComplete = 1}
        }
    return tempPctComplete
}

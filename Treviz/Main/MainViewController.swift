//
//  MainViewController.swift
//  Treviz
//
//  Highest-level view controller
//  Mainly consists of the main split view controller and the progress bar
//
//  Created by Tyler Anderson on 3/10/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainViewController: TZViewController, AnalysisProgressReporter {

    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var analysisProgressBar: NSProgressIndicator!
    var mainSplitViewController : MainSplitViewController!
    var textOutputView : NSTextView? {
        return mainSplitViewController.outputsViewController.outputSplitViewController?.textOutputView
    }    
    // Run tracking
    var initialState: StateArray { return analysis.initState }
    var terminalCondition=Condition()// { return analysis.terminalCondition }
    
    // Progress Bar Update
    func updateProgress(at currentState: StateArray) {
        let pComplete = pctComplete(curState: currentState)
        analysisProgressBar.doubleValue = pComplete
    }
    func startProgressTracking(){
        self.terminalCondition = analysis.terminalCondition.copy() as! Condition
        analysisProgressBar.isHidden = false
    }
    func endProgressTracking(){
        analysisProgressBar.isHidden = true
    }
    /**
     Provide an estimate for the percentage completion of the analysis based on the initial state, current state, and terminal conditions
      - parameters:
        - cond: Condition, the terminal conditions
        - initState: StateArray, the beginning value of all changing values
        - curState: StateArray, the state at the current point in the analysis
     - returns:
        pctComplete: Double, a number between 0 and 1 representing the estimated completion
     */
    private func pctComplete(curState: StateArray)->Double{
        var tempPctComplete = 0.0
        for thisCond in terminalCondition.conditions {
            var curPctComplete = 0.0
            if let thisCond1 = thisCond as? SingleCondition {
                let thisVar = State.getValue(thisCond1.varID, curState)!
                let initVar = State.getValue(thisCond1.varID, initialState)!
                if thisCond1.equality != nil {
                    let finalVar = thisCond1.equality!
                    curPctComplete = Double((thisVar-initVar) / (finalVar-initVar))
                }
                else if thisCond1.specialCondition != nil {
                    
                } else {
                    let finalVar = thisCond1.ubound != nil ? thisCond1.ubound! : thisCond1.lbound!
                    curPctComplete = Double((thisVar-initVar) / (finalVar-initVar))
                }
            } else { curPctComplete = pctComplete(curState: curState) }
        
            tempPctComplete = (tempPctComplete < curPctComplete) ? curPctComplete : tempPctComplete
            if tempPctComplete < 0 {
                tempPctComplete = 0}
            else if tempPctComplete > 1{
                tempPctComplete = 1}
            }
        return tempPctComplete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFrameSize(NSSize.init(width: 1200, height: 500))
        self.analysis.progressReporter = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainSplitViewSegue"{
            self.mainSplitViewController =  (segue.destinationController as! MainSplitViewController)
            self.mainSplitViewController.analysis = analysis
        } else {return}
        
    }
    
}

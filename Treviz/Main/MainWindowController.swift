//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, AnalysisProgressReporter {

    //@IBOutlet weak var toolbar: NSToolbar!
    weak var toolbar: TZToolbar!
    @IBOutlet weak var showHidePanesControl: NSSegmentedControl!
    @IBOutlet weak var runButton: NSButton!

    var analysis : Analysis! { didSet { self.analysis.progressReporter = self }}
    var viewController: MainViewController! { return contentViewController as? MainViewController ?? nil}
    var analysisProgressBar: NSProgressIndicator? { return viewController.analysisProgressBar }
    
    @IBAction func storyboardRunAnalysisClicked(_ sender: Any) {
        runAnalysisClicked(sender)
    }
    /*
    private func processOutputs() {
        guard let textOutputView = viewController.textOutputView else {return}
        guard let outputSplitVC = viewController.mainSplitViewController.outputsViewController.outputSplitViewController else { return }
        guard let plotViewController = outputSplitVC.plotViewController else { return }
        
        textOutputView.string = ""
        plotViewController.plotViews = []
        for curOutput in analysis.plots {
            //curOutput.loadVars(analysis: analysis)
            do { try curOutput.assertValid() }
            catch {
                analysis.logMessage(error.localizedDescription)
                continue
            }
            curOutput.curTrajectory = analysis.varList
            if curOutput is TZTextOutput {
                do {
                    let newText = try (curOutput as! TZTextOutput).getText()
                    textOutputView.textStorage?.append(newText)
                    textOutputView.textStorage?.append(NSAttributedString(string: "\n\n"))
                } catch {
                    analysis.logMessage("Error in output set '\(curOutput.title)': \(error.localizedDescription)")
                }
            }
            else if curOutput is TZPlot {
                do {
                    try plotViewController.createPlot(plot: curOutput as! TZPlot)
                } catch {
                    analysis.logMessage("Error in plot '\(curOutput.title)': \(error.localizedDescription)")
                }
            }
        }
        let plotTabViewIndex = outputSplitVC.viewerTabViewController.tabView.indexOfTabViewItem(withIdentifier: "plotterTabViewItem")
        outputSplitVC.viewerTabViewController.tabView.selectTabViewItem(at: plotTabViewIndex)
    }*/
        
    // MARK: AnalysisProgressReporter implementation
    var terminalCondition = Condition()
    var initialState: StateDictSingle { return analysis.initState }
    
    func updateProgress(at currentState: StateDictSingle) {
        let pComplete = pctComplete(curState: currentState)
        analysisProgressBar?.doubleValue = pComplete
    }
    func startProgressTracking(){
        self.terminalCondition = analysis.terminalCondition!
        analysisProgressBar?.isHidden = false
        toolbar.toggleAnalysisRun.image = NSImage(named: "stop.fill")
    }
    func endProgressTracking(){
        analysisProgressBar?.isHidden = true
    }
    
    func completeAnalysis(){ // Runs when the analysis has terminated
        analysis.isRunning = false
        toolbar.toggleAnalysisRun.image = NSImage(named: "play.fill")

        guard let outputSplitVC = viewController.mainSplitViewController.outputsViewController.outputSplitViewController else { return }
        let plotTabViewIndex = outputSplitVC.viewerTabViewController.tabView.indexOfTabViewItem(withIdentifier: "plotterTabViewItem")
        outputSplitVC.viewerTabViewController.tabView.selectTabViewItem(at: plotTabViewIndex)
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
    private func pctComplete(curState: StateDictSingle)->Double{
        var tempPctComplete = 0.0
        for thisCond in terminalCondition.conditions {
            var curPctComplete = 0.0
            if let thisCond1 = thisCond as? SingleCondition {
                let thisVar = curState[thisCond1.varID]!//2State.getValue(thisCond1.varID, curState)!
                let initVar = initialState[thisCond1.varID]!//State.getValue(thisCond1.varID, initialState)!
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
}

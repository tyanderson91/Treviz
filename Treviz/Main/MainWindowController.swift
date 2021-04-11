//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, AnalysisProgressReporter {

    @IBOutlet weak var toolbar: TZToolbar!
    @IBOutlet weak var conditionsToolbarItem: NSToolbarItem!
    //weak var toolbar: TZToolbar!
    @IBOutlet weak var showHidePanesControl: NSSegmentedControl!
    @IBOutlet weak var runButton: NSToolbarItem!

    var analysis : Analysis! { didSet { self.analysis.progressReporter = self }}
    var viewController: MainViewController! { return contentViewController as? MainViewController ?? nil}
    var analysisProgressBar: NSProgressIndicator? { return viewController.analysisProgressBar }
    
    @IBAction func storyboardRunAnalysisClicked(_ sender: Any) {
        runAnalysisClicked(sender)
    }
    
    func updateProgress(at currentState: Any?) {
        let pComplete = pctComplete(at: currentState)
        analysisProgressBar?.doubleValue = pComplete
    }
    
    func startProgressTracking(){
        runButton.image = NSImage(systemSymbolName: "pause.rectangle.fill", accessibilityDescription: nil)
        runButton.label = "Stop"
        analysisProgressBar?.isHidden = false
    }
    func endProgressTracking(){
        runButton.image = NSImage(systemSymbolName: "play.rectangle", accessibilityDescription: nil)
        runButton.label = "Run"
        analysisProgressBar?.isHidden = true
        analysisProgressBar?.updateLayer()
    }
    
    func completeAnalysis(){ // Runs when the analysis has terminated
        analysis.isRunning = false

        guard let outputSplitVC = viewController.mainSplitViewController.outputsViewController.outputSplitViewController else { return }
        let plotTabViewIndex = outputSplitVC.viewerTabViewController.tabView.indexOfTabViewItem(withIdentifier: "plotsTabViewItem")
        outputSplitVC.viewerTabViewController.tabView.selectTabViewItem(at: plotTabViewIndex)
    }
    
    func changeType(indeterminate: Bool){
        if indeterminate {
            analysisProgressBar?.startAnimation(self)
        } else { analysisProgressBar?.stopAnimation(self) }
        analysisProgressBar?.isIndeterminate = indeterminate
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
    private func pctComplete(at currentState: Any?)->Double{
        let allRuns = analysis.runs.count
        let numComplete = currentState as? Int ?? 0
        return Double(numComplete)/Double(allRuns)
    }
}

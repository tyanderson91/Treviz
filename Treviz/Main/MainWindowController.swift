//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSToolbarDelegate {

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var showHidePanesControl: NSSegmentedControl!
    @IBOutlet weak var runButton: NSButton!
    var analysis: Analysis! {
        get { return contentViewController?.representedObject as? Analysis ?? nil }
        set { contentViewController?.representedObject = newValue }
    }
        
    var viewController: MainViewController! { return contentViewController as? MainViewController ?? nil}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        /** NSWindows loaded from the storyboard will be cascaded
         based on the original frame of the window in the storyboard.
         */
        shouldCascadeWindows = true
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //showHidePanesControl.setImage(NSImage(named: "smallSegmentedCell"), forSegment: 0)
        //showHidePanesControl.setImage(NSImage(named: "largeSegmentedCell"), forSegment: 1)
        //showHidePanesControl.setImage(NSImage(named: "smallSegmentedCell"), forSegment: 2)
        showHidePanesControl.setWidth(18, forSegment: 0)
        showHidePanesControl.setWidth(26, forSegment: 1)
        showHidePanesControl.setWidth(18, forSegment: 2)
        for i in 0...2 { // TODO: handle this all with restoration IDs
            if let isEnabled = UserDefaults().value(forKey: "mainSplitViewDiscloseButton\(i)Enabled") as? Bool {
                showHidePanesControl.setEnabled(isEnabled, forSegment: i)
            }
            if let isSelected = UserDefaults().value(forKey: "mainSplitViewDiscloseButton\(i)Selected") as? Bool {
                showHidePanesControl.setSelected(isSelected, forSegment: i)
            }
        }
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(self.completeAnalysis), name: .didFinishRunningAnalysis, object: nil)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    @IBAction func runAnalysisClicked(_ sender: Any) {
        if let asys = self.contentViewController?.representedObject as? Analysis {
            if asys.isRunning{
                runButton.title = "►"
                asys.isRunning = false
                DistributedNotificationCenter.default().post(name: .didFinishRunningAnalysis, object: nil)
            }
            else {
                runButton.title = "■"
                viewController.analysisProgressBar.doubleValue = analysis.pctComplete
                _ = asys.runAnalysis()
            }
        }
    }
    
    func processOutputs(){
        guard let textOutputView = viewController.textOutputView else {return}
        guard let plotViewController = viewController.mainSplitViewController.outputsViewController.outputSplitViewController?.plotViewController else { return }

        textOutputView.string = ""
        for curOutput in analysis.plots {
            curOutput.curTrajectory = analysis.traj
            if curOutput is TZTextOutput {
                let newText = (curOutput as! TZTextOutput).getText()
                textOutputView.textStorage?.append(newText)
                textOutputView.textStorage?.append(NSAttributedString(string: "\n\n"))
            }
            else if curOutput is TZPlot {
                plotViewController.createPlot(plot: curOutput as! TZPlot)
            }
        }
    }
    
    @objc func completeAnalysis(notification: Notification){ // Runs when the analysis has terminated
        analysis.isRunning = false
        runButton.title = "►"
        let progressBar = viewController.analysisProgressBar!
        progressBar.doubleValue = 0
        if analysis.returnCode > 0 { //Nominal successfull completion
            processOutputs()}
        else { //TODO: make different error codes for analysis run
            viewController.textOutputView?.string.append("Not enough inputs to make analysis fully defined!")
        }
    }
    
    @IBAction func conditionsClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "conditionsPopupSegue", sender: self)
        }
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "conditionsPopupSegue" {
            let conditionsVC = segue.destinationController as! ConditionsViewController
            conditionsVC.analysis = self.viewController.analysis
        }
    }
    
    
    @IBAction func showHidePanesClicked(_ sender: Any) {
        guard let button = sender as? NSSegmentedControl else {return}
        let curIndex = button.indexOfSelectedItem
        let shouldCollapse = !button.isSelected(forSegment: curIndex)
        let splitViewController = viewController.mainSplitViewController!
        _ = splitViewController.setSectionCollapse(shouldCollapse, forSection: curIndex)
        
        for i in 0...2 { // If there is one button left, disable it so user cannot collapse everything
            let enableButton = (splitViewController.numActiveViews == 1 && button.isSelected(forSegment: i)) ? false : true
            button.setEnabled(enableButton, forSegment: i)
            UserDefaults().set(button.isEnabled(forSegment: i), forKey: "mainSplitViewDiscloseButton\(i)Enabled")
            UserDefaults().set(button.isSelected(forSegment: i), forKey: "mainSplitViewDiscloseButton\(i)Selected")
        }
    }
}

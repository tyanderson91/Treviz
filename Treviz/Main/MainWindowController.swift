//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    //@IBOutlet weak var toolbar: NSToolbar!
    weak var toolbar: TZToolbar!
    @IBOutlet weak var showHidePanesControl: NSSegmentedControl!
    @IBOutlet weak var runButton: NSButton!
    /*var analysis: Analysis! {
        get { return (contentViewController as? TZViewController)?.analysis ?? nil }
        set { (contentViewController as? TZViewController)?.analysis = newValue }
    }*/
    var analysis = Analysis()
        
    var viewController: MainViewController! { return contentViewController as? MainViewController ?? nil}
    
    init?(coder: NSCoder, newAnalysis: Analysis, storyboard: NSStoryboard){
        self.analysis = newAnalysis
        super.init(coder: coder)
        /*contentViewController = storyboard.instantiateController(identifier: NSStoryboard.SceneIdentifier("mainViewController")) {
            aDecoder in MainViewController(coder: aDecoder, newAnalysis: newAnalysis)
        }*/
        //analysis = newAnalysis
        //shouldCascadeWindows = true
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBSegueAction func createMainViewController(_ coder: NSCoder) -> MainViewController? {
        let mainViewController = MainViewController(coder: coder)
        mainViewController?.analysis = analysis
        return mainViewController
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
        self.window!.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    func processOutputs(){
        guard let textOutputView = viewController.textOutputView else {return}
        guard let outputSplitVC = viewController.mainSplitViewController.outputsViewController.outputSplitViewController else { return }
        guard let plotViewController = outputSplitVC.plotViewController else { return }
        
        textOutputView.string = ""
        plotViewController.plotViews = []
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
        let plotTabViewIndex = outputSplitVC.viewerTabViewController.tabView.indexOfTabViewItem(withIdentifier: "plotterTabViewItem")
        outputSplitVC.viewerTabViewController.tabView.selectTabViewItem(at: plotTabViewIndex)
    }
    
    @objc func completeAnalysis(notification: Notification){ // Runs when the analysis has terminated
        analysis.isRunning = false
        runButton.title = "►"
        // toolbar.toggleAnalysisRun.title = "►"
        let progressBar = viewController.analysisProgressBar!
        progressBar.doubleValue = 0
        if analysis.returnCode > 0 { //Nominal successfull completion
            processOutputs()}
        else { //TODO: make different error codes for analysis run
            processOutputs()
            //viewController.textOutputView?.string.append("Not enough inputs to make analysis fully defined!")
        }
    }
}

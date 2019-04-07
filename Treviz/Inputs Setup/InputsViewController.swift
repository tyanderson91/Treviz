//
//  ViewController.swift
//  Treviz
//
//  View controller controls all information regarding analysis input states and settings
///
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class InputsViewController: ViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    //var parentSplitViewController : MainSplitViewController? = nil
    //@IBOutlet weak var tableView: NSTableView!    
    @IBOutlet weak var stack: CustomStackView!
    @IBOutlet weak var tableView: NSTableView!
    
    var tableViewController : ParamTableViewController!
    weak var initStateViewController: InitStateViewController!
    var params : [InputSetting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        //TODO: Fix stack loading issues
        // Load and install all the view controllers from our storyboard in the following order.
        stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "SettingsViewController")
        stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "EnvironmentViewController")
        stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "InitStateViewController")
        let initStateView = stack.views.last
        self.initStateViewController = initStateView?.nextResponder as? InitStateViewController
        
        tableViewController = ParamTableViewController(tableView: tableView)
        tableViewController.tableView = tableView
        tableViewController.initStateViewController = initStateViewController
        
        tableViewController.loadAllParams()
        tableView.reloadData()
        
    }
    
    @IBAction func runAnalysisPushed(_ sender: Any) {

        let curAnalysis = self.representedObject as! Analysis
        let newInputData = initStateViewController.getInputSettingData() as [Variable]
        let existingInputData = curAnalysis.analysisData.initVars
        //curAnalysis.analysisData.initVars = newInputData
        
        let newState = State(fromInputVars: newInputData)
        newState.variables[7] = Variable("mtot", named: "mass", symbol: "m", units: "mass", value: 10)
        curAnalysis.initialState = newState
        
        //let existingState = State(fromInputVars: existingInputData)
        //curAnalysis.initialState = State(fromInputVars: curAnalysis.analysisData.initVars)
        
        let parentSplitViewController = self.parent as! MainSplitViewController
        let mainView = parentSplitViewController.parent as! MainViewController
        curAnalysis.progressBar = mainView.analysisProgressBar
        let returnCode = curAnalysis.runAnalysis()
        print(returnCode)
        
        let y_end = curAnalysis.trajectory.last![2]
        let x_end = curAnalysis.trajectory.last![1]
        
        let outputSplitViewController = parentSplitViewController.outputsViewController?.outputSplitViewController
        let textOutputSplitViewItem = outputSplitViewController?.textOutputSplitViewItem
        let textOutputViewController = textOutputSplitViewItem?.viewController as! TextOutputsViewController
        let textOutputView = textOutputViewController.textView
        textOutputView?.string.append("Y end:\t\(y_end)\n")
        textOutputView?.string.append("X end:\t\(x_end)\n")

        
        //let outputTextView = textViewController.textView!
        //outputTextView.string.append("results!")
        
    }
    
    @IBAction func removeParamPressed(_ sender: Any) {//TODO: move to params table view controller
        let button = sender as! NSView
        tableViewController.removeParam(sender : button)
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


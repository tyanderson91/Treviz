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
    weak var initStateViewController: InitStateViewController!
    
    var params : [InputSetting] = []
    
    @IBAction func runAnalysisPushed(_ sender: Any) {

        let curAnalysis = self.representedObject as! Analysis
        
        curAnalysis.initialState = State(fromInputVars: curAnalysis.analysisData.initVars)
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
        
        self.loadAllParams()
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(tableView!, selector: #selector(paramWasSet(_:)), name: .didSetParam, object: nil)
        }
    
    @objc func loadAllParams(){
        let initStateParams = getParamSettings(from: initStateViewController.inputs)
        self.params.append(contentsOf: initStateParams)
    }
    
    @objc func paramWasSet(_ notification: Notification){
        let initStateParams = getParamSettings(from: initStateViewController.inputs)
        self.params.append(contentsOf: initStateParams)
    }
    
    
    func getParamSettings(from settings: [InputSetting], params: [InputSetting] = [])->[InputSetting]{
        var curParam = params
        for thisSetting in settings{
            if thisSetting.itemType != "var"{
                curParam = getParamSettings(from: thisSetting.children, params: curParam)
            }
            else if thisSetting.isParam {
                curParam.append(thisSetting)
            }
        }
        return curParam
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return params.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //initVariables = initState.getVariables()
        let thisVar = params[row]
        
        if tableColumn?.identifier.rawValue == "NameColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCellView"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = "\(thisVar.name) (\(thisVar.symbol)₀)"
                return thisCell
            }
        }
        else if tableColumn?.identifier.rawValue == "ValueColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ValueCellView"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = "\(thisVar.value)"
                return thisCell
            }
        }
        else if tableColumn?.identifier.rawValue == "UnitsColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "UnitsCellView"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = thisVar.units
                return thisCell
            }
        }
        return nil
    }
    
    private func tableView(_ tableView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let thisSetting = item as? InputSetting{
            if tableColumn?.identifier.rawValue == "Name Column"{return thisSetting.name}
            else if tableColumn?.identifier.rawValue == "ValueColumn"{return thisSetting.value}
            else if tableColumn?.identifier.rawValue == "UnitsColumn"{return thisSetting.units}
        }
        return nil
    }
            
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


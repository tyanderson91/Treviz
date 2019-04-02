//
//  ViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class InputsViewController: ViewController{//}, NSTableViewDataSource, NSTableViewDelegate {
    
    //var parentSplitViewController : MainSplitViewController? = nil
    //@IBOutlet weak var tableView: NSTableView!    
    @IBOutlet weak var stack: CustomStackView!
    
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
        
        //self.view.setFrameSize(NSSize.init(width: 200, height: 700))
        /*
        let t0 = Variable("t",named: "time",symbol:"t",units:"s")
        let x0 = Variable("x",named:"X pos",symbol:"x",units:"m")
        let y0 = Variable("y",named:"Y pos",symbol: "y",units:"m")
        let dx0 = Variable("dx",named:"X vel",symbol: "ẋ",units:"m/s")
        dx0.value = 10
        let dy0 = Variable("dy",named:"Y vel",symbol: "ẏ",units:"m/s")
        dy0.value = 10
        let m0 = Variable("m",named:"Mass",symbol:"m",units:"kg")
        m0.value = 10*/
        
        //tableView.reloadData()
        }
    
    /*
    func numberOfRows(in tableView: NSTableView) -> Int {
        return initState.variables.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //initVariables = initState.getVariables()
        let thisVar = initState.variables[row]
        
        if tableColumn?.identifier.rawValue == "nameColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameCell"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = "\(thisVar.name) (\(thisVar.symbol)₀)"
                return thisCell
            }
        }
        else if tableColumn?.identifier.rawValue == "valueColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "valueCell"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = "\(thisVar.value)"
                return thisCell
            }
        }
        else if tableColumn?.identifier.rawValue == "unitsColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "unitsCell"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = thisVar.units
                return thisCell
            }
        }
        return nil
        
    }
*/
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


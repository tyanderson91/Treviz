//
//  AddOutputViewController.swift
//  Treviz
//
//  Contains all of the reusable code between the various output setup wiew controller options
//
//  Created by Tyler Anderson on 9/28/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

enum outputLocation{
    case plot, text
}

class AddOutputViewController: BaseViewController, NSComboBoxDataSource { //TODO : Add a way to add variable selectors and associated logic
    
    @IBOutlet weak var conditionsComboBox: NSComboBox!
    @IBOutlet weak var addOutputButton: NSButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    @IBOutlet weak var includePlotCheckbox: NSButton!
    
    @IBOutlet weak var plotTypePopupButton: NSPopUpButton!
    var plotTypeSelector : (PlotType)->(Bool) = { _ in return true} //Chooses whether a given plot type applies to the current options
    var outputSetupViewController : OutputSetupViewController!
    var maxPlotID : Int { if self.analysis.plots.count == 0 { return 0 }
                            else { return self.analysis.plots.map( {return $0.id} ).max()! }
                        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.populatePlotTypes(_:)), name: .didLoadAppDelegate, object: nil)
        
        //setWidth(component: conditionsComboBox!, width: 100)
        //setWidth(component: plotTypePopupButton!, width: 100)
        //setWidth(component: includeTextCheckbox!, width: 100)
        //setWidth(component: includePlotCheckbox!, width: 100)

        // conditionsComboBox.constraints
        // Do view setup here.
    }
    
    /*
    func setWidth(component: Any, width: CGFloat){
        let conditionWidth = NSLayoutConstraint(item: component, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,multiplier: 1, constant: width)
        self.view.addConstraint(conditionWidth)
    }*/
    
    @objc func populatePlotTypes(_ notification: Notification) {
        var plotTypeNames : [String] = []
        let asys = self.representedObject as? Analysis
        if let allPlotTypes = asys?.plotTypes {
            for thisPlotType in allPlotTypes{
                if plotTypeSelector(thisPlotType) { plotTypeNames.append(thisPlotType.name) }
            }
            plotTypePopupButton.addItems(withTitles: plotTypeNames)
        }
    }
    
    func createOutput()-> TZOutput?{ //Should be overwritten by each subclass
        return nil
    }

    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
        setOutputType(type: .text)
    }
    @IBAction func includePlotCheckboxClicked(_ sender: Any) {
        setOutputType(type: .plot)
    }
    func setOutputType(type: outputLocation){ // Can override with specific rules for each plot type
        let textOn = self.includeTextCheckbox.state.rawValue
        let plotOn = self.includePlotCheckbox.state.rawValue
        if textOn + plotOn == 0 {
            switch type {
            case .text:
                self.includePlotCheckbox.state = NSControl.StateValue.on
            case .plot:
                self.includeTextCheckbox.state = NSControl.StateValue.on
            }
        }
    }
    
    @IBAction func plotTypeWasSelected(_ sender: Any) {
    }
    
    @IBAction func addOutputButtonClicked(_ sender: Any) {
        guard let newOutput = createOutput() else {return}
        if includePlotCheckbox.state == .on {
            let newPlot = TZPlot(id: maxPlotID+1, with: newOutput)
            outputSetupViewController.addOutput(newPlot)
        }
        if includeTextCheckbox.state == .on {
            let newText = TZTextOutput(id: maxPlotID+1, with: newOutput)
            outputSetupViewController.addOutput(newText)
        }
    }
    
    // MARK Conditions view controller
    @objc func conditionsChanged(_ notification: Notification){
        self.conditionsComboBox.reloadData()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let asys = analysis {
            let conditions = asys.conditions
            return conditions.count
        }
        return 0
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let asys = analysis { //TODO:: implement bindings
            let conditions = asys.conditions
            return conditions[index].name
        }
        return nil
    }
}

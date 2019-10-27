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

class AddOutputViewController: BaseViewController, NSComboBoxDataSource { //TODO : Add a way to add variable selectors and associated logic

    @IBOutlet weak var conditionsComboBox: NSComboBox!
    @IBOutlet weak var addOutputButton: NSButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    @IBOutlet weak var plotTypePopupButton: NSPopUpButton!
    var plotTypeSelector : (PlotType)->(Bool) = {(condition: PlotType)->(Bool) in return true} //Chooses whether a given plot type applis to the current options
    var outputSetupViewController : OutputSetupViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.populatePlotTypes(_:)), name: .didLoadAppDelegate, object: nil)
        // Do view setup here.
    }
    
    @objc func populatePlotTypes(_ notification: Notification) {
        var plotTypeNames : [String] = []
        let asys = self.representedObject as? Analysis
        if let allPlotTypes = asys?.plotTypes {
            for thisPlotType in allPlotTypes{
                if plotTypeSelector(thisPlotType) { plotTypeNames.append(thisPlotType.name)}
            }
            plotTypePopupButton.addItems(withTitles: plotTypeNames)
        }
    }
    
    func createPlot()-> TZPlot?{ //Should be overwritten by each subclass
        return nil
    }

    @IBAction func includeCheckboxButtonClicked(_ sender: Any) {
    }
    
    @IBAction func plotTypeWasSelected(_ sender: Any) {
    }
    
    
    @IBAction func addOutputButtonClicked(_ sender: Any) {
        guard let newPlot = createPlot() else {return}
        var newTextOutput : TZTextOutput?
        if includeTextCheckbox.state == .on {
            outputSetupViewController.maxPlotNum += 1 //TODO: make this a lookup, not a static variable
            newTextOutput = TZTextOutput(id: outputSetupViewController.maxPlotNum, with: newPlot)
        } else {newTextOutput = nil}
        
        outputSetupViewController.addOutput(newPlot)
        if newTextOutput != nil { outputSetupViewController.addOutput(newTextOutput!) }
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
        if let asys = analysis {
            let conditions = asys.conditions
            return conditions[index].name
        }
        return nil
    }
}

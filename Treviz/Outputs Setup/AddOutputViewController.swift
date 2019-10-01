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
    @IBOutlet weak var includeTextChecbox: NSButton!
    
    
    var outputSetupViewController : OutputSetupViewController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)
        // Do view setup here.
    }
    
    func createPlot()-> TZPlot?{ //Should be overwritten by each subclass
        return nil
    }
    @IBAction func includeCheckboxButtonClicked(_ sender: Any) {
    }
    
    @IBAction func addOutputButtonClicked(_ sender: Any) {
        guard let newPlot = createPlot() else {return}
        if outputSetupViewController != nil {
            outputSetupViewController?.allPlots.append(newPlot)
            NotificationCenter.default.post(name: .didAddPlot, object: nil)
        }
    }
    
    // MARK Conditions view controller
    @objc func conditionsChanged(_ notification: Notification){
        self.conditionsComboBox.reloadData()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let asys = analysis {
            let conditions = asys.conditions!
            return conditions.count
        }
        return 0
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let asys = analysis {
            let conditions = asys.conditions!
            return conditions[index].name
        }
        return nil
    }
    
}

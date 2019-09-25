//
//  ThreeAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class ThreeAxisOutputSetupViewController: BaseViewController, NSComboBoxDataSource {
    
    @IBOutlet weak var variable1DropDown: NSPopUpButton!
    @IBOutlet weak var variable2DropDown: NSPopUpButton!
    @IBOutlet weak var variable3DropDown: NSPopUpButton!
    @IBOutlet weak var includeTextCheckBox: NSButton!
    @IBOutlet weak var conditionsComboBox: NSComboBox!
    
    @IBOutlet weak var variablesGridView: NSGridView!
    var conditions : [Condition] = []

    var strongAddButtonLeadingConstraint1 : NSLayoutConstraint? = nil
    var strongAddButtonLeadingConstraint2 : NSLayoutConstraint? = nil
    
    @IBAction func plotTypeSelected(_ sender: Any) {
    }
    
    
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
        //didDisclose()
    }
    @IBAction func addOutputClicked(_ sender: Any) {
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Three Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let asys = analysis {
            conditions = asys.conditions!
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)
        
        // Do view setup here.
        /*
        let variableSelectorViewControllers = [VariableSelectorViewController(), VariableSelectorViewController(), VariableSelectorViewController()]
        // Add three subviews containing variable selectors for each dimension
        for i in [0,1,2]{
            let curController = variableSelectorViewControllers[i]
            self.addChild(curController)
            variablesGridView.cell(atColumnIndex: 1, rowIndex: i).contentView = curController.view
            curController.addVariables()
        }*/
    }
    

    @objc func conditionsChanged(_ notification: Notification){
        if let asys = analysis {
            conditions = asys.conditions!
        }
        self.conditionsComboBox.reloadData()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return conditions.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return conditions[index].name
    }

    
    
    /*
    override func didDisclose() {
        if !conditionStackView.isHidden && disclosureState == .open {
            addButtonLeadingConstraint2.isActive = false
            addButtonLeadingConstraint1 = strongAddButtonLeadingConstraint1
            addButtonLeadingConstraint1.isActive = true
        } else {
            addButtonLeadingConstraint1.isActive = false
            addButtonLeadingConstraint2 = strongAddButtonLeadingConstraint2
            addButtonLeadingConstraint2.isActive = true
        }
    }*/
}

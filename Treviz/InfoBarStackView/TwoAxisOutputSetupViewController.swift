//
//  TwoAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class TwoAxisOutputSetupViewController: BaseViewController, NSComboBoxDataSource {
    
    @IBOutlet weak var variable1DropDown: NSPopUpButton!
    @IBOutlet weak var variable2DropDown: NSPopUpButton!
    @IBOutlet weak var variable3DropDown: NSPopUpButton!
    @IBOutlet weak var plotTypeDropDown: NSPopUpButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var conditionsComboBox: NSComboBox!
    @IBOutlet weak var variableGridView: NSGridView!
    
    var conditions : [Condition] = []

    
    @IBOutlet weak var plottingStackView: NSStackView!
    var strongAddButtonLeadingConstraint1 : NSLayoutConstraint? = nil
    var strongAddButtonLeadingConstraint2 : NSLayoutConstraint? = nil
    
    @IBAction func plotTypeSelected(_ sender: Any) {
    }
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
        switch includeTextCheckbox.state {
        case .on:
            gridView.showHideCols(.show, index: [2])
        case .off:
            gridView.showHideCols(.hide, index: [2])
        default:
            print("Unknown state")
        }
    }
    @IBAction func addOutputClicked(_ sender: Any) {
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Two Axis", comment: "") }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let asys = analysis {
            conditions = asys.conditions!
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)
    
        /*
        let variableSelectorViewControllers = [VariableSelectorViewController(), VariableSelectorViewController(), VariableSelectorViewController()]
        // Add three subviews containing variable selectors for each dimension
        for i in [0,1,2]{
            let curController = variableSelectorViewControllers[i]
            self.addChild(curController)
            variableGridView.cell(atColumnIndex: 1, rowIndex: i).contentView = curController.view
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
    
    
    override func didDisclose() {//TODO : collapse grid columns (animated) when view is collapsed
        /*
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 5
        if disclosureState == .open {
            //gridView.isHidden = false
            do {try gridView.showHideCols(.show, index: [0,1,2])} catch {}
        } else {
            //gridView.isHidden = true
            do {try gridView.showHideCols(.hide, index : [0,1,2])} catch {}
        }
        NSAnimationContext.endGrouping()
    */}
}


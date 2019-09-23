//
//  MonteCarloOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/20/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class MonteCarloOutputSetupViewController: BaseViewController, NSComboBoxDataSource {
    
    
    @IBOutlet weak var conditionComboBox: NSComboBox!
    var conditions : [Condition] = []
    
    @IBAction func addOutputClicked(_ sender: Any) {
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Monte-Carlo Run Statistics", comment: "") }
        
    override func viewDidLoad() {
        if let asys = analysis {
            conditions = asys.conditions!
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)
        super.viewDidLoad()
        didDisclose()
    }
    

    @objc func conditionsChanged(_ notification: Notification){
        if let asys = analysis {
            conditions = asys.conditions!
        }
        self.conditionComboBox.reloadData()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return conditions.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return conditions[index].name
    }

    
    /*
    override func didDisclose() {
        if disclosureState == .open {
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

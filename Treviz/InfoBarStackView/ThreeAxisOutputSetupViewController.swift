//
//  ThreeAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class ThreeAxisOutputSetupViewController: BaseViewController {
    
    @IBOutlet weak var variable1DropDown: NSPopUpButton!
    @IBOutlet weak var variable2DropDown: NSPopUpButton!
    @IBOutlet weak var variable3DropDown: NSPopUpButton!
    @IBOutlet weak var includeTextCheckBox: NSButton!
 
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
        // Do view setup here.
        //didDisclose()
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

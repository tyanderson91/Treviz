//
//  SettingStackViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class SingleAxisOutputSetupViewController: BaseViewController {

    @IBOutlet weak var variableDropDown: NSPopUpButton!
    @IBOutlet weak var plotTypeDropDown: NSPopUpButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    
    @IBAction func addOutputClicked(_ sender: Any) {
    }
    @IBAction func plotTypeSelected(_ sender: Any) {
    }
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
    }
    
    
    override func headerTitle() -> String { return NSLocalizedString("Single Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

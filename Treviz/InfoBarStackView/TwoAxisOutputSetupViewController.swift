//
//  TwoAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class TwoAxisOutputSetupViewController: BaseViewController {
    
    
    @IBOutlet weak var variable1DropDown: NSPopUpButton!
    @IBOutlet weak var variable2DropDown: NSPopUpButton!
    @IBOutlet weak var variable3DropDown: NSPopUpButton!
    @IBOutlet weak var plotTypeDropDown: NSPopUpButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    
    @IBAction func plotTypeSelected(_ sender: Any) {
    }
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
    }
    @IBAction func addOutputClicked(_ sender: Any) {
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Two Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}


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
    @IBOutlet weak var gridView: CollapsibleGridView!
    
    @IBAction func addOutputClicked(_ sender: Any) {
    }
    @IBAction func plotTypeSelected(_ sender: Any) {
    }
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
        switch includeTextCheckbox.state{
        case .on:
            print("on")
            gridView.showHideCols(.show, index: [2])
        case .off:
            print("off")
            gridView.showHideCols(.hide, index: [2])
        default:
            print("nada")
        }
    }
    
    
    override func headerTitle() -> String { return NSLocalizedString("Single Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //didDisclose()
    }
    
    //override func didDisclose() {
    //    if disclosureState == .open {
    //
     //   } else {
     //
     //   }
    //}
    
}

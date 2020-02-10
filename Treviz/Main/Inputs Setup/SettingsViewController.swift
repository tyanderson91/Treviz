//
//  SettingsViewController.swift
//  Treviz
//
//  View controller that sets run settings (e.g. propagator type, timestep, physics engine, gravity type)
//
//  Created by Tyler Anderson on 3/27/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class SettingsViewController: BaseViewController {

    @IBOutlet weak var terminalConditionPopupButton: NSPopUpButton!
    let terminalConditionArrayController = NSArrayController()
    
    override func headerTitle() -> String { return NSLocalizedString("Settings", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        terminalConditionArrayController.content = analysis?.conditions
        terminalConditionPopupButton.bind(.content, to: terminalConditionArrayController, withKeyPath: "arrangedObjects", options: nil)
        terminalConditionPopupButton.bind(.contentValues, to: terminalConditionArrayController, withKeyPath: "arrangedObjects.name", options: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didLoadAnalysisData(_:)), name: .didLoadAnalysisData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didLoadAnalysisData(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRemoveCondition(_:)), name: .didRemoveCondition, object: nil)
        // Do view setup here.
    }
    
    @objc func didRemoveCondition(_ notification: Notification){
        terminalConditionArrayController.content = analysis!.conditions
        if analysis.terminalConditions == nil {return}
        if !analysis.conditions.contains(analysis.terminalConditions) {
            analysis.terminalConditions = nil
            terminalConditionPopupButton.bind(.selectedObject, to: analysis!, withKeyPath: "terminalConditions", options: nil)
        }
    }
    @objc func didLoadAnalysisData(_ notification: Notification){
        terminalConditionArrayController.content = analysis!.conditions
        terminalConditionPopupButton.bind(.selectedObject, to: analysis!, withKeyPath: "terminalConditions", options: nil)
    }
    
}

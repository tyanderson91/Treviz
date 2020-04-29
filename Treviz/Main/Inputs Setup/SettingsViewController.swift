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
    private var terminalConditionCandidates: [Condition] {
        analysis.conditions.filter { !$0.containsGlobalCondition() }
    }
    
    override func getHeaderTitle() -> String { return NSLocalizedString("Settings", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //terminalConditionArrayController.content = analysis?.conditions
        //terminalConditionPopupButton.bind(.content, to: terminalConditionArrayController, withKeyPath: "arrangedObjects", options: nil)
        //terminalConditionPopupButton.bind(.contentValues, to: terminalConditionArrayController, withKeyPath: "arrangedObjects.name", options: nil)
        if analysis != nil {
            //terminalConditionPopupButton.bind(.selectedObject, to: analysis!, withKeyPath: "terminalCondition")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeCondition1(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeCondition1(_:)), name: .didRemoveCondition, object: nil)
        
        if analysis != nil {
            //terminalConditionArrayController.content = analysis!.conditions
            //terminalConditionPopupButton.bind(.selectedObject, to: analysis!, withKeyPath: "terminalCondition", options: nil)
        }
        // Do view setup here.
        getPopupOptions()
    }
    
    @objc func didChangeCondition(_ notification: Notification){
        terminalConditionArrayController.content = analysis!.conditions
        if analysis.terminalCondition == nil {return}
        if !analysis.conditions.contains(analysis.terminalCondition) {
            analysis.terminalCondition = nil
            terminalConditionPopupButton.bind(.selectedObject, to: analysis!, withKeyPath: "terminalCondition", options: nil)
        }
    }
    
    
    @objc func didChangeCondition1(_ notification: Notification){
        if analysis.terminalCondition == nil {}
        else if !analysis.conditions.contains(analysis.terminalCondition) {
            analysis.terminalCondition = nil
        }
        getPopupOptions()
        setSelection()
    }
    // MARK: Non-binding implementation
    @IBAction func didChangeSelection(_ sender: Any) {
        if let curCondition = analysis.conditions.first(where: { $0.name == terminalConditionPopupButton.titleOfSelectedItem }) {
            analysis.terminalCondition = curCondition
        }
    }
    
    private func setSelection(){
        if let curCondition = analysis.terminalCondition {
            terminalConditionPopupButton.selectItem(withTitle: curCondition.name)
        } else {terminalConditionPopupButton.selectItem(at: -1)}
    }
    
    private func getPopupOptions(){
        let menuItemNames: [String] = terminalConditionCandidates.compactMap { $0.name }
        terminalConditionPopupButton.removeAllItems()
        terminalConditionPopupButton.addItems(withTitles: menuItemNames)
        setSelection()
    }
}

//
//  PhysicsViewController.swift
//  Treviz
//
//  View controller that sets run settings (e.g. propagator type, timestep, physics engine, gravity type)
//
//  Created by Tyler Anderson on 3/27/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class PhysicsViewController: PhasedViewController {

    @IBOutlet weak var terminalConditionPopupButton: NSPopUpButton!
    private var terminalConditionCandidates: [Condition] {
        analysis.conditions.filter { !$0.containsGlobalCondition() }
    }
    
    override func getHeaderTitle() -> String { return NSLocalizedString("Physics Model", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if analysis != nil {
        }
        getPopupOptions()
    }
    
    @IBAction func didChangeSelection(_ sender: Any) {
        if let curCondition = analysis.conditions.first(where: { $0.name == terminalConditionPopupButton.titleOfSelectedItem }) {
            phase.terminalCondition = curCondition
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

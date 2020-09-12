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

    @IBOutlet weak var physicsSelectorPopupButton: NSPopUpButton!

    let physicsModels = PhysicsModel.allPhysicsModels
    
    override func getHeaderTitle() -> String { return NSLocalizedString("Physics Model", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if analysis != nil {
        }
        for thisPhysicsModel in physicsModels {
            let menuItem = NSMenuItem.init(title: thisPhysicsModel.name, action: nil, keyEquivalent: "")
            menuItem.image = thisPhysicsModel.icon
            physicsSelectorPopupButton.menu?.addItem(menuItem)
        }
        physicsSelectorPopupButton.bezelStyle = .texturedSquare
    }
    
    @IBAction func didChangeSelection(_ sender: Any) {
    }
    
    private func setSelection(){
    }
    
    private func getPopupOptions(){
    }
}

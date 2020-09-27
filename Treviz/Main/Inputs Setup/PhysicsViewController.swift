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
    var curModelParam: EnumGroupParam { return phase.physicsModelParam }
    var inputsViewController: InputsViewController? {return parent as? InputsViewController}

    override func getHeaderTitle() -> String { return NSLocalizedString("Physics Model", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if analysis != nil {
        }
        for thisPhysicsModel in physicsModels {
            let menuItem = NSMenuItem.init(title: thisPhysicsModel.valuestr, action: nil, keyEquivalent: "")
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
    @IBAction func didSetPhysicsModelParam(_ sender: Any) {
        guard let senderButton = sender as? ParameterSelectorButton else { return }
        if senderButton.state == .off {
            analysis.enableParam(param: curModelParam)
        } else { analysis.disableParam(param: curModelParam) }
        inputsViewController?.reloadParams()
    }
}

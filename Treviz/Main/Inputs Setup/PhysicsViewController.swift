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

    @IBOutlet weak var physicsSelectorPopupButton: ParamValuePopupView!

    @IBOutlet weak var physicsModelRunVariantButton: ParameterSelectorButton!
    
    let physicsModels = PhysicsModel.allPhysicsModels
    var curModelParam: EnumGroupParam { return phase.physicsModelParam }
    var curPhysicsModel: PhysicsModel? { return curModelParam.value as? PhysicsModel }
    var usesInertiaParam: BoolParam { return phase.usesVehicleInertiaParam }
    //var inputsViewController: InputsViewController? {return parent as? InputsViewController}

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
        //let newModel = curPhysicsModel?.valuestr
        physicsSelectorPopupButton.parameter = curModelParam
        physicsModelRunVariantButton.param = curModelParam
        
        self.paramValueViews = [physicsSelectorPopupButton]
        //physicsSelectorPopupButton.selectItem(withTitle: curPhysicsModel?.valuestr ?? "")
    }
    
    @IBAction func didChangeSelection(_ sender: Any) {
        if let thisSelector = sender as? ParamValueView {
            guard let param = thisSelector.parameter else {return}
            let valName = thisSelector.stringValue
            param.setValue(to: thisSelector.stringValue)
            inputsViewController?.updateParamValueView(for: param.id)
        }
    }
    
    private func setSelection(){
    }
    
    private func getPopupOptions(){
    }
    
    @IBAction func didSetParamValue(_ sender: Any){
        inputsViewController?.reloadParams()
    }
    
    @IBAction func didSetParameter(_ sender: Any) {
        guard let senderButton = sender as? ParameterSelectorButton else { return }

        var setOn = false
        if senderButton.state == .on {
            setOn = true
        }
        
        if let paramToSet = senderButton.param {
            analysis.setParam(param: paramToSet, setOn: setOn)
            inputsViewController?.updateParamValueView(for: paramToSet.id)
        }
    }
}

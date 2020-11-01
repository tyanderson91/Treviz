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
    
    let physicsModels = PhysicsModel.allPhysicsModels
    var curModelParam: EnumGroupParam { return phase.physicsSettings.physicsModelParam }
    var curPhysicsModel: PhysicsModel? { return curModelParam.value as? PhysicsModel }
    var usesInertiaParam: BoolParam { return phase.physicsSettings.vehiclePointMassParam }
    var physicsSettings: PhysicsSettings { return phase.physicsSettings }
    var staticCentralBodyImage: NSImage? {
        get {let mainVC = inputsViewController?.parent as? MainSplitViewController
        let vizVC = mainVC?.outputsViewController.outputSplitViewController?.viewerTabViewController.visualizerTabViewItem.viewController as? VisualizerViewController
            return vizVC?.placeholderImageView.image
    }
    set {let mainVC = inputsViewController?.parent as? MainSplitViewController
        let vizVC = mainVC?.outputsViewController.outputSplitViewController?.viewerTabViewController.visualizerTabViewItem.viewController as? VisualizerViewController
            vizVC?.placeholderImageView.image = newValue
        }
    }
    
    //MARK: Param views
    @IBOutlet weak var physicsSelectorPopupButton: ParamValuePopupView!
    @IBOutlet weak var physicsModelRunVariantButton: RunVariantEnableButton!
    @IBOutlet weak var centralBodyRunVariantButton: RunVariantEnableButton!
    @IBOutlet weak var includeRotationRunVariantButton: RunVariantEnableButton!
    @IBOutlet weak var baseCsysRunVariantButton: RunVariantEnableButton!
    @IBOutlet weak var gravityRunVariantButton: RunVariantEnableButton!
    @IBOutlet weak var atmosphereRunVariantButton: RunVariantEnableButton!
    @IBOutlet weak var useVehicleInertiaRunVariantButton: RunVariantEnableButton!
    
    @IBOutlet weak var centralBodyParamPopupButton: ParamValuePopupView!
    
    
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
        
        for thisBody in CelestialBody.allBodies {
            let menuItem = NSMenuItem.init(title: thisBody.valuestr, action: nil, keyEquivalent: "")
            menuItem.image = thisBody.icon
            centralBodyParamPopupButton.menu?.addItem(menuItem)
        }
        physicsSelectorPopupButton.bezelStyle = .texturedSquare
        centralBodyParamPopupButton.bezelStyle = .texturedSquare
        //let newModel = curPhysicsModel?.valuestr
        physicsSelectorPopupButton.parameter = curModelParam
        physicsModelRunVariantButton.param = curModelParam
        centralBodyParamPopupButton.parameter = physicsSettings.centralBodyParam
        centralBodyRunVariantButton.param = physicsSettings.centralBodyParam
        
        self.paramValueViews = [physicsSelectorPopupButton, centralBodyParamPopupButton]
        for thisParam in paramValueViews {
            thisParam.update()
        }
        //physicsSelectorPopupButton.selectItem(withTitle: curPhysicsModel?.valuestr ?? "")
    }
    
    @IBAction func didChangeSelection(_ sender: Any) {
        if let thisSelector = sender as? ParamValueView {
            guard let param = thisSelector.parameter else {return}
            param.setValue(to: thisSelector.stringValue)
            inputsViewController?.updateParamValueView(for: param.id)
            
            if thisSelector.identifier!.rawValue == "centralBodyPopup" {
                guard let cbody = (param as? EnumGroupParam)?.value as? CelestialBody else { return }
                if let cbodyImage = NSImage(named: cbody.name) {
                    staticCentralBodyImage = cbodyImage
                } else { staticCentralBodyImage = NSImage(named: "Default_cbody")}
            }
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
        guard let senderButton = sender as? RunVariantEnableButton else { return }

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

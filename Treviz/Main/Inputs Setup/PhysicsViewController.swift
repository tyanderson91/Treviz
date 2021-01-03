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
    @IBOutlet weak var useVehicleInertiaCheckbox: ParamValueCheckboxView!
    
    @IBOutlet weak var centralBodyParamPopupButton: ParamValuePopupView!
    
    
    override func getHeaderTitle() -> String { return NSLocalizedString("Physics Model", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        physicsSelectorPopupButton.parameter = curModelParam
        physicsModelRunVariantButton.param = curModelParam
        centralBodyParamPopupButton.parameter = physicsSettings.centralBodyParam
        centralBodyRunVariantButton.param = physicsSettings.centralBodyParam
        centralBodyParamPopupButton.didUpdate = {
            guard let cbody = self.physicsSettings.centralBodyParam.value as? CelestialBody else { return }
            if let cbodyImage = NSImage(named: cbody.name) {
                self.staticCentralBodyImage = cbodyImage
            } else { self.staticCentralBodyImage = NSImage(named: "Default_cbody")}
        }
        useVehicleInertiaRunVariantButton.param = physicsSettings.vehiclePointMassParam
        useVehicleInertiaCheckbox.parameter = physicsSettings.vehiclePointMassParam
    }
}

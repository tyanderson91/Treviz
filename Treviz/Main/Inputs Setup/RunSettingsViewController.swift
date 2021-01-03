//
//  RunSettingsViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/5/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

class RunSettingsViewController: PhasedViewController {

    // Min, Max, and Default timestep elements
    @IBOutlet weak var defaultTimestepTextBox: ParamValueTextField!
    @IBOutlet weak var minTimestepTextBox: ParamValueTextField!
    @IBOutlet weak var maxTimestepTextBox: ParamValueTextField!
    @IBOutlet weak var adaptiveTimestepParamCheckbox: RunVariantEnableButton!
    @IBOutlet weak var defaultTimestepParamCheckbox: RunVariantEnableButton!
    @IBOutlet weak var minTimestepParamCheckbox: RunVariantEnableButton!
    @IBOutlet weak var maxTimestepParamCheckbox: RunVariantEnableButton!
    @IBOutlet weak var defaultTimestepUnitLabel: NSTextField!
    @IBOutlet weak var minTimestepUnitLabel: NSTextField!
    @IBOutlet weak var maxTimestepUnitLabel: NSTextField!
    @IBOutlet weak var propagatorParamCheckbox: RunVariantEnableButton!
    
    @IBOutlet weak var allTimestepsStackView: CollapsibleStackView!
    
    // Other UI elements
    @IBOutlet weak var propagatorPopupButton: ParamValuePopupView!
    @IBOutlet weak var adaptiveTimestepCheckbox: ParamValueCheckboxView!
    @IBOutlet weak var minTimeStepNumberFormatter: NumberFormatter!
    @IBOutlet weak var maxTimeStepNumberFormatter: NumberFormatter!
    @IBOutlet weak var defaultTimeStepNumberFormatter: NumberFormatter!
    
    var runSettings: TZRunSettings { return phase.runSettings }
        
    override func getHeaderTitle() -> String { return NSLocalizedString("Run Settings", comment: "") }

    override func viewDidLoad() {
        super.viewDidLoad()
        maxTimeStepNumberFormatter.maximumFractionDigits = 10
        minTimeStepNumberFormatter.maximumFractionDigits = 10
        defaultTimeStepNumberFormatter.maximumFractionDigits = 10
        adaptiveTimestepParamCheckbox.param = runSettings.useAdaptiveTimestep
        adaptiveTimestepCheckbox.parameter = runSettings.useAdaptiveTimestep
        defaultTimestepParamCheckbox.param = runSettings.defaultTimestep
        defaultTimestepTextBox.parameter = runSettings.defaultTimestep
        minTimestepParamCheckbox.param = runSettings.minTimestep
        minTimestepTextBox.parameter = runSettings.minTimestep
        maxTimestepParamCheckbox.param = runSettings.maxTimestep
        maxTimestepTextBox.parameter = runSettings.maxTimestep
        propagatorParamCheckbox.param = runSettings.propagatorType
        propagatorPopupButton.parameter = runSettings.propagatorType
        setRunSettingUI()
        adaptiveTimestepCheckbox.didUpdate = didSetAdaptiveTimestep
        minTimestepTextBox.didUpdate = didSetMinMaxTimestep
        maxTimestepTextBox.didUpdate = didSetMinMaxTimestep
        didSetMinMaxTimestep()
    }
        
    private func setRunSettingUI() {
        adaptiveTimestepCheckbox.update()
        if runSettings.useAdaptiveTimestep.value {
            allTimestepsStackView.showHideViews(.hide, index: [0])
            allTimestepsStackView.showHideViews(.show, index: [1,2])
            
            minTimestepTextBox.stringValue = maxTimeStepNumberFormatter.string(from: NSNumber(value: runSettings.minTimestep.value)) ?? ""
            maxTimestepTextBox.stringValue = maxTimeStepNumberFormatter.string(from: NSNumber(value: runSettings.maxTimestep.value)) ?? ""
        } else {
            allTimestepsStackView.showHideViews(.show, index: [0])
            allTimestepsStackView.showHideViews(.hide, index: [1,2])
            
            let defNumber = NSNumber(value: runSettings.defaultTimestep.value)
            let numStr = maxTimeStepNumberFormatter.string(from: defNumber)
            defaultTimestepTextBox.stringValue = numStr ?? ""
        }
    }
    
    func didSetAdaptiveTimestep() {
        switch adaptiveTimestepCheckbox.state {
        case .on:
            defaultTimestepParamCheckbox.state = .off
            didSetParam(defaultTimestepParamCheckbox)
        case .off, .mixed:
            minTimestepParamCheckbox.state = .off
            maxTimestepParamCheckbox.state = .off
            didSetParam(minTimestepParamCheckbox)
            didSetParam(maxTimestepParamCheckbox)
        default:
            runSettings.useAdaptiveTimestep.value = false
        }
        setRunSettingUI()
    }
    
    func didSetMinMaxTimestep() {
        minTimeStepNumberFormatter.maximum = NSNumber(value: runSettings.maxTimestep.value)
        maxTimeStepNumberFormatter.minimum = NSNumber(value: runSettings.minTimestep.value)
    }
}

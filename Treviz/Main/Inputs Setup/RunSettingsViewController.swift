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
    @IBOutlet weak var timeStepNumberFormatter: NumberFormatter!
    
    var runSettings: TZRunSettings { return phase.runSettings }
        
    override func getHeaderTitle() -> String { return NSLocalizedString("Run Settings", comment: "") }

    override func viewDidLoad() {
        super.viewDidLoad()
        timeStepNumberFormatter.maximumFractionDigits = 10
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
    }
    
    /*
    @IBAction func propagatorChanged(_ sender: Any) {
        guard let senderButton = sender as? NSPopUpButton else { return }
        
        switch senderButton.selectedItem?.title {
        case "Explicit":
            runSettings.propagatorType.value = PropagatorType.explicit
        case "Runge-Kutta":
            runSettings.propagatorType.value = PropagatorType.rungeKutta4
        default:
            runSettings.propagatorType.value = PropagatorType.explicit
        }
    }*/
    
    private func setRunSettingUI() {
        /*switch (runSettings.propagatorType.value as! PropagatorType) {
        case .explicit:
            propagatorPopupButton.selectItem(withTitle: "Explicit")
        case .rungeKutta4:
            propagatorPopupButton.selectItem(withTitle: "Runge-Kutta")
        }*/
        adaptiveTimestepCheckbox.update()
        if runSettings.useAdaptiveTimestep.value {
            allTimestepsStackView.showHideViews(.hide, index: [0])
            allTimestepsStackView.showHideViews(.show, index: [1,2])
            
            minTimestepTextBox.stringValue = timeStepNumberFormatter.string(from: NSNumber(value: runSettings.minTimestep.value)) ?? ""
            maxTimestepTextBox.stringValue = timeStepNumberFormatter.string(from: NSNumber(value: runSettings.maxTimestep.value)) ?? ""
        } else {
            allTimestepsStackView.showHideViews(.show, index: [0])
            allTimestepsStackView.showHideViews(.hide, index: [1,2])
            
            let defNumber = NSNumber(value: runSettings.defaultTimestep.value)
            let numStr = timeStepNumberFormatter.string(from: defNumber)
            defaultTimestepTextBox.stringValue = numStr ?? ""
        }
    }
    
    @IBAction func didSetParams(_ sender: Any) {
        didSetParam(sender as! RunVariantEnableButton)
    }
    
    @IBAction func didSetAdaptiveTimestep(_ sender: Any) {
        guard let checkbox = sender as? NSButton else { return }
        switch checkbox.state {
        case .on:
            runSettings.useAdaptiveTimestep.value = true
            defaultTimestepParamCheckbox.state = .off
            //didSetParam(defaultTimestepParamCheckbox)
        case .off, .mixed:
            runSettings.useAdaptiveTimestep.value = false
            minTimestepParamCheckbox.state = .off
            maxTimestepParamCheckbox.state = .off
            //didSetParam(minTimestepParamCheckbox)
            //didSetParam(maxTimestepParamCheckbox)
        default:
            runSettings.useAdaptiveTimestep.value = false
        }
        inputsViewController?.updateParamValueView(for: phase.runSettings.useAdaptiveTimestep.id)
        setRunSettingUI()
    }
    /*
    @IBAction func didSetTimestep(_ sender: Any) {
        guard let textBox = sender as? NSTextField,
            let inputNum = VarValue(textBox.stringValue)
            else { return }
        
        do {
            switch textBox.identifier?.rawValue {
            case "defaultTimeStepBox":
                try runSettings.setDefaultTimeStep(inputNum)
            case "minTimeStepBox":
                try runSettings.setMinTimeStep(inputNum)
            case "maxTimeStepBox":
                try runSettings.setMaxTimeStep(inputNum)
            default:
                return
            }
        } catch { phase.analysis.logMessage(error.localizedDescription) }
        setRunSettingUI()
    }*/
}

//
//  RunSettingsViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/5/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

class RunSettingsViewController: PhasedViewController {

    @IBOutlet weak var propagatorPopupButton: NSPopUpButton!
    @IBOutlet weak var firstTimestepTextBox: NSTextField!
    @IBOutlet weak var secondTimestepTextBox: NSTextField!
    @IBOutlet weak var adaptiveTimestepCheckbox: NSButton!
    @IBOutlet weak var firstTimestepLabel: NSTextField!
    @IBOutlet weak var firstTimestepUnitLabel: NSTextField!
    @IBOutlet weak var secondTimestepUnitLabel: NSTextField!
        override func getHeaderTitle() -> String { return NSLocalizedString("Run Settings", comment: "") }
    @IBOutlet weak var box1NumberFormatter: NumberFormatter!
    @IBOutlet weak var box2NumberFormatter: NumberFormatter!
    @IBOutlet weak var maxTimestepStackView: NSStackView!
    var runSettings: TZRunSettings { return phase.runSettings }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRunSettingUI()
        // Do view setup here.
    }
    
    @IBAction func propagatorChanged(_ sender: Any) {
        guard let senderButton = sender as? NSPopUpButton else { return }
        switch senderButton.selectedItem?.title {
        case "Explicit":
            runSettings.propagatorType = .explicit
        case "Runge-Kutta":
            runSettings.propagatorType = .rungeKutta4
        default:
            runSettings.propagatorType = .explicit
        }
    }
    
    private func setRunSettingUI() {
        switch runSettings.propagatorType {
        case .explicit:
            propagatorPopupButton.selectItem(withTitle: "Explicit")
        case .rungeKutta4:
            propagatorPopupButton.selectItem(withTitle: "Runge-Kutta")
        }
        if runSettings.useAdaptiveTimestep {
            maxTimestepStackView.isHidden = false
            adaptiveTimestepCheckbox.state = .on
            firstTimestepTextBox.stringValue = box1NumberFormatter.string(from: NSNumber(value: runSettings.minTimestep)) ?? ""
            secondTimestepTextBox.stringValue = box2NumberFormatter.string(from: NSNumber(value: runSettings.maxTimestep)) ?? ""
            firstTimestepLabel.stringValue = "Min timestep:"
        } else {
            maxTimestepStackView.isHidden = true
            adaptiveTimestepCheckbox.state = .off
            let defNumber = NSNumber(value: runSettings.defaultTimestep)
            let numStr = box1NumberFormatter.string(from: defNumber)
            firstTimestepTextBox.stringValue = numStr ?? ""
            firstTimestepLabel.stringValue = "Default timestep:"
        }
    }
    
    @IBAction func didSetAdaptiveTimestep(_ sender: Any) {
        guard let checkbox = sender as? NSButton else { return }
        switch checkbox.state {
        case .on:
            runSettings.useAdaptiveTimestep = true
        case .off:
            runSettings.useAdaptiveTimestep = false
        default:
            runSettings.useAdaptiveTimestep = false
        }
        setRunSettingUI()
    }
    
    @IBAction func didSetTimestep(_ sender: Any) {
        guard let textBox = sender as? NSTextField,
            let inputNum = VarValue(textBox.stringValue)
            else { return }
        
        switch textBox.identifier?.rawValue {
        case "timestepBox1":
            if runSettings.useAdaptiveTimestep {
                runSettings.minTimestep = inputNum
            } else { runSettings.defaultTimestep = inputNum }
        case "timestepBox2":
            runSettings.maxTimestep = inputNum
        default:
            return
        }
        setRunSettingUI()
    }
}

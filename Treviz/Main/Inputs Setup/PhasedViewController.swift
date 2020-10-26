//
//  PhasedViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/30/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 A Phase View Controller is a view controller that displays an input setting dependent on the analysis phase. It contains a few functions and variables useful for displaying, updating, and passing around phase information
 */
class PhasedViewController: BaseViewController {

    var phase: TZPhase!
    var inputsViewController: InputsViewController? { return self.parent as? InputsViewController }
    var paramValueViews: [ParamValueView] = []
    var paramSelectorViews: [ParameterSelectorButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis, phase curPhase: TZPhase) {
        self.init(coder: coder, analysis: curAnalysis)
        phase = curPhase
    }
    
    func didSetParam(_ sender: ParameterSelectorButton) {
        guard let representedParam = sender.param else { return }
        switch sender.state {
        case .on:
            analysis.enableParam(param: representedParam )
        case .off:
            analysis.disableParam(param: representedParam )
        default:
            return
        }
        if inputsViewController != nil { inputsViewController?.reloadParams() }
    }
    
    func containsParamView(for id: VariableID)->Bool{
        return paramValueViews.contains(where: {$0.parameter.id == id})
    }
    func paramView(for id: VariableID)->ParamValueView? {
        if let thisView = paramValueViews.first(where: {$0.parameter.id == id}) {
            return thisView
        } else {return nil}
    }
}

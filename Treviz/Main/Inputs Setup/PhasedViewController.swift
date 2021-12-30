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
extension NSView {
    /**
     Returns a list of all the base-level views
     */
    func recurseGetSubviews()->[NSView] {
        let curSubviews = self.subviews
        if curSubviews.count > 0 {
            var viewsOut = [NSView]()
            for curSubview in curSubviews {
                let newViews = curSubview.recurseGetSubviews()
                viewsOut.append(contentsOf: newViews)
            }
            return viewsOut
        } else { return [self] }
    }
}


class PhasedViewController: BaseViewController {

    var phase: TZPhase!
    var inputsViewController: InputsViewController? { return self.parent as? InputsViewController }
    var paramValueViews: [ParamValueView] = []
    var paramSelectorViews: [RunVariantEnableButton] = []

    /**
     Automatically called to update param value based on the text in the control
     */
    @objc func didChangeParamValue(_ sender: Any) {
        if let thisSelector = sender as? ParamValueView {
            guard let param = thisSelector.parameter else {return}
            param.setValue(to: thisSelector.stringValue)
            inputsViewController?.updateParamValueView(for: param.id)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let baseSubViews = self.view.recurseGetSubviews()
        paramSelectorViews = baseSubViews.filter({$0 is RunVariantEnableButton }) as! [RunVariantEnableButton]
        paramValueViews = baseSubViews.filter({$0 is ParamValueView}) as! [ParamValueView]
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        for thisParamView in paramValueViews {
            thisParamView.update()
            if let thisControl = thisParamView as? NSControl {
                thisControl.action = #selector(self.didChangeParamValue(_:))
                thisControl.target = self
            }
            if let thisPopup = thisParamView as? ParamValuePopupView {
                thisPopup.target = self
                thisPopup.finishSetup()
            }
        }
        for thisParamSelector in paramSelectorViews {
            thisParamSelector.target = self
            thisParamSelector.action = #selector(didSetParam(_:))
        }
    }
    
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis, phase curPhase: TZPhase) {
        self.init(coder: coder, analysis: curAnalysis)
        phase = curPhase
    }
    
    @objc func didSetParam(_ sender: RunVariantEnableButton) {
        guard let representedParam = sender.param else { return }
        guard inputsViewController != nil else { return }
        switch sender.state {
        case .on:
            analysis.enableParam(param: representedParam )
        case .off:
            analysis.disableParam(param: representedParam )
        default:
            return
        }
    }
    
    func containsParamView(for id: ParamID)->Bool{
        return paramValueViews.contains(where: {$0.parameter.id == id})
    }
    func paramView(for id: ParamID)->ParamValueView? {
        if let thisView = paramValueViews.first(where: {$0.parameter.id == id}) {
            return thisView
        } else {return nil}
    }
}

//
//  ViewController.swift
//  Treviz
//
//  View controller controls all information regarding analysis input states and settings
///
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSNotification.Name {
    static let didSetParam = Notification.Name("didSetParam")
    static let didChangeUnits = Notification.Name("didChangeUnits")
    static let didChangeValue = Notification.Name("didChangeValue")
}

class InputsSplitViewController: TZSplitViewController {
    @IBOutlet var phaseSelectorSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var inputsSplitViewItem: NSSplitViewItem!
    //@IBOutlet var runVariantsSplitViewItem: NSSplitViewItem!
    
    var runVariantViewController : RunVariantViewController!
    var phaseSelectorViewController: PhaseSelectorViewController!
    var inputsViewController : InputsViewController!
    
    func reloadParams(){
        runVariantViewController.reloadAll()
    
        //initStateViewController.outlineView.reloadData()
        //physicsViewController.viewDidLoad()
    }
    
    override func viewDidLoad() {
        inputsViewController = inputsSplitViewItem.viewController as? InputsViewController
        phaseSelectorViewController = phaseSelectorSplitViewItem.viewController as? PhaseSelectorViewController
        //runVariantViewController = runVariantsSplitViewItem.viewController as? RunVariantViewController
        inputsViewController.inputSplitViewController = self
        phaseSelectorViewController.inputSplitViewController = self
        //runVariantViewController.inputsSplitViewController = self
        super.viewDidLoad()
    }
}

class InputsViewController: TZViewController {
     
    @IBOutlet weak var stack: CustomStackView!
    
    var inputSplitViewController : InputsSplitViewController!
    var runVariantViewController : RunVariantViewController!
    weak var physicsViewController: PhysicsViewController!
    weak var initStateViewController: InitStateViewController!
    weak var phaseSelectorViewController: PhaseSelectorViewController!
    weak var runSettingsViewController: RunSettingsViewController!
    var params : [Parameter] = []
    var paramValueViews: [ParamValueView] {
        var tmpViews = [ParamValueView]()
        for thisView in self.children.filter({$0 is PhasedViewController}) as! [PhasedViewController] {
            tmpViews.append(contentsOf: thisView.paramValueViews)
        }
        return tmpViews
    }
    var paramSelectorViews: [RunVariantEnableButton] {
        var tmpViews = [RunVariantEnableButton]()
        for thisView in self.children.filter({$0 is PhasedViewController}) as! [PhasedViewController] {
            tmpViews.append(contentsOf: thisView.paramSelectorViews)
        }
        return tmpViews
    }
    
    func valueView(for paramID: ParamID)->ParamValueView? {
        if let thisView = paramValueViews.first(where: {$0.parameter.id == paramID}) {
            return thisView
        } else {return nil}
    }
    func updateParamValueView(for paramID: ParamID) {
        let theseViews = paramValueViews.filter({ ($0.parameter?.id ?? "") == paramID})
        for curView in theseViews {
            curView.update()
            curView.didUpdate()
        }

        self.runVariantViewController.reloadAll()
    }
    func updateParamSelectorView(for paramID: ParamID) {
        let selectorView = paramSelectorViews.first(where: {$0.param?.id == paramID})
        if let param = selectorView?.param
        {
            if param.isParam { selectorView!.state = .on} else {selectorView!.state = .off}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        stack.parent = self
        stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        // Load and install all the view controllers from our storyboard in the following order.
        let storyboard = NSStoryboard(name: "Inputs", bundle: nil)
        
        runSettingsViewController = storyboard.instantiateController(identifier: "RunSettingsViewController") { aCoder in
            RunSettingsViewController(coder: aCoder, analysis: self.analysis, phase: self.analysis.phases[0])
        }
        physicsViewController = storyboard.instantiateController(identifier: "PhysicsViewController") { aCoder in
            PhysicsViewController(coder: aCoder, analysis: self.analysis, phase: self.analysis.phases[0])
        }

        initStateViewController = storyboard.instantiateController(identifier: "InitStateViewController") { aCoder in
            InitStateViewController(coder: aCoder, analysis: self.analysis, phase: self.analysis.phases[0])
        }
        stack.addViewController(runSettingsViewController)
        stack.addViewController(physicsViewController)
        stack.addViewController(initStateViewController)

        //runVariantViewController = self.inputSplitViewController.runVariantViewController!
        phaseSelectorViewController = self.inputSplitViewController.phaseSelectorViewController!
    }
    
    func reloadParams(){
        runVariantViewController.reloadAll()
    }
    
    
}


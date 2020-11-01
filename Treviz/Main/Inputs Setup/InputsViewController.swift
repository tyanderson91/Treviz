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

class InputsViewController: TZViewController, NSTableViewDataSource, NSTableViewDelegate {
     
    @IBOutlet weak var stack: CustomStackView!
    
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
    
    func valueView(for paramID: VariableID)->ParamValueView? {
        if let thisView = paramValueViews.first(where: {$0.parameter.id == paramID}) {
            return thisView
        } else {return nil}
    }
    func updateParamValueView(for paramID: VariableID) {

        let theseViews = paramValueViews.filter({$0.parameter.id == paramID})
        for curView in theseViews {
            curView.update()
        }

        self.runVariantViewController.tableView.reloadData()
    }
    func updateParamSelectorView(for paramID: VariableID) {
        let selectorView = paramSelectorViews.first(where: {$0.param?.id == paramID})
        if let param = selectorView?.param
        {
            if param.isParam { selectorView!.state = .on} else {selectorView!.state = .off}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
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
        
        for thisController in [runSettingsViewController,
                               physicsViewController,
                               //vehicleViewController,
                               initStateViewController]{
            self.addChild(thisController!)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .paramTableViewSegue as NSStoryboardSegue.Identifier{
            self.runVariantViewController = segue.destinationController as? RunVariantViewController
            self.runVariantViewController.analysis = analysis
            runVariantViewController.inputsViewController = self
        } else if segue.identifier == "PhaseSelectorSegue" {
            self.phaseSelectorViewController = segue.destinationController as? PhaseSelectorViewController
            self.phaseSelectorViewController.analysis = analysis
        }
    }
    
    func reloadParams(){
        runVariantViewController.tableView.reloadData()
        //initStateViewController.outlineView.reloadData()
        //physicsViewController.viewDidLoad()
    }
    
    
}


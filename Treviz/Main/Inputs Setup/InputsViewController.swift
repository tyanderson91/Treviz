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
    
    var tableViewController : ParamTableViewController!
    weak var physicsViewController: PhysicsViewController!
    weak var initStateViewController: InitStateViewController!
    weak var phaseSelectorViewController: PhaseSelectorViewController!
    weak var runSettingsViewController: RunSettingsViewController!
    var params : [Parameter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        // Load and install all the view controllers from our storyboard in the following order.
        let storyboard = NSStoryboard(name: "Inputs", bundle: nil)

        runSettingsViewController = storyboard.instantiateController(identifier: "RunSettingsViewController") { aCoder in
            RunSettingsViewController(coder: aCoder, analysis: self.analysis, phase: self.analysis.phases[0])
        }
        physicsViewController = storyboard.instantiateController(identifier: "PhysicsViewController") { aCoder in
            PhysicsViewController(coder: aCoder, analysis: self.analysis, phase: self.analysis.phases[0])
        }
        //let vehicleViewController = (stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "VehicleViewController", analysis: analysis) as! VehicleViewController)
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
        
        initStateViewController.inputsViewController = self
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .paramTableViewSegue as NSStoryboardSegue.Identifier{
            self.tableViewController = segue.destinationController as? ParamTableViewController
            self.tableViewController.analysis = analysis
            tableViewController.inputsViewController = self
        } else if segue.identifier == "PhaseSelectorSegue" {
            self.phaseSelectorViewController = segue.destinationController as? PhaseSelectorViewController
            self.phaseSelectorViewController.analysis = analysis
        }
    }
    
    func reloadParams(){
        tableViewController.tableView.reloadData()
        initStateViewController.outlineView.reloadData()
    }
    
    
}


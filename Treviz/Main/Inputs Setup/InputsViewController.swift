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

class InputsViewController: TZViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    //var parentSplitViewController : MainSplitViewController? = nil
    //@IBOutlet weak var tableView: NSTableView!    
    @IBOutlet weak var stack: CustomStackView!
    
    var tableViewController : ParamTableViewController!
    weak var settingsViewController: SettingsViewController!
    weak var environmentsViewController: EnvironmentViewController!
    weak var initStateViewController: InitStateViewController!
    var params : [Parameter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        // Load and install all the view controllers from our storyboard in the following order.
        settingsViewController = (stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "SettingsViewController") as! SettingsViewController)
        //environmentsViewController = (stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "EnvironmentViewController") as! EnvironmentViewController)
        initStateViewController = (stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "InitStateViewController") as! InitStateViewController)
        for thisController in [settingsViewController,
                               //environmentsViewController,
                               initStateViewController]{
            self.addChild(thisController!)
            thisController?.analysis = self.analysis
            //thisController?.representedObject = self.representedObject
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .paramTableViewSegue as NSStoryboardSegue.Identifier{
            self.tableViewController = segue.destinationController as? ParamTableViewController
        }
    }
}


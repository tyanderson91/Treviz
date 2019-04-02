//
//  MainSplitViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/9/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainSplitViewController: SplitViewController {

    @IBOutlet weak var inputsSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var outputsSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var outputSetupSplitViewItem: NSSplitViewItem!
    var inputsViewController : InputsViewController? = nil
    var outputsViewController : OutputsViewController? = nil
    //var outputSetupViewController : OutputSetupViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputsViewController = inputsSplitViewItem?.viewController as? InputsViewController //TODO: try to move this to the variable declaration
        outputsViewController = outputsSplitViewItem?.viewController as? OutputsViewController
        //outputSetupViewController = outputSetupSplitViewItem?.viewController as? OutputSetupViewController

        //inputsViewController!.parentSplitViewController = self
        //outputsViewController!.parentSplitViewController = self
        //outputSetupViewController.parentSplitViewController = self
        // Do view setup here.
    }
    
}

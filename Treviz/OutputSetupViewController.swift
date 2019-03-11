//
//  OutputSetupViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/8/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class OutputSetupViewController: NSViewController {


    //@IBOutlet weak var singleOutputSetupTableView: NSTableView!
    @IBOutlet weak var outputSummaryTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func singleOutputSetupDisclosureClicked(_ sender: Any) {
        //singleOutputSetupTableView.isHidden = false
        print("disclosed!")
    }
    
}

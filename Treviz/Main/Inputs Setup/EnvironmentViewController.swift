//
//  EnvironmentViewController.swift
//  Treviz
//
//  View controller that sets analysis environemtn settings, including celestial bodies, atmosphere properties, etc.
//
//  Created by Tyler Anderson on 3/27/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class EnvironmentViewController: BaseViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    override func getHeaderTitle() -> String { return NSLocalizedString("Environment", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

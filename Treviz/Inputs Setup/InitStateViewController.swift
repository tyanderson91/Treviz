//
//  InitStateViewController.swift
//  
//
//  Created by Tyler Anderson on 3/27/19.
//

import Cocoa

class InitStateViewController: BaseViewController {

    @IBOutlet weak var table: NSTableView!
    
    override func headerTitle() -> String { return NSLocalizedString("Initial State", comment: "") }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

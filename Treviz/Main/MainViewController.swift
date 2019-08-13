//
//  MainViewController.swift
//  Treviz
//
//  Highest-level view controller
//
//  Created by Tyler Anderson on 3/10/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainViewController: ViewController {

    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var analysisProgressBar: NSProgressIndicator!
    var mainSplitViewController : MainSplitViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFrameSize(NSSize.init(width: 1200, height: 500))
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
    }

    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainSplitViewSegue"{
            self.mainSplitViewController =  (segue.destinationController as! MainSplitViewController)
        } else {return}
        
    }
    
}

//
//  MainViewController.swift
//  Treviz
//
//  Highest-level view controller
//  Mainly consists of the main split view controller and the progress bar
//
//  Created by Tyler Anderson on 3/10/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainViewController: TZViewController {

    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var analysisProgressBar: NSProgressIndicator!
    var toolbarOffsetHeightConstraint: CGFloat = 0 {
        didSet {
            guard let mv = mainSplitViewController else {return}
            mv.sidebarViewController.toolbarOffsetConstraint.constant = toolbarOffsetHeightConstraint
            mv.outputsViewController.toolbarOffsetConstraint.constant = toolbarOffsetHeightConstraint
            mv.outputSetupViewController.toolbarOffsetConstraint.constant = toolbarOffsetHeightConstraint
        }
    }
    var mainSplitViewController : MainSplitViewController!
    var textOutputView : NSTextView? {
        return mainSplitViewController.outputsViewController.outputSplitViewController?.textOutputView
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setFrameSize(NSSize.init(width: 1200, height: 500))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainSplitViewSegue"{
            self.mainSplitViewController =  (segue.destinationController as! MainSplitViewController)
            self.mainSplitViewController.analysis = analysis
        } else {return}
        
    }
    
}

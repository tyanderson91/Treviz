//
//  TextOutputsViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/21/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class TextOutputContainerViewController: NSViewController{
    @IBOutlet weak var textOutputSplitView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

class TextOutputSplitViewController: NSSplitViewController{
    
}

class TextLogViewController: NSViewController{
    
}

class TextOutputsViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string.append("Analysis results will be shown below \n")
        // Do view setup here.
    }
    
}

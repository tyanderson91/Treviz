//
//  TextOutputsViewController.swift
//  Treviz
//
//  Controls the display of text-based outputs
//
//  Created by Tyler Anderson on 3/21/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa


extension NSStoryboardSegue.Identifier{
    static let loggerViewSegue = "loggerViewSegue"
}

class TextOutputContainerViewController: TZViewController{
    @IBOutlet weak var textOutputSplitView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

class TextOutputSplitViewController: TZSplitViewController{
    
    @IBOutlet weak var textOutputSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var messageLoggerSplitViewItem: NSSplitViewItem!
    var textOutputViewController: TextOutputsViewController! {
        return textOutputSplitViewItem.viewController as? TextOutputsViewController ?? nil
    }
    var textOutputView: NSTextView! {
        return textOutputViewController!.textOutputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    /*
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .loggerViewSegue {
            let vc = segue.destinationController as? TZMessageLoggerViewController
            vc?.analysis = analysis
        }
    }*/
}

class TextOutputsViewController: TZViewController {

    @IBOutlet var textOutputView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textOutputView.string.append("Analysis results will be shown below \n")
        // Do view setup here.
    }
    
}

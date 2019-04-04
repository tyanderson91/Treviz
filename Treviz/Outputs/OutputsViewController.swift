//
//  OutputsViewController.swift
//  Treviz
//
//  Controls display of all analysis output information
//
//  Created by Tyler Anderson on 3/8/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class OutputsViewController: ViewController {
        
    @IBOutlet weak var outputsSplitView: NSView!
    var outputSplitViewController: OutputsSplitViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //analysisProgressBar. = NSControlTint.blueControlTint
        // Do view setup here.
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "outputSplitViewSegue"{
            self.outputSplitViewController =  segue.destinationController as? OutputsSplitViewController
        }
    }
    
}



class OutputsSplitViewController: SplitViewController {
    
    @IBOutlet weak var textOutputSplitViewItem: NSSplitViewItem!
    //let textOutputView: NSTextView
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let textOutputViewController = textOutputSplitViewItem.viewController as? TextOutputsViewController
        //let textOutputView = textOutputViewController?.textView
        //textOutputView?.string.append("dsfgeaef")
        //analysisProgressBar. = NSControlTint.blueControlTint
        // Do view setup here.
    }
    
}
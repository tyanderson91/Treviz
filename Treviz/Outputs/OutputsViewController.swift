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

class OutputsViewController: TZViewController {
        
    @IBOutlet weak var outputsSplitView: NSView!
    var outputSplitViewController: OutputsSplitViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //analysisProgressBar. = NSControlTint.blueControlTint
        // Do view setup here.
        //let curHeight = self.view.frame.height
        //self.view.setFrameSize(NSSize.init(width: 600, height: curHeight))
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "outputSplitViewSegue"{
            self.outputSplitViewController =  segue.destinationController as? OutputsSplitViewController
        }
    }
    
    func processOutputs(){
        if let curAnalysis = self.representedObject as? Analysis{
            let outputSet = curAnalysis.analysisData.plots
            
            let textOutputSplitViewItem = outputSplitViewController!.textOutputSplitViewItem
            let textOutputViewController = textOutputSplitViewItem!.viewController as! TextOutputsViewController
            let textOutputView = textOutputViewController.textView!
            
            textOutputView.string = ""
            for curOutput in outputSet {
                curOutput.curTrajectory = curAnalysis.traj
                if curOutput is TZTextOutput {
                    let newText = (curOutput as! TZTextOutput).getText()
                    textOutputView.textStorage?.append(newText)
                }
            }
            // Old
            //let y_end = curAnalysis.traj["y"].value.last
            //let x_end = curAnalysis.traj["x"].value.last
            
            //textOutputView.string.append("Y end:\t\(String(describing: y_end))\n")
            //textOutputView.string.append("X end:\t\(String(describing: x_end))\n")
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

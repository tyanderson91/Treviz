//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSToolbarDelegate {

    @IBOutlet weak var toolbar: AnalysisToolbar!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    @IBAction func runAnalysisClicked(_ sender: Any) {
        if let asys = self.contentViewController?.representedObject as? Analysis {
            _ = asys.runAnalysis()
        }
    }
    
    @IBAction func conditionsClicked(_ sender: Any) {
        //self.performSegue(withIdentifier: <#T##NSStoryboardSegue.Identifier#>, sender: <#T##Any?#>)
    }
    
    
    @IBAction func showHidePanesClicked(_ sender: Any) {
        let asys = self.contentViewController?.representedObject as! Analysis

        if let button = sender as? NSSegmentedControl {
            //button.setSelected(true, forSegment: 0)
            //button.setSelected(true, forSegment: 2)
            let curIndex = button.indexOfSelectedItem
            if button.isSelected(forSegment: curIndex){
                button.setSelected(true, forSegment: curIndex)
            } else {
                button.setSelected(false, forSegment: curIndex)
            }
            let selectStatus = button.isSelected(forSegment: curIndex)
            switch curIndex {
            case 0:
                print("1st!")
            case 1:
                print("2nd")
            case 2:
                asys.viewController.mainSplitViewController.outputSetupViewController.setViewStatus(selectStatus)
            default:
                print("nada")
            }
        }
    }
    /*
    override func perform(_ aSelector: runAnalysisClicked, on thr: Thread, with arg: Any?, waitUntilDone wait: Bool, modes array: [String]?) {
    }
 */
}

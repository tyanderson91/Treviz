//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSToolbarDelegate {

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var showHidePanesControl: NSSegmentedControl!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //showHidePanesControl.setImage(NSImage(named: "smallSegmentedCell"), forSegment: 0)
        //showHidePanesControl.setImage(NSImage(named: "largeSegmentedCell"), forSegment: 1)
        //showHidePanesControl.setImage(NSImage(named: "smallSegmentedCell"), forSegment: 2)
        showHidePanesControl.setWidth(17, forSegment: 0)
        showHidePanesControl.setWidth(24, forSegment: 1)
        showHidePanesControl.setWidth(17, forSegment: 2)

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    @IBAction func runAnalysisClicked(_ sender: Any) {
        if let asys = self.contentViewController?.representedObject as? Analysis {
            _ = asys.runAnalysis()
        }
    }
    
    
    @IBAction func conditionsClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "conditionsPopupSegue", sender: self)
        }
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "conditionsPopupSegue" {
            let conditionsVC = segue.destinationController as! ConditionsViewController
            conditionsVC.analysis = self.contentViewController!.representedObject as? Analysis
        }
    }
    
    
    @IBAction func showHidePanesClicked(_ sender: Any) {
        let asys = self.contentViewController?.representedObject as! Analysis

        if let button = sender as? NSSegmentedControl {
            let curIndex = button.indexOfSelectedItem
            let shouldCollapse = !button.isSelected(forSegment: curIndex)
            let splitViewController = asys.viewController.mainSplitViewController!
            if splitViewController.numActiveViews() == 1 && shouldCollapse {
                button.setSelected(true, forSegment: curIndex)
            } else {
                splitViewController.setSectionCollapse(shouldCollapse, forSection: curIndex)
            }
        }
    }
    /*
    override func perform(_ aSelector: runAnalysisClicked, on thr: Thread, with arg: Any?, waitUntilDone wait: Bool, modes array: [String]?) {
    }
 */
}

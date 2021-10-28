//
//  MainWindowControllerToolbar.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/29/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSToolbarItem.Identifier {
    static var runAnalysis = NSToolbarItem.Identifier("runAnalysis")
    static var conditions = NSToolbarItem.Identifier("conditions")
    static var parameters = NSToolbarItem.Identifier("parameters")
    static var vectors = NSToolbarItem.Identifier("vectors")
    static var csys = NSToolbarItem.Identifier("csys")
    static var showWindowPanes = NSToolbarItem.Identifier("showWindowPanes")
    static var runVariants = NSToolbarItem.Identifier("runVariants")
}
/*
class TZToolbarSelectorItem: NSToolbarItem {
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        super.init(itemIdentifier: itemIdentifier)
        self.isBordered = true
    }
}*/


/*
class TZToolbarButtonItem: NSToolbarItem {
    var button: NSButton
    override var title: String {
        get { return button.title }
        set { button.title = newValue }
    }
    var width = 40
    var height = 40
    var bezelStyle: NSButton.BezelStyle {
        get { return button.bezelStyle }
        set { button.bezelStyle = newValue }
    }
    
    override init(itemIdentifier: NSToolbarItem.Identifier) {
        button = NSButton(frame: NSRect(x: 0, y: 0, width: width, height: height))
        button.bezelStyle = .texturedRounded
        button.action = nil
        super.init(itemIdentifier: itemIdentifier)
        self.view = button
    }
}*/

class TZToolbar: NSToolbar {
    
}


extension MainWindowController: NSToolbarDelegate {
    func toolbarDidLoad(){
        for i in 0...2 {
            if let isEnabled = UserDefaults().value(forKey: "mainSplitViewDiscloseButton\(i)Enabled") as? Bool {
                showHidePanesControl.setEnabled(isEnabled, forSegment: i)
            }
            if let isSelected = UserDefaults().value(forKey: "mainSplitViewDiscloseButton\(i)Selected") as? Bool {
                showHidePanesControl.setSelected(isSelected, forSegment: i)
            }
        }
    }
    @IBAction func conditionsClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "conditionsPopupSegue", sender: self)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "conditionsPopupSegue" {
            conditionsToolbarItem.isEnabled = false
            let conditionsVC = segue.destinationController as! ConditionsViewController
            conditionsVC.analysis = self.viewController.analysis
        }
    }
    
    
    @IBAction func showHidePanesClicked(_ sender: Any) {
        guard let button = sender as? NSSegmentedControl else {return}
        let curIndex = button.indexOfSelectedItem
        if curIndex == 1 { return } // TODO: do something useful with this
        let shouldCollapse = !button.isSelected(forSegment: curIndex)
        let splitViewController = viewController.mainSplitViewController!
        _ = splitViewController.setSectionCollapse(shouldCollapse, forSection: curIndex)
        setShowHidePanesEnabled()

    }
    
    func setShowHidePanesEnabled(){
        let button = showHidePanesControl!
        let splitViewController = viewController.mainSplitViewController!
        for i in 0...2 { // If there is one button left, disable it so user cannot collapse everything
            let enableButton = (splitViewController.numActiveViews == 1 && button.isSelected(forSegment: i)) ? false : true
            button.setEnabled(enableButton, forSegment: i)
            UserDefaults().set(button.isEnabled(forSegment: i), forKey: "mainSplitViewDiscloseButton\(i)Enabled")
            UserDefaults().set(button.isSelected(forSegment: i), forKey: "mainSplitViewDiscloseButton\(i)Selected")
        }
    }
    
    @IBAction func runAnalysisClicked(_ sender: Any) {
        if let asys = self.contentViewController?.representedObject as? Analysis {
            if asys.isRunning{
                asys.isRunning = false
                asys.analysisDispatchQueue.suspend()
                endProgressTracking()
                /*DistributedNotificationCenter.default().post(name: .didFinishRunningAnalysis, object: nil)*/
            }
            else {
                startProgressTracking()
                viewController.analysisProgressBar.doubleValue = analysis.pctComplete
                asys.runAnalysis()
            }
        }
    }
    
    @IBAction func reloadPlotsClicked(_ sender: Any) {
        if let asys = self.contentViewController?.representedObject as? Analysis {
            asys.processOutputs()
        }
        refreshPlotsButton.isEnabled = false
    }
    
    @IBAction func changeSidebarSelection(_ sender: NSToolbarItem) {
        viewController.mainSplitViewController.sidebarViewController.tabView.selectTabViewItem(withIdentifier: sender.itemIdentifier)
    }
}

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
}

class TZToolbar: NSToolbar {
    /*
    var toggleAnalysisRun = TZToolbarButtonItem(itemIdentifier: .runAnalysis)
    var conditionsButton = TZToolbarButtonItem(itemIdentifier: .conditions)
    var variablesButton = TZToolbarButtonItem(itemIdentifier: .parameters)
    var vectorsButton = TZToolbarButtonItem(itemIdentifier: .vectors)
    var csysButton = TZToolbarButtonItem(itemIdentifier: .csys)
    var runVariantsButton = TZToolbarButtonItem(itemIdentifier: .runVariants)
    var showWindowPanes = TZToolbarButtonItem(itemIdentifier: .showWindowPanes)
    var showHidePanesControl : NSSegmentedControl!
    
    var defaultItemIdentifiers : [NSToolbarItem.Identifier] = [.runAnalysis, .conditions, .parameters, .vectors, .csys, .runVariants, .flexibleSpace, .showWindowPanes]
    var defaultItems : [NSToolbarItem] { [toggleAnalysisRun, conditionsButton, variablesButton, vectorsButton, csysButton, runVariantsButton, showWindowPanes] }
    
    override init(identifier: NSToolbar.Identifier) {
        super.init(identifier: identifier)
    }
    
    init(){
        toggleAnalysisRun.label = "Run Analysis"
        toggleAnalysisRun.button.image = NSImage(named: "play.fill")
        
        conditionsButton.label = "Conditions"
        conditionsButton.image = NSImage()
        conditionsButton.title = "(𝑥<𝑦)"
        
        variablesButton.label = "Variables"
        variablesButton.title = "𝒳"
        
        vectorsButton.label = "Vectors"
        vectorsButton.title = "↗︎"
        vectorsButton.button.font = NSFont(name: "PingFang SC Light", size: 13)
        
        csysButton.label = "CSYS"
        csysButton.button.image = NSImage(named: "CSYS")
        csysButton.button.imageScaling = .scaleProportionallyDown
        
        runVariantsButton.label = "Run Variants"
        
        super.init(identifier: "MainToolbar")
        showHidePanesControl = NSSegmentedControl(labels: ["◁","▽","▷"], trackingMode: .selectAny, target: self, action: nil)
        showHidePanesControl.segmentStyle = .roundRect
        showHidePanesControl.segmentDistribution = .fillProportionally
        showHidePanesControl.font = NSFont(name: "Menlo Bold", size: 12)
        showHidePanesControl.setWidth(18, forSegment: 0)
        showHidePanesControl.setWidth(26, forSegment: 1)
        showHidePanesControl.setWidth(18, forSegment: 2)
        showHidePanesControl.setImageScaling(.scaleProportionallyUpOrDown, forSegment: 0)
        showHidePanesControl.setImageScaling(.scaleProportionallyUpOrDown, forSegment: 1)
        showHidePanesControl.setImageScaling(.scaleProportionallyUpOrDown, forSegment: 2)
        
        for i in 0...2 {
            if let isEnabled = UserDefaults().value(forKey: "mainSplitViewDiscloseButton\(i)Enabled") as? Bool {
                showHidePanesControl.setEnabled(isEnabled, forSegment: i)
            }
            if let isSelected = UserDefaults().value(forKey: "mainSplitViewDiscloseButton\(i)Selected") as? Bool {
                showHidePanesControl.setSelected(isSelected, forSegment: i)
            }
        }
        showWindowPanes.view = showHidePanesControl
        showWindowPanes.label = "Show/Hide Panes"
        
        self.showsBaselineSeparator = false
    }*/
    
}


extension MainWindowController: NSToolbarDelegate {
    /*
    #if !STORYBOARD_WINDOW_CONTROLLER
    func createToolbar(){
        let toolbar = TZToolbar()
        toolbar.delegate = self
        self.window?.toolbar = toolbar
        self.toolbar = toolbar
        toolbar.toggleAnalysisRun.action = #selector(self.runAnalysisClicked(_:))
        toolbar.conditionsButton.action = #selector(self.showConditions(_:))
        toolbar.showHidePanesControl.target = self
        toolbar.showHidePanesControl.action = #selector(self.showHidePanesClicked1)
        //
    }
    
    @objc func showConditions(_ sender: Any){
        let sb = NSStoryboard(name: "Conditions", bundle: nil)
        let vc = sb.instantiateController(identifier: NSStoryboard.SceneIdentifier("conditionsViewController"), creator: { aDecoder in
            return ConditionsViewController(coder: aDecoder, analysis: self.analysis)
        })
        self.contentViewController?.present(vc, asPopoverRelativeTo: toolbar.conditionsButton.button.bounds, of: toolbar.conditionsButton.button, preferredEdge: .maxY, behavior: .transient)
    }
    
    @objc func showHidePanesClicked1(_ sender: Any) {
        guard let button = sender as? NSSegmentedControl else {return}
        let curIndex = button.indexOfSelectedItem
        let shouldCollapse = !button.isSelected(forSegment: curIndex)
        let splitViewController = viewController.mainSplitViewController!
        _ = splitViewController.setSectionCollapse(shouldCollapse, forSection: curIndex)
        
        for i in 0...2 { // If there is one button left, disable it so user cannot collapse everything
            let enableButton = (splitViewController.numActiveViews == 1 && button.isSelected(forSegment: i)) ? false : true
            button.setEnabled(enableButton, forSegment: i)
            UserDefaults().set(button.isEnabled(forSegment: i), forKey: "mainSplitViewDiscloseButton\(i)Enabled")
            UserDefaults().set(button.isSelected(forSegment: i), forKey: "mainSplitViewDiscloseButton\(i)Selected")
        }
    }
    
    //MARK: NSToolbarDelegate implementation
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
            willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        guard let toolbar = toolbar as? TZToolbar else { return nil }
        let curItem = toolbar.defaultItems.filter({ $0.itemIdentifier == itemIdentifier })
        if curItem.count == 1 { return curItem[0] }
        else { return nil }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        guard let toolbar = toolbar as? TZToolbar else { return [] }
        //return toolbar.defaultItems.compactMap({ $0.itemIdentifier })
        return toolbar.defaultItemIdentifiers
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        guard let toolbar = toolbar as? TZToolbar else { return [] }
        return toolbar.defaultItems.compactMap({ $0.itemIdentifier })
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return []
    }

    func toolbarWillAddItem(_ notification: Notification) {
    }

    func toolbarDidRemoveItem(_ notification: Notification) {
    }
    
    @objc func runAnalysisClicked(_ sender: Any) {
        if let asys = self.contentViewController?.representedObject as? Analysis {
            if asys.isRunning{
                toolbar.toggleAnalysisRun.image = NSImage(systemSymbolName: "play.rectangle", accessibilityDescription: nil)
                asys.isRunning = false
                self.endProgressTracking()
            }
            else {
                toolbar.toggleAnalysisRun.image = NSImage(systemSymbolName: "stop.fill", accessibilityDescription: nil)
                viewController.analysisProgressBar.doubleValue = analysis.pctComplete
                asys.runAnalysis()
            }
        }
    }
    #else*/
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
    //#endif
}

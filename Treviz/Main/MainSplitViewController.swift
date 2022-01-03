//
//  MainSplitViewController.swift
//  Treviz
//
//  View controller housing the input, output, and output setup split view items
//
//  Created by Tyler Anderson on 3/9/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainSplitViewController: TZSplitViewController {

    @IBOutlet @objc weak var sidebarSplitViewItem: NSSplitViewItem!
    @IBOutlet @objc weak var outputsSplitViewItem: NSSplitViewItem!
    @IBOutlet @objc weak var outputSetupSplitViewItem: NSSplitViewItem!
    var sidebarViewController: SidebarTabViewController!
    var inputsViewController : InputsSplitViewController!
    var outputsViewController : OutputsViewController!
    var outputSetupViewController : OutputSetupViewController!
    var splitViewItemList : [NSSplitViewItem] = []
    var numActiveViews : Int {
        var numViews = 0
        for thisView in splitViewItemList { numViews += (thisView.isCollapsed ? 0 : 1) }
        return numViews}
    let splitViewNames = ["sidebar", "outputs", "outputSetup"]
    let holdingPriorites : Dictionary<String, Int> = ["sidebar": 300, "outputs":10, "outputSetup": 350]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarViewController = (sidebarSplitViewItem?.viewController as! SidebarTabViewController)
        inputsViewController = sidebarViewController.inputsViewController
        outputsViewController = (outputsSplitViewItem?.viewController as! OutputsViewController)
        outputSetupViewController = (outputSetupSplitViewItem?.viewController as! OutputSetupViewController)
        splitViewItemList = [sidebarSplitViewItem, outputsSplitViewItem, outputSetupSplitViewItem]
        
        for splitViewName in splitViewNames {
            let itemKey = splitViewName + "SplitViewItem"
            if splitViewName == "outputs" {
                UserDefaults().set(false, forKey: itemKey + ".isCollapsed") // TODO: Remove
            }
            guard let splitViewItem = self.value(forKey: itemKey) as? NSSplitViewItem else { continue }
            if let shouldCollapseView = UserDefaults().value(forKey: itemKey + ".isCollapsed") as? Bool {
                splitViewItem.isCollapsed = shouldCollapseView
            }
            splitViewItem.holdingPriority = NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.RawValue(holdingPriorites[splitViewName]!))
        }
        
        // Set the output tab view for use by any views within the sidebar
        sidebarViewController.outputTabViewController = outputsViewController.outputSplitViewController?.viewerTabViewController
    }
    
    /**
     Collapse and expand Main Split View items
     - Parameter collapsed: Bool, whether to collapse or expand the view
     - Parameter secID: Int, which section (Inputs, Outputs, Outputs setup) to expand/collapse
     */
    func setSectionCollapse(_ collapsed : Bool, forSection secID: Int)->Bool{
        guard self.representedObject is Analysis else {return false}
        if !(collapsed && numActiveViews == 1){
            splitViewItemList[secID].animator().isCollapsed = collapsed
            let itemKey = splitViewNames[secID] + "SplitViewItem.isCollapsed"
            UserDefaults().set(collapsed, forKey: itemKey)
            return true
        } else {return false}
    }
    
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        for splitViewName in splitViewNames {
            let itemKey = splitViewName + "SplitViewItem"
            guard let splitViewItem = self.value(forKey: itemKey) as? NSSplitViewItem else { continue }
            UserDefaults.standard.set(splitViewItem.viewController.view.bounds.width, forKey: itemKey + ".width")
        }
        outputsViewController?.outputSplitViewController?.visualizerViewController.resizeView()
    }
}

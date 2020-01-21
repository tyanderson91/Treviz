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

    @IBOutlet @objc weak var inputsSplitViewItem: NSSplitViewItem!
    @IBOutlet @objc weak var outputsSplitViewItem: NSSplitViewItem!
    @IBOutlet @objc weak var outputSetupSplitViewItem: NSSplitViewItem!
    var inputsViewController : InputsViewController!
    var outputsViewController : OutputsViewController!
    var outputSetupViewController : OutputSetupViewController!
    var splitViewItemList : [NSSplitViewItem] = []
    var numActiveViews : Int {
        var numViews = 0
        for thisView in splitViewItemList { numViews += (thisView.isCollapsed ? 0 : 1) }
        return numViews}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputsViewController = (inputsSplitViewItem?.viewController as! InputsViewController)
        outputsViewController = (outputsSplitViewItem?.viewController as! OutputsViewController)
        outputSetupViewController = (outputSetupSplitViewItem?.viewController as! OutputSetupViewController)
        splitViewItemList = [inputsSplitViewItem, outputsSplitViewItem, outputSetupSplitViewItem]
        
        for splitViewName in ["inputs", "outputs", "outputSetup"] {
            let itemKey = splitViewName + "SplitViewItem"
            guard let splitViewItem = self.value(forKey: itemKey) as? NSSplitViewItem else { continue }
            if let shouldCollapseView = UserDefaults().value(forKey: itemKey + ".isCollapsed") as? Bool {
                splitViewItem.isCollapsed = shouldCollapseView
            }
        }
    }
    
    /**
     Collapse and expand Main Split View items
     - Parameter collapsed: Bool, whether to collapse or expand the view
     - Parameter secID: Int, which section (Inputs, Outputs, Outputs setup) to expand/collapse
     */
    func setSectionCollapse(_ collapsed : Bool, forSection secID: Int)->Bool{
        let listNames = ["inputs", "outputs", "outputSetup"]
        guard self.representedObject is Analysis else {return false}
        if !(collapsed && numActiveViews == 1){
            splitViewItemList[secID].animator().isCollapsed = collapsed
            let itemKey = listNames[secID] + "SplitViewItem.isCollapsed"
            UserDefaults().set(collapsed, forKey: itemKey)
            return true
        } else {return false}
    }
    
}

//
//  ViewController.swift
//  customTabViewTest
//
//  Created by Tyler Anderson on 12/30/21.
//

import Cocoa

extension NSStoryboard.SceneIdentifier {
    fileprivate static var customTabHeader = "customTabHeader"
}

class DynamicTabViewController: NSViewController {
    static let storyboardName: String = "DynamicTabViewController"
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var tabSelectorView: NSStackView!
    weak var activeView: DynamicTabHeaderViewController?
    weak var previousView: DynamicTabHeaderViewController? // View switches to this in the event that the primary view is removed
    weak var unpinnedView: DynamicTabHeaderViewController?
    var allViews: [DynamicTabHeaderViewController] {
        return self.children.filter({
        $0 is DynamicTabHeaderViewController }) as! [DynamicTabHeaderViewController]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabView.layer?.borderWidth = 0.5
    }
    
    func setDefaultView(vc: NSViewController){
        let defaultItem = NSTabViewItem(viewController: vc)
        tabView.tabViewItems.forEach { tabView.removeTabViewItem($0) }
        tabView.insertTabViewItem(defaultItem, at: 0)
    }

    
    func selectView(tabVC: DynamicTabHeaderViewController){
        if tabVC == activeView { return }
        else if activeView != nil {
            previousView = activeView!
            previousView!.isActive = false
        }
        tabVC.isActive = true
        activeView = tabVC
        tabView.selectTabViewItem(tabVC.tabViewItem)
    }
        
    /**
     Function attempts to switch to the tab with a given title, and returns a bool indicating whether it succeeded or not
     */
    func switchToView(title: String)->Bool {
        if let matchingHeader = allViews.first(where: {$0.title == title}) {
            matchingHeader.makeActive()
            return true
        } else { return false }
    }
    
    func tabHeaderItem(named title: String)->DynamicTabHeaderViewController? {
        if let matchingItem = allViews.first(where: { $0.title == title }){
            return matchingItem
        } else { return nil }
    }
    /**
     Deletes the given tab and does all necessary cleanup of the associated views
     */
    func deleteView(tabVC: DynamicTabHeaderViewController){
        let curActive = tabVC.isActive
        let curUnpinned = !tabVC.isPinned
        tabView.removeTabViewItem(tabVC.tabViewItem)
        tabVC.childVC.removeFromParent()
        tabSelectorView.removeArrangedSubview(tabVC.view)
        //tabSelectorView.layout()
        tabVC.view.removeFromSuperview()
        tabVC.removeFromParent()
        
        if curActive {
            if previousView != nil {
                selectView(tabVC: previousView!)
            } else {
                tabView.selectTabViewItem(at: 0)
            }
        }
        if curUnpinned {
            unpinnedView = nil
        }
    }
    
    /**
     Adds a new view controller to the tab view and determines whether to place it in the existing unpinned view or whether to create a new one
     */
    func addViewController(controller: NSViewController){
        if unpinnedView == nil { // Create new view
            let newVC = addNewViewController(controller: controller)
            unpinnedView = newVC
            selectView(tabVC: newVC)
        } else {
            unpinnedView!.swapView(newVC: controller)
            selectView(tabVC: unpinnedView!)
        }
    }
    
    /**
     Creates a new header tab and associated view controller
     */
    func addNewViewController(controller: NSViewController)->DynamicTabHeaderViewController{
        let sb = NSStoryboard(name: DynamicTabViewController.storyboardName, bundle: nil)
        let newVC = sb.instantiateController(identifier: .customTabHeader) { aCoder in
            return DynamicTabHeaderViewController(coder: aCoder, parent: self, childVC: controller)
        }
        tabView.selectTabViewItem(newVC.tabViewItem)
        self.addChild(newVC)
        tabSelectorView.addArrangedSubview(newVC.view)
        return newVC
    }
}

// TODO: Make a custom view and override didChangeEffectiveAppearance so that the selected view highlight color changes with the system appearance

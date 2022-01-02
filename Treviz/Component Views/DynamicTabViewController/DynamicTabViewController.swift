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
        if activeView != nil {
            previousView = activeView!
            previousView!.isActive = false
        }
        tabVC.isActive = true
        activeView = tabVC
        tabView.selectTabViewItem(tabVC.tabViewItem)
    }
    
    func deleteView(tabVC: DynamicTabHeaderViewController){
        let curActive = tabVC.isActive
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
    }
    
    func addUnpinnedViewController(controller: NSViewController){
        if unpinnedView == nil { // Create new view
            let newVC = addNewViewController(controller: controller)
            unpinnedView = newVC
            selectView(tabVC: newVC)
        } else {
            unpinnedView!.swapView(newVC: controller)
            selectView(tabVC: unpinnedView!)
        }
    }
    
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


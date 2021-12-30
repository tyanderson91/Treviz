//
//  SplitView.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/28/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

class CustomSplitViewController: TZSplitViewController, StackItemHost {
    var curHoldingPriority: Float = 100.0
    var numExpandedViews: Int = 0
    
    func addViewController(_ viewController : BaseViewController) {
        
        // Check if we stored the disclosure state from a previous launch (default state is open).
        if let defaultDisclosureState = UserDefaults().value(forKey: viewController.getHeaderTitle() ) {
            if defaultDisclosureState as! Int != 0 {
                viewController.disclosureState = .closed
            } else { viewController.disclosureState = .open }
        }
        
        // Setup the view controller's item container.
        let stackItem = viewController.stackItemContainer!
        
        // Set the appropriate action for toggling.
        stackItem.header.disclose = {
            self.disclose(viewController.stackItemContainer!)
        }
        
        // Add the header view.
        let headerItem = NSSplitViewItem(viewController: stackItem.header.viewController)
        self.addSplitViewItem(headerItem)
        
        // Add the main body content view.
        let bodyItem = NSSplitViewItem(viewController: stackItem.body.viewController)
        bodyItem.canCollapse = true
        bodyItem.isCollapsed = false//viewController.disclosureState == .closed
        bodyItem.holdingPriority = NSLayoutConstraint.Priority(curHoldingPriority)
        curHoldingPriority = curHoldingPriority*0.9
        self.addSplitViewItem(bodyItem)
        
        // Make sure the appropriate view controllers are added as children of the current controller.
        self.addChild(stackItem.body.viewController)
        self.addChild(stackItem.header.viewController)
        
        // Set the current disclosure state.
        switch stackItem.state {
        case .open:
            show(stackItem, animated: false)
        case .closed:
            numExpandedViews += 1
            hide(stackItem, animated: false)
        }
    }
    
    func disclose(_ stackItem: StackItemContainer) {
        switch stackItem.state {
        case .open:
            if numExpandedViews > 1 {
                hide(stackItem, animated: true)
                stackItem.state = .closed
            }
            if numExpandedViews == 1 {
                splitViewItems.forEach({
                    if let hvc = $0.viewController as? HeaderViewController {
                        hvc.canCollapse = false
                    }
                })
            }
        case .closed:
            show(stackItem, animated: true)
            stackItem.state = .open
            if numExpandedViews > 1 {
                splitViewItems.forEach({
                    if let hvc = $0.viewController as? HeaderViewController {
                        hvc.canCollapse = true
                    }
                })
            }
        }
        
        // Update the stackItem's header disclosure state.
        stackItem.header.update(toDisclosureState: stackItem.state)
        
        if let base = stackItem.body as? BaseViewController {
            base.disclosureState = stackItem.state
            base.didDisclose()
        }
    }
    
    func show(_ stackItem: StackItemContainer, animated: Bool) {
        
        // Show the stackItem's body content.
        numExpandedViews += 1
        self.splitViewItem(for: stackItem.body.viewController)?.animator().isCollapsed = false
        // Update the stackItem's header button state.
        stackItem.header.update(toDisclosureState: .open)
    }
    
    func hide(_ stackItem: StackItemContainer, animated: Bool) {
        numExpandedViews -= 1
        // Hide the stackItem's body content.
        self.splitViewItem(for: stackItem.body.viewController)?.animator().isCollapsed = true
        
        // Update the stackItem's header button state.
        stackItem.header.update(toDisclosureState: .closed)
    }
}

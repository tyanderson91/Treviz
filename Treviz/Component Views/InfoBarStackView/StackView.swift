/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Classes and protocols for handling NSStackView architecture.
 */

import Cocoa

// MARK: Protocol Delarations -

// The hosting object containing both the header and body.
protocol StackItemHost : AnyObject {
    
    func disclose(_ stackItem: StackItemContainer)
}

// The object containing the header portion.
protocol StackItemHeader : AnyObject {
 
    var viewController: NSViewController { get }
    var disclose: (() -> ())? { get set }
    
    func update(toDisclosureState: StackItemContainer.DisclosureState)
}

// The object containing the main body portion.
protocol StackItemBody : AnyObject {
    
    var viewController: NSViewController { get }
    
    func show(animated: Bool)
    func hide(animated: Bool)
}

// MARK: - Protocol implementations -

extension StackItemHost {
    
    func disclose(_ stackItem: StackItemContainer) {
        
        switch stackItem.state {
        case .open:
            hide(stackItem, animated: true)
            stackItem.state = .closed
            
        case .closed:
            show(stackItem, animated: true)
            stackItem.state = .open
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
        stackItem.body.show(animated: animated)
        
        // Update the stackItem's header button state.
        stackItem.header.update(toDisclosureState: .open)
    }
    
    func hide(_ stackItem: StackItemContainer, animated: Bool) {
        
        // Hide the stackItem's body content.
        stackItem.body.hide(animated: animated)
        
        // Update the stackItem's header button state.
        stackItem.header.update(toDisclosureState: .closed)
    }
    
}

// MARK:
extension StackItemHeader where Self : NSViewController {
    
    var viewController: NSViewController { return self }
}

// MARK: -
extension StackItemBody where Self : NSViewController {
    
    var viewController: NSViewController { return self }
    
    func animateDisclosure(disclose: Bool, animated: Bool) {
        let viewController = self as! BaseViewController
        if let constraint = viewController.heightConstraint {
            let heightValue = disclose ? viewController.savedDefaultHeight : 0
            let newLock = disclose ? true : false
            
            if animated {
                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                    context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    constraint.animator().constant = heightValue
                    if let lockConstraint = viewController.lockingConstraint {
                        lockConstraint.animator().isActive = newLock
                    }
                }, completionHandler: { () -> Void in
                    // animation completed
                })
            }
            else {
                constraint.constant = heightValue
                if let lockConstraint = viewController.lockingConstraint {
                    lockConstraint.isActive = newLock
                }
            } 
        }
    }
    
    func show(animated: Bool) {
        animateDisclosure(disclose: true, animated: animated)
    }
    
    func hide(animated: Bool) {
        animateDisclosure(disclose: false, animated: animated)
    }
    
}

// MARK: -
class StackItemContainer {
    
    // Content view disclosure states.
    enum DisclosureState : Int {
        case open = 0
        case closed = 1
    }
    
    let header: StackItemHeader
    var state: DisclosureState
    let body: StackItemBody
    var hostStackView: CustomStackView? {
        return (self.body as? BaseViewController)?.parentStackView ?? nil }
    var hostSplitView: CustomSplitView? {
        return (self.body as? BaseViewController)?.parentSplitView ?? nil }
    
    init(header: StackItemHeader, body: StackItemBody, state: DisclosureState) {
        self.header = header
        self.body = body
        self.state = state
    }
    
    func deleteFromHost(){ // Used to remove a view and its header completely from the host view
        if hostStackView != nil {
            let hvc = self.header.viewController
            let bvc = self.body.viewController
            hostStackView!.removeView(hvc.view)
            hostStackView!.removeView(bvc.view)
            hvc.removeFromParent()
            bvc.removeFromParent()
        }
    }
    
}

// To adjust the origin of stack view in its enclosing scroll view.
class CustomStackView : NSStackView, StackItemHost {
    
    override var isFlipped: Bool { return true }
    var parent : NSViewController?
    
    /*
    override func viewWillDraw() {
        //self.wantsLayer = true
        // self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }*/
    
    func addViewController(fromStoryboardId storyboardid:String, withIdentifier identifier: String)->NSViewController? {
        
        let storyboard = NSStoryboard(name: storyboardid, bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: identifier) as! BaseViewController
        self.addViewController(viewController)
        return viewController
    }
    
    func addViewController(fromStoryboardId storyboardid:String, withIdentifier identifier: String, analysis: Analysis)->BaseViewController? {
        
        let storyboard = NSStoryboard(name: storyboardid, bundle: nil)
        let viewController = storyboard.initViewController(identifier: identifier, with: analysis) as! BaseViewController
        self.addViewController(viewController)
        return viewController
    }
    
    func addViewController(_ viewController : BaseViewController) {
        
        // Check if we stored the disclosure state from a previous launch (default state is open).
        if let defaultDisclosureState = UserDefaults().value(forKey: viewController.getHeaderTitle() ) {
            if defaultDisclosureState as! Int != 0 {
                viewController.disclosureState = .closed
            }
        }
        
        // Setup the view controller's item container.
        let stackItem = viewController.stackItemContainer!
        
        // Set the appropriate action for toggling.
        stackItem.header.disclose = {
            self.disclose(viewController.stackItemContainer!)
        }
        
        // Add the header view.
        self.addArrangedSubview(stackItem.header.viewController.view)
        
        // Add the main body content view.
        self.addArrangedSubview(stackItem.body.viewController.view)

        
        // Make sure the appropriate view controllers are added as children of the current controller.
        if let parentController = self.parent {
            parentController.addChild(stackItem.body.viewController)
            parentController.addChild(stackItem.header.viewController)
        }
        
        // Set the current disclosure state.
        switch stackItem.state {
        case .open: show(stackItem, animated: false)
        case .closed: hide(stackItem, animated: false)
        }
        
        // Final setup
        viewController.parentStackView = self
        //show(stackItem, animated: false)
    }
    
}

class CustomSplitView : NSSplitView, StackItemHost {
        
    override var isFlipped: Bool { return true }
    var parent : NSViewController?

    /*
    override func viewWillDraw() {
        //self.wantsLayer = true
        // self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }*/
    
    func addViewController(fromStoryboardId storyboardid:String, withIdentifier identifier: String)->NSViewController? {
        
        let storyboard = NSStoryboard(name: storyboardid, bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: identifier) as! BaseViewController
        
        self.addViewController(viewController)
        return viewController
    }
    
    func addViewController(fromStoryboardId storyboardid:String, withIdentifier identifier: String, analysis: Analysis)->BaseViewController? {
        
        let storyboard = NSStoryboard(name: storyboardid, bundle: nil)
        let viewController = storyboard.initViewController(identifier: identifier, with: analysis) as! BaseViewController
        self.addViewController(viewController)
        self.addArrangedSubview(viewController.view)
        return viewController
    }
    
    func addViewController(_ viewController : BaseViewController) {
        
        // Check if we stored the disclosure state from a previous launch (default state is open).
        if let defaultDisclosureState = UserDefaults().value(forKey: viewController.getHeaderTitle() ) {
            if defaultDisclosureState as! Int != 0 {
                viewController.disclosureState = .closed
            }
        }
        
        // Setup the view controller's item container.
        let stackItem = viewController.stackItemContainer!
        
        // Set the appropriate action for toggling.
        stackItem.header.disclose = {
            self.disclose(viewController.stackItemContainer!)
        }
        
        // Add the header view.
        self.addArrangedSubview(stackItem.header.viewController.view)
        
        // Add the main body content view.
        self.addArrangedSubview(stackItem.body.viewController.view)
        
        // Make sure the appropriate view controllers are added as children of the current controller.
        if let parentController = self.parent {
            parentController.addChild(stackItem.body.viewController)
            parentController.addChild(stackItem.header.viewController)
        }
        
        // Set the current disclosure state.
        switch stackItem.state {
        case .open: show(stackItem, animated: false)
        case .closed: hide(stackItem, animated: false)
        }
        
        // Final setup
        viewController.parentSplitView = self
        //show(stackItem, animated: false)
    }
    
    // MARK: StackItemHost
    /*
    func disclose(_ stackItem: StackItemContainer) {
        
        let vc = stackItem.body as! BaseViewController
        
        switch stackItem.state {
        case .open:
            //hide(stackItem, animated: true)
            //vc.view.animator().view?.isHidden = true
            stackItem.state = .closed
            
        case .closed:
            //show(stackItem, animated: true)
            vc.show(animated: true)
            stackItem.state = .open
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
        stackItem.body.show(animated: animated)
        
        // Update the stackItem's header button state.
        stackItem.header.update(toDisclosureState: .open)
    }
    
    func hide(_ stackItem: StackItemContainer, animated: Bool) {
        
        // Hide the stackItem's body content.
        stackItem.body.hide(animated: animated)
        
        // Update the stackItem's header button state.
        stackItem.header.update(toDisclosureState: .closed)
    }*/
}

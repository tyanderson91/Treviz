/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View Controller controlling the NSStackView.
 */

import Cocoa

class OutputSetupViewController: NSViewController, StackItemHost {
    
    @IBOutlet weak var stack: CustomStackView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Have the stackView strongly hug the sides of the views it contains.
        stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)

        // Load and install all the view controllers from our storyboard in the following order.
        addViewController(withIdentifier: "SingleAxisOutputSetupViewController")
        addViewController(withIdentifier: "TwoAxisOutputSetupViewController")
        addViewController(withIdentifier: "ThreeAxisOutputSetupViewController")
        addViewController(withIdentifier: "MonteCarloOutputSetupViewController")

        //addViewController(withIdentifier: "CollectionViewController")
        //addViewController(withIdentifier: "OtherViewController")
    }
    
    /// Used to add a particular view controller as an item to our stack view.
    func addViewController(withIdentifier identifier: String) {
    
        let storyboard = NSStoryboard(name: "StackItems", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: identifier) as! BaseViewController
        
        // Check if we stored the disclosure state from a previous launch (default state is open).
        if let defaultDisclosureState = UserDefaults().value(forKey: viewController.headerTitle()) {
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
        stack.addArrangedSubview(stackItem.header.viewController.view)
        
        // Add the main body content view.
        stack.addArrangedSubview(stackItem.body.viewController.view)
        
        // Make sure the appropriate view controllers are added as children of the current controller.
        addChild(stackItem.body.viewController)
        addChild(stackItem.header.viewController)
        
        // Set the current disclosure state.
        switch stackItem.state {
        case .open: show(stackItem, animated: false)
        case .closed: hide(stackItem, animated: false)
        }
        
        //show(stackItem, animated: false)
    }

}

// MARK: -

// To adjust the origin of stack view in its enclosing scroll view.
class CustomStackView : NSStackView {
    
    override var isFlipped: Bool { return true }
}

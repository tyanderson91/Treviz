/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Base view controller to be subclassed for any view controller in the stack view.
 */

import Cocoa

class BaseViewController : TZViewController, StackItemBody {
    
    // static let StackItemBackgroundColor = NSColor(calibratedRed: 0.1, green: 0.105, blue: 0.1, alpha:1)
    static let StackItemBackgroundColor = NSColor.controlBackgroundColor
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    var savedDefaultHeight: CGFloat = 0
    var disclosureState: StackItemContainer.DisclosureState = .open
    var customCreator: ((BaseViewController)->BaseViewController)?
    weak var parentStackView: CustomStackView?
    
    // Subclasses determine the header title.
    func getHeaderTitle() -> String { return "" }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Remember the default height for disclosing later (subclasses can determine this value in their own viewDidLoad).
        savedDefaultHeight = view.bounds.height
        
        view.wantsLayer = true
        view.layer?.backgroundColor = BaseViewController.StackItemBackgroundColor.cgColor
        // view.layer?.borderColor = BaseViewController.StackItemBackgroundColor.cgColor
        // view.layer?.borderWidth = 0.5
    }
    
    // MARK: - StackItemBody
    
    lazy var stackItemContainer: StackItemContainer? = {
        
        let storyboardIdentifier = "HeaderTriangleViewController"
        let storyboard = NSStoryboard(name: "HeaderViewController", bundle: nil)
        guard let header = storyboard.instantiateController(withIdentifier: storyboardIdentifier) as? HeaderViewController else {
            return .none
        }
        header.title = self.getHeaderTitle()
        
        return StackItemContainer(header: header, body: self, state: self.disclosureState)
    }()
    
    func delete(){//Used to delete the base view from the host stack view (called from the stack item container which also deletes the header)
        self.removeFromParent()
        if parentStackView != nil {
            parentStackView?.removeView(self.view)
        }
    }
    
    func didDisclose(){
        // Function to be overridden. Runs after each disclosure
    }
}

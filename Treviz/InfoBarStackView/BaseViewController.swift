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
    
    // Subclasses determine the header title.
    func headerTitle() -> String { return "" }
    
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
        
        // Note:
        // We conditionally decide what flavor of header to use by "DisclosureTriangleAppearance" compilation flag,
        // which is defined in “Active Compilation Conditions” Build Settings (for passing conditional compilation flags to the Swift compiler).
        // If you want to use the non-triangle disclosure version, remove that compilation flag.
        //
        var storyboardIdentifier : String
#if DisclosureTriangleAppearance
        storyboardIdentifier = "HeaderTriangleViewController"
#else
        storyboardIdentifier = "HeaderViewController"
#endif
        let storyboard = NSStoryboard(name: "HeaderViewController", bundle: nil)
        guard let header = storyboard.instantiateController(withIdentifier: storyboardIdentifier) as? HeaderViewController else {
            return .none
        }
        header.title = self.headerTitle()
            
        return StackItemContainer(header: header, body: self, state: self.disclosureState)
    }()
    
    
    func didDisclose(){
        // Function to be overridden. Runs after each disclosure
    }
}

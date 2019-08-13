/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Base view controller to be subclassed for any view controller in the stack view.
 */

import Cocoa

class BaseViewController : ViewController, StackItemBody {
    
    //static let StackItemBackgroundColor = NSColor(calibratedRed: 244/255, green:244/255, blue:244/255, alpha:1)
    
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
        //view.layer?.backgroundColor = BaseViewController.StackItemBackgroundColor.cgColor
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

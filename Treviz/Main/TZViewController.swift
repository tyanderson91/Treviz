/*
Abstract:
NSViewController subclass controlling the user interface of the Document.
This is a custom subclass that passes the Analysis document data to all child view controllers
*/

import Cocoa
//TODO: turn this into some kind of extension on top of NSViewController


class TZViewController: NSViewController {
    
    override var representedObject: Any? {
        didSet {
            // Pass down the represented object to all of the child view controllers.
            for child in children {
                child.representedObject = representedObject
            }
        }
    }
    
    weak var analysis: Analysis! {
        didSet {
            for child in children {
                if let tzchild = child as? TZViewController { tzchild.analysis = self.analysis }
                else if let tzchild = child as? TZSplitViewController { tzchild.analysis = self.analysis }
            }
        }
    }
    
}


class TZSplitViewController: NSSplitViewController {
    override var representedObject: Any? {
        didSet {
            // Pass down the represented object to all of the child view controllers.
            for child in children {
                child.representedObject = representedObject
            }
        }
    }
    
    weak var analysis: Analysis! {
        didSet {
            for child in children {
                if let tzchild = child as? TZViewController { tzchild.analysis = self.analysis }
                else if let tzchild = child as? TZSplitViewController { tzchild.analysis = self.analysis }
            }
        }
    }
    
}

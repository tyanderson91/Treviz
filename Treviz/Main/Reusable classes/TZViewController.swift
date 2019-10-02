/*
Abstract:
NSViewController subclass controlling the user interface of the Document.
This is a custom subclass that passes the Analysis document data to all child view controllers
*/

import Cocoa
//TODO: turn this into some kind of extension on top of NSViewController
class TZViewController: NSViewController {

    /// - Tag: setRepresentedObjectExample
    override var representedObject: Any? {
        didSet {
            // Pass down the represented object to all of the child view controllers.
            for child in children {
                child.representedObject = representedObject
            }
        }
    }

    weak var analysis: Analysis? {
        if let analysisRepresentedObject = representedObject as? Analysis {
            return analysisRepresentedObject
        }
        return nil
    }

}


class SplitViewController: NSSplitViewController {
    
    /// - Tag: setRepresentedObjectExample
    override var representedObject: Any? {
        didSet {
            // Pass down the represented object to all of the child view controllers.
            for child in children {
                child.representedObject = representedObject
            }
        }
    }
    
    weak var analysis: Analysis? {
        if let analysisRepresentedObject = representedObject as? Analysis {
            return analysisRepresentedObject
        }
        return nil
    }
    
}

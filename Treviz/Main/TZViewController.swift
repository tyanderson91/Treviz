/*
Abstract:
NSViewController subclass controlling the user interface of the Document.
This is a custom subclass that passes the Analysis document data to all child view controllers
*/

import Cocoa

class TZViewController: NSViewController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        for child in self.children {
            if child is TZViewController {
                (child as! TZViewController).analysis = analysis
            } else if child is TZSplitViewController {
                (child as! TZSplitViewController).analysis = analysis
            }
        }
    }
    
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis) {
        self.init(coder: coder)
        analysis = curAnalysis
    }
    
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
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        _ = segue.destinationController
        super.prepare(for: segue, sender: sender)
    }
    
}


class TZSplitViewController: NSSplitViewController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        for child in self.children {
            if child is TZViewController {
                (child as! TZViewController).analysis = analysis
            } else if child is TZSplitViewController {
                (child as! TZSplitViewController).analysis = analysis
            }
        }
    }
    
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis) {
        self.init(coder: coder)
        analysis = curAnalysis
    }
    
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
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        _ = segue.destinationController
        super.prepare(for: segue, sender: sender)
    }
    
}

//
//  InitStateViewController.swift
//  
//
//  Created by Tyler Anderson on 3/27/19.
//

import Cocoa

class InitStateViewController: BaseViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {

    @IBOutlet weak var outlineView: NSOutlineView!
    var inputs : [InitState] = []
    
    override func headerTitle() -> String { return NSLocalizedString("Initial State", comment: "") }

    override func viewDidLoad() {
        super.viewDidLoad()
        let filePath = Bundle.main.path(forResource: "AnalysisInputs", ofType: "plist")
        if (filePath != nil) {
            self.inputs = InitState.inputList(filename: filePath!)
        }
        outlineView.reloadData()
        // Do view setup here.
    }
    
    func outlineViewColumnDidResize(_ notification: Notification) {
        //TODO: enforce width constraints
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {return self.inputs.count}
        let itemObj = item as! NSObject
        if itemObj.isKind(of: InitState.self){
            return (itemObj as! InitState).children.count
        }
        else {//Looking at the top level
            return self.inputs.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {return self.inputs[index]}
        let itemObj = item as! NSObject
        if itemObj.isKind(of: InitState.self){
            return (itemObj as! InitState).children[index]
        }
        else {
            return self.inputs[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let itemObj = item as! NSObject
        
        //let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "NameCellView"), owner: self) as! NSTableCellView
        //newView.textField?.stringValue = "this"
        //return newView
        
        if itemObj.isKind(of: InitState.self){
            let curItem = item as! InitState
            if tableColumn?.identifier.rawValue == "ValueColumn"{
                if let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "ValueCellView"), owner: self) {
                    let textField = (newView as! NSTableCellView).textField
                    let dubVal = curItem.value
                    if dubVal == nil{
                        textField?.stringValue = "--"
                    } else {
                        textField?.stringValue = "\(String(describing: dubVal))"
                    }
                    return newView
                }
            }
            else if tableColumn?.identifier.rawValue == "NameColumn"{
                //let newView1 = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "NameCellView"), owner: self) as! NSTableCellView
                //newView1.textField?.stringValue = curItem.name
                //return newView1
                var newView : NSTableCellView? = nil
                if curItem.itemType == "header"{
                    newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "HeaderCellView"), owner: self) as? NSTableCellView
                    let isValidImageView = newView!.imageView as! NSImageView
                    isValidImageView.image = NSImage.init(named: (curItem.isValid ? NSImage.statusAvailableName : NSImage.statusUnavailableName))
                }
                else if curItem.itemType == "subHeader"{
                    newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "SubHeaderCellView"), owner: self) as? NSTableCellView
                }
                else if curItem.itemType == "variable"{
                    newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "NameCellView"), owner: self) as? NSTableCellView
                }
                //TODO: actual error checking
                let textField = newView!.textField
                textField?.stringValue = curItem.name
                
                return newView
            }
            else if tableColumn?.identifier.rawValue == "UnitsColumn"{
                let newView1 = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "UnitsCellView"), owner: self) as! NSTableCellView
                newView1.textField?.stringValue = curItem.units
                return newView1
                let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "UnitsCellView"), owner: self) as! NSTableCellView
                let textField = newView.textField
                textField?.stringValue = curItem.units
                
                return newView
            }
            else if tableColumn?.identifier.rawValue == "ParameterColumn"{
                let newView1 = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "ParamCheckBoxView"), owner: self)
                return newView1
                let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "ParamCheckBoxView"), owner: self) as! NSButton
                if curItem.itemType=="variable"{
                    newView.state = curItem.isParam ? NSControl.StateValue.on : NSControl.StateValue.off
                }
                else if curItem.itemType == "header" || curItem.itemType == "subHeader" {
                    newView.state = curItem.hasParams() ? NSControl.StateValue.on : NSControl.StateValue.off
                }
                return newView
            }
            
            return nil
        }
        
        return nil
        
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let itemObj = item as! InitState
        return (itemObj.children.count > 0) ? true : false
    }
 
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return self.inputs
    }
 
// - (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
 //return [item children] ? [[item children] objectAtIndex:index] : [self.inputs objectAtIndex:index];
}

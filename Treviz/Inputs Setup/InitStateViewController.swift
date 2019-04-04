//
//  InitStateViewController.swift
//  
//
//  Created by Tyler Anderson on 3/27/19.
//

import Cocoa

class InitStateViewController: BaseViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {

    @IBOutlet weak var outlineView: NSOutlineView!
    var inputs : [InputSetting] = []
    override func headerTitle() -> String { return NSLocalizedString("Initial State", comment: "") }

    override func viewDidLoad() {
        super.viewDidLoad()
        let stateFilePath = Bundle.main.path(forResource: "AnalysisInputs", ofType: "plist")
        if (stateFilePath != nil) {
            self.inputs = InputSetting.inputList(filename: stateFilePath!)
        }
        outlineView.reloadData()        // Do view setup here.
    }
    
    func outlineViewColumnDidResize(_ notification: Notification) {
        //TODO: enforce width constraints
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {return self.inputs.count}
        let itemObj = item as! NSObject
        if itemObj.isKind(of: InputSetting.self){
            return (itemObj as! InputSetting).children.count
        }
        else {//Looking at the top level
            return self.inputs.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {return self.inputs[index]}
        let itemObj = item as! NSObject
        if itemObj.isKind(of: InputSetting.self){
            return (itemObj as! InputSetting).children[index]
        }
        else {
            return self.inputs[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let curItem = item as? InputSetting {
            if curItem.itemType != "var"{//should be header or subHeader
                if tableColumn?.identifier.rawValue == "NameColumn"{
                    if curItem.itemType == "header"{
                        if let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "HeaderCellView"), owner: self){
                            let viewAsHeader = newView as! NSTableCellView
                            viewAsHeader.textField?.stringValue = curItem.name
                            if let thisImageView = viewAsHeader.imageView {
                                thisImageView.image = NSImage.init(named: (curItem.isValid ? NSImage.statusAvailableName : NSImage.statusUnavailableName))
                            }
                            return newView
                        }
                    }
                    else if curItem.itemType == "subHeader"{
                        if let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "SubHeaderCellView"), owner: self){
                            let viewAsSubHeader = newView as! NSTableCellView
                            viewAsSubHeader.textField?.stringValue = curItem.name
                            return newView
                        }
                    }
                }
                
                else if tableColumn?.identifier.rawValue == "ParameterColumn" {
                    if let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "HasParamsCellView"), owner: self){
                        if let thisImageView = (newView as? NSTableCellView)?.imageView {
                            let curimage = curItem.isParam ? NSImage(named: NSImage.menuOnStateTemplateName) : nil//NSImage(named : NSImage.statusUnavailableName)
                            thisImageView.image = curimage
                        }
                        return newView
                    }
                }
                return nil  //if a non-var object has a name other than those mentioned above
            }
            else {
                if tableColumn?.identifier.rawValue == "ValueColumn"{
                    if let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "ValueCellView"), owner: self) {
                        let textField = (newView as! NSTableCellView).textField
                        let dubVal = curItem.value
                        if dubVal == nil{
                            textField?.stringValue = "--"
                        } else {
                            textField?.stringValue = "\(String(describing: dubVal!))"
                        }
                        return newView
                    }
                }
                else if tableColumn?.identifier.rawValue == "NameColumn"{
                    let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "NameCellView"), owner: self) as? NSTableCellView
                    //TODO: actual error checking
                    if let textField = newView?.textField{
                        textField.stringValue = curItem.name
                    }
                    return newView
                }
                else if tableColumn?.identifier.rawValue == "UnitsColumn"{
                    let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "UnitsCellView"), owner: self) as! NSTableCellView
                    let textField = newView.textField
                    let str = curItem.units
                    textField?.stringValue = str
                    return newView
                }
                else if tableColumn?.identifier.rawValue == "ParameterColumn"{
                    let newView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(rawValue: "ParamCheckBoxView"), owner: self) as! NSButton
                    newView.state = NSControl.StateValue.off//curItem.isParam ? NSControl.StateValue.on : NSControl.StateValue.off
                    return newView
                }
                return nil
            }//End of all var item objects
        }//End of if item is type InitState
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let itemObj = item as! InputSetting
        return (itemObj.children.count > 0) ? true : false
    }
 
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let stateItem = item as? InputSetting {
            if tableColumn?.identifier.rawValue == "ValueColumn" && stateItem.itemType == "var" {
                let val = stateItem.itemType == "var" ? stateItem.value : nil
                return val
            }
            else if tableColumn?.identifier.rawValue == "NameColumn"{
                return stateItem.name
            }
            else if tableColumn?.identifier.rawValue == "UnitsColumn"{
                let units = stateItem.itemType == "var" ? stateItem.units : nil
                return units
            }
            else if tableColumn?.identifier.rawValue == "ParameterColumn"{
                return stateItem.isParam
            }
        }
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        if tableColumn?.identifier.rawValue == "ValueColumn" {
            return true
        }
        return true
    }
    
    @IBAction func setParams(_ sender: Any) {
        if let button = sender as? NSView{
            let row = outlineView.row(for: button)
            if let thisInputSetting = outlineView.item(atRow: row) as? InputSetting{
                thisInputSetting.isParam = (sender as! NSButton).state.rawValue == 1 ? true : false
            }
        }
        
    }
    
    //func setParam(_)
    /*
    - (void)_removeItemAtRow:(NSInteger)row {
    id item = [self.outlineView itemAtRow:row];
    ATDesktopFolderEntity *parent = (ATDesktopFolderEntity *)[self.outlineView parentForItem:item];
    if (parent == nil) {
    parent = self.rootContents;
    }
    NSInteger indexInParent = [parent.children indexOfObject:item];
    [parent.children removeObjectAtIndex:indexInParent];
    
    if (parent == self.rootContents) {
    parent = nil;
    }
    [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:indexInParent]
    inParent:parent
    withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideLeft];
    }
    
    
    #pragma mark - Actions
    
    - (IBAction)pathCtrlValueChanged:(id)sender {
    NSURL *url = self.pathCtrlRootDirectory.objectValue;
    self.rootContents = [[ATDesktopFolderEntity alloc] initWithFileURL:url];
    [self.outlineView reloadData];
    }
    
    - (IBAction)btnDeleteRowClicked:(id)sender {
    NSInteger row = [self.outlineView rowForView:sender];
    if (row != -1) {
    // Take care of the case of the user clicking on a row that was in the middle of being deleted
    [self _removeItemAtRow:row];
    }
    }*/
}


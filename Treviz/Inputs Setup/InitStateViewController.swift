//
//  InitStateViewController.swift
//  
//
//  Created by Tyler Anderson on 3/27/19.
//

import Cocoa
import Foundation

class InitStateViewController: BaseViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {

    @IBOutlet weak var outlineView: InitStateOutlineView!
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
                switch tableColumn?.identifier{
                case NSUserInterfaceItemIdentifier.nameColumn:
                    if curItem.itemType == "header"{
                        return InputsViewController.headerCellView(view: outlineView, thisInput: curItem)
                    }
                    else if curItem.itemType == "subHeader"{
                        return InputsViewController.subHeaderCellView(view: outlineView, thisInput: curItem)
                    }
                case NSUserInterfaceItemIdentifier.initStateParamColumn:
                    return InputsViewController.inputHeaderParamCellView(view: outlineView, thisInput: curItem)
                default: return nil}
            }
            else {
                switch tableColumn?.identifier{
                case NSUserInterfaceItemIdentifier.nameColumn:
                    return InputsViewController.nameCellView(view: outlineView, thisInput: curItem)
                case NSUserInterfaceItemIdentifier.initStateValueColumn:
                    return InputsViewController.inputValueCellView(view: outlineView, thisInput: curItem)
                case NSUserInterfaceItemIdentifier.unitsColumn:
                    return InputsViewController.unitsCellView(view: outlineView, thisInput: curItem)
                case NSUserInterfaceItemIdentifier.initStateParamColumn:
                    return InputsViewController.inputParamCellView(view: outlineView, thisInput: curItem)
                default:
                    return nil
                }
            }//End of all var item objects
        }//End of if item is type InputSetting
        return nil
    }

    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let itemObj = item as! InputSetting
        return (itemObj.children.count > 0) ? true : false
    }
 
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let stateItem = item as? InputSetting {
            
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.initStateValueColumn:
                if stateItem.itemType == "var" {return stateItem.value}
                else {return nil}
            case NSUserInterfaceItemIdentifier.nameColumn:
                return stateItem.name
            case NSUserInterfaceItemIdentifier.unitsColumn:
                if stateItem.itemType == "var" {return stateItem.units}
                else {return nil}
            case NSUserInterfaceItemIdentifier.initStateParamColumn:
                return stateItem.isParam
            default:
                return nil
            }
        }
        return nil
    }

    @IBAction func setParams(_ sender: Any) {
        if let button = sender as? NSView{
            let row = outlineView.row(for: button)
            if let thisInputSetting = outlineView.item(atRow: row) as? InputSetting{
                thisInputSetting.isParam = (sender as! NSButton).state == NSControl.StateValue.on ? true : false
                outlineView.refreshSetting(thisInputSetting)
                NotificationCenter.default.post(name: .didSetParam, object: thisInputSetting)
            }
        }
    }
    
    @IBAction func editUnits(_ sender: NSTextField) {
        let curRow = outlineView.row(for: sender)
        if let thisInputSetting = outlineView.item(atRow: curRow) as? InputSetting{
            thisInputSetting.units = sender.stringValue
            NotificationCenter.default.post(name: .didChangeUnits, object: thisInputSetting)
        }
    }
    
    @IBAction func editValues(_ sender: NSTextField) {
        let curRow = outlineView.row(for: sender)
        if let thisInputSetting = outlineView.item(atRow: curRow) as? InputSetting{
            let valuestr = sender.stringValue
            thisInputSetting.value = Double(valuestr)
            NotificationCenter.default.post(name: .didChangeValue, object: thisInputSetting)
        }
    }
    
    func getInputSettingData(_ input : [InputSetting] = [])->[InputSetting]{
        var curInputs : [InputSetting]
        var outputs : [InputSetting] = []
        if input == []{
            curInputs = self.inputs
        } else {curInputs = input}
        
        for thisInput in curInputs{
            var newInputs = [InputSetting]()
            if thisInput.itemType == "var"{
                newInputs = [thisInput]
            }
            else {
                newInputs = getInputSettingData(thisInput.children)
            }
            outputs.append(contentsOf: newInputs)
        }
        return outputs
    }
}


//
//  InitStateViewController.swift
//  
//
//  Created by Tyler Anderson on 3/27/19.
//

import Cocoa
import Foundation

class InitStateViewController: BaseViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {

    @IBOutlet weak var outlineView: NSOutlineView!
    var inputVars : [Parameter] = []
    var inputVarStructure : InitStateHeader?
    override func headerTitle() -> String { return NSLocalizedString("Initial State", comment: "") }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadData(_:)), name: .didLoadAppDelegate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadData(_:)), name: .didSetParam, object: nil)
    }
    
    override func viewDidAppear() {
    }
    
    func outlineViewColumnDidResize(_ notification: Notification) {
        //TODO: enforce width constraints
    }
    
    override func didDisclose() {
    }
    
    @objc func loadData(_ notification: Notification){        
        let asys = self.analysis!
        inputVarStructure = asys.initStateGroups
        inputVars = self.analysis.analysisData.inputSettings
        //NotificationCenter.default.post(name: .didSetParam, object: nil) //TODO : Maybe this belongs in ParamViewController
        outlineView.reloadData()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // if item is Parameter {return 0}
        if item is InitStateHeader {
            let children = (item as! InitStateHeader).children
            return children.count}
        else {
            let children = inputVarStructure?.children
            return children?.count ?? 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item is InitStateHeader{
            let children = (item as! InitStateHeader).children
            return children[index]
        }
        else {
            let children = inputVarStructure?.children
            return children?[index] ?? "None"
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let curItem = item as? InitStateHeader {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn:
                if let itemAsSubHeader = curItem as? InitStateSubHeader{
                    return InputsViewController.subHeaderCellView(view: outlineView, thisInput: itemAsSubHeader)
                } else {
                    return InputsViewController.headerCellView(view: outlineView, thisInput: curItem)
                }
            case NSUserInterfaceItemIdentifier.initStateParamColumn:
                return InputsViewController.inputHeaderParamCellView(view: outlineView, thisInput: curItem)
            default: return nil}
        }
        else if let curItem = item as? Parameter {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn:
                return InputsViewController.nameCellView(view: outlineView, thisInput: curItem)
            case NSUserInterfaceItemIdentifier.initStateValueColumn:
                return InputsViewController.inputValueCellView(view: outlineView, inputVar: curItem as? Variable)
            case NSUserInterfaceItemIdentifier.unitsColumn:
                return InputsViewController.unitsCellView(view: outlineView, thisInput: curItem as? Variable)
            case NSUserInterfaceItemIdentifier.initStateParamColumn:
                return InputsViewController.inputParamCellView(view: outlineView, thisInput: curItem)
            default:
                return nil
            }
        }//End of if item is type InputSetting
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is InitStateHeader ? true : false
    }
 
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let paramItem = item as? Parameter {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn:
                return paramItem.name
            case NSUserInterfaceItemIdentifier.initStateParamColumn:
                return paramItem.isParam
            default:
                return nil
            }
        }
        if let varItem = item as? Variable {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.initStateValueColumn:
                return varItem.value[0]
            case NSUserInterfaceItemIdentifier.unitsColumn:
                return varItem.units
            default:
                return nil
            }
        }
        if let headerItem = item as? InitStateHeader {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.initStateParamColumn:
                return headerItem.hasParams
            default:
                return nil
            }
        }
        return nil
    }

    @IBAction func setParams(_ sender: Any) {
        if let button = sender as? NSView{
            let row = outlineView.row(for: button)
            if var thisParam = outlineView.item(atRow: row) as? Parameter {
                thisParam.isParam = (sender as! NSButton).state == NSControl.StateValue.on ? true : false
                //outlineView.refreshSetting(thisParam)
                NotificationCenter.default.post(name: .didSetParam, object: nil)
            }
        }
    }
    
    @IBAction func editUnits(_ sender: NSTextField) {
        let curRow = outlineView.row(for: sender)
        if let thisParam = outlineView.item(atRow: curRow) as? Variable{
            thisParam.units = sender.stringValue
            NotificationCenter.default.post(name: .didChangeUnits, object: nil)
        }
    }
    
    @IBAction func editValues(_ sender: NSTextField) {
        let curRow = outlineView.row(for: sender)
        if let thisParam = outlineView.item(atRow: curRow) as? Variable{
            if let value = Double(sender.stringValue) {
                thisParam.value[0] = value}
            NotificationCenter.default.post(name: .didChangeValue, object: nil)
        }
    }
    
}


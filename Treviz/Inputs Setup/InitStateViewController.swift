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
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: .didChangeUnits, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: .didChangeValue, object: nil)
    }
    
    override func viewDidAppear() {
        // outlineView.wantsLayer = true
        // outlineView.layer?.backgroundColor = NSColor.red.cgColor
    }
    
    func outlineViewColumnDidResize(_ notification: Notification) {
        //TODO: enforce width constraints
    }
    
    override func didDisclose() {
    }
    
    @objc func loadData(_ notification: Notification){        
        inputVarStructure = analysis.initStateGroups
        inputVars = self.analysis.inputSettings
        outlineView.reloadData()
    }
    @objc func reloadData(_ notification: Notification){
        outlineView.reloadData()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item is InitStateHeader {
            let children = (item as! InitStateHeader).children
            return children.count
        } else if item is Variable {
            return 0
        } else {
            return inputVarStructure?.children.count ?? 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item is InitStateHeader{
            let children = (item as! InitStateHeader).children
            return children[index]
        } else if item is Variable {
            return 0
        } else {
            let children = inputVarStructure?.children
            return children?[index] ?? 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        //  Custom view creators live in InputsCellViews.swift
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
        }
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is InitStateHeader ? true : false
    }
 
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let varItem = item as? Variable {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.initStateValueColumn:
                return varItem.value[0]
            case NSUserInterfaceItemIdentifier.unitsColumn:
                return varItem.units
            case NSUserInterfaceItemIdentifier.nameColumn:
                return varItem.name
            case NSUserInterfaceItemIdentifier.initStateParamColumn:
                return varItem.isParam
            default:
                return nil
            }
        }
        if let headerItem = item as? InitStateHeader {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.initStateParamColumn:
                return headerItem.hasParams
            case NSUserInterfaceItemIdentifier.nameColumn:
                return headerItem.name
            default:
                return nil
            }
        }
        return nil
    }

    @IBAction func setParams(_ sender: Any) {
        guard let button = sender as? NSButton else {return}
        let row = outlineView.row(for: button)
        if var thisParam = outlineView.item(atRow: row) as? Parameter {
            thisParam.isParam = button.state == NSControl.StateValue.on
            NotificationCenter.default.post(name: .didSetParam, object: nil)
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
            if let value = VarValue(sender.stringValue) {
                thisParam.value[0] = value}
            NotificationCenter.default.post(name: .didChangeValue, object: nil)
        }
    }
    
}


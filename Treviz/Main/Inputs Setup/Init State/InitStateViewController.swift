//
//  InitStateViewController.swift
//  
//
//  Created by Tyler Anderson on 3/27/19.
//

import Cocoa
import Foundation

class InitStateViewController: PhasedViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {

    @IBOutlet weak var outlineScrollView: NSScrollView!
    @IBOutlet weak var outlineClipView: NSClipView!
    @IBOutlet weak var outlineView: NSOutlineView!
    var inputVars : [Parameter] { phase.varList }
    var inputVarStructure : InitStateHeader { return phase.initStateGroups }
    override func getHeaderTitle() -> String { return NSLocalizedString("Boundary States", comment: "") }
    //var inputsViewController: InputsViewController?
    
    // Terminal Condition variables
    @IBOutlet weak var terminalConditionPopupButton: NSPopUpButton!
    private var terminalConditionCandidates: [Condition] {
        analysis.conditions.filter { !$0.containsGlobalCondition() }
    }
    @IBOutlet weak var outlineScrollViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.autosaveExpandedItems = false  // TODO: Implement functions that allow this
        outlineView.autosaveName = "initStateOutlineView"
        //Load data
        outlineView.reloadData()
        getTerminalConditionPopupOptions()
        //outlineView.postsBoundsChangedNotifications = true
        updateOutlineViewHeight()
        //outlineScrollView.hasVerticalScroller = false
        outlineScrollView.verticalScroller?.isEnabled = false
        outlineScrollView.verticalScrollElasticity = .none
        outlineScrollView.verticalScroller?.refusesFirstResponder = true
    }
    
    func updateOutlineViewHeight() {
        //outlineView.reloadData()
        //outlineScrollViewHeightConstraint.constant = outlineView.intrinsicContentSize.height*1.1 + 30
        //analysis.logMessage("newheight: \(outlineScrollViewHeightConstraint.constant)")
    }
    
    @IBAction func outlineViewAction(_ sender: Any) {
        updateOutlineViewHeight()
    }
    
    override func viewDidAppear() {
    }
    
    func outlineViewColumnDidResize(_ notification: Notification) {
    }
        
    func outlineViewItemDidExpand(_ notification: Notification) {
        updateOutlineViewHeight()
    }
    func outlineViewItemDidCollapse(_ notification: Notification) {
        updateOutlineViewHeight()
    }
    override func didDisclose() {
    }   
    
    //MARK: Outline View Datasource and Delegate
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item is InitStateHeader {
            let children = (item as! InitStateHeader).children
            return children.count
        } else if item is Variable {
            return 0
        } else {
            return inputVarStructure.children.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item is InitStateHeader{
            let children = (item as! InitStateHeader).children
            return children[index]
        } else if item is Variable {
            return 0
        } else {
            let children = inputVarStructure.children
            return children[index] 
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        //  Custom view creators live in InputsCellViews.swift
        var outputView: NSView?
        if let curItem = item as? InitStateHeader {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn:
                if let itemAsSubHeader = curItem as? InitStateSubHeader{
                    outputView = InputsViewController.subHeaderCellView(view: outlineView, thisInput: itemAsSubHeader)
                } else {
                    outputView = InputsViewController.headerCellView(view: outlineView, thisInput: curItem)
                }
            case NSUserInterfaceItemIdentifier.initStateRunVariantColumn:
                outputView = InputsViewController.inputHeaderParamCellView(view: outlineView, thisInput: curItem)
            default: return nil}
        }
        else if let curItem = item as? Variable {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn:
                outputView = InputsViewController.nameCellView(view: outlineView, thisInput: curItem)
            case NSUserInterfaceItemIdentifier.initStateValueColumn:
                outputView = InputsViewController.inputValueCellView(view: outlineView, inputVar: curItem)
                if !self.containsParamView(for: curItem.id) {
                    paramValueViews.append(outputView as! ParamValueView)
                }
            case NSUserInterfaceItemIdentifier.unitsColumn:
                outputView = InputsViewController.unitsCellView(view: outlineView, thisInput: curItem)
            case NSUserInterfaceItemIdentifier.initStateRunVariantColumn:
                outputView = InputsViewController.inputParamCellView(view: outlineView, thisInput: curItem)
            default:
                return nil
            }
        }
        return outputView
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
            case NSUserInterfaceItemIdentifier.initStateRunVariantColumn:
                return varItem.isParam
            default:
                return nil
            }
        }
        if let headerItem = item as? InitStateHeader {
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.initStateRunVariantColumn:
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
            switch button.state {
            case .on:
                analysis.enableParam(param: thisParam)
            case .off:
                analysis.disableParam(param: thisParam)
            default:
                thisParam.isParam = false
            }
            inputsViewController?.reloadParams()
        }
    }
    
    @IBAction func editUnits(_ sender: NSTextField) {
        let curRow = outlineView.row(for: sender)
        guard let thisParam = outlineView.item(atRow: curRow) as? Variable else { return }
        if let thisUnit = Unit.fromString(stringSymbol: sender.stringValue) {
            if let oldDim = thisParam.units as? Dimension, let newDim = thisUnit as? Dimension { // Convert the value
                guard (oldDim as? TZDim)?.unitType() == (newDim as? TZDim)?.unitType()
                else {
                    sender.stringValue = thisParam.units.symbol
                    return } // Make sure the types are the same
                let oldVal = Measurement(value: thisParam.value[0], unit: oldDim)
                let newVal = oldVal.converted(to: newDim)
                thisParam.value[0] = newVal.value; thisParam.units = thisUnit
            } else {
                thisParam.units = thisUnit
            }
            outlineView.reloadData(forRowIndexes: IndexSet(integer: curRow), columnIndexes: IndexSet(integersIn: 0...outlineView.numberOfColumns-1))
        } else {
            sender.stringValue = thisParam.units.symbol
        }
    }
    
    @IBAction func editValues(_ sender: NSTextField) {
        let curRow = outlineView.row(for: sender)
        if let thisParam = outlineView.item(atRow: curRow) as? Variable{
            /*if let value = VarValue(sender.stringValue) {
                thisParam.value[0] = value}
            */
            thisParam.setValue(to: sender.stringValue)
            inputsViewController?.reloadParams()
        }
    }
    
    // MARK: Terminal Condition
    @IBAction override func didChangeParamValue(_ sender: Any) {
        if let curCondition = analysis.conditions.first(where: { $0.name == terminalConditionPopupButton.titleOfSelectedItem }) {
            phase.terminalCondition = curCondition
        }
    }
    
    private func setSelection(){
        if let curCondition = phase.terminalCondition {
            terminalConditionPopupButton.selectItem(withTitle: curCondition.name)
        } else {terminalConditionPopupButton.selectItem(at: -1)}
    }
    
    private func getTerminalConditionPopupOptions(){
        let menuItemNames: [String] = terminalConditionCandidates.compactMap { $0.name }
        terminalConditionPopupButton.removeAllItems()
        terminalConditionPopupButton.addItems(withTitles: menuItemNames)
        setSelection()
    }
}

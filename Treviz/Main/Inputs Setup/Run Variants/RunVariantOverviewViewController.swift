//
//  RunVariantOverviewViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/10/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

extension NSUserInterfaceItemIdentifier {
    static let rvVariantPopupCellView = NSUserInterfaceItemIdentifier.init("variantTypePopupCellView")
    static let rvSummaryCellView = NSUserInterfaceItemIdentifier.init("summaryCellView")
    static let rvVariantTypeColumn = NSUserInterfaceItemIdentifier("variantTypeColumn")
    static let rvSummaryColumn = NSUserInterfaceItemIdentifier.init("summaryColumn")
}

/**
 This ViewController provides an overview of all run variants, as well as a way to remove them and change their type
 */
class RunVariantOverviewViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource {
    var activeVariants: [RunVariant] { return analysis?.runVariants.filter({$0.isActive}) ?? [] }
    var parentVC: RunVariantViewController! { return parent as? RunVariantViewController }
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newNib = NSNib(nibNamed: "RunVariantCellViews", bundle: .main)
        tableView.register(newNib, forIdentifier: .rvAddRemoveNameCellView)
        tableView.register(newNib, forIdentifier: .rvCheckboxValueCellView)
        tableView.register(newNib, forIdentifier: .rvPopupValueCellView)
        tableView.register(newNib, forIdentifier: .rvTextValueField)
    }

    // MARK: Table View Delegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let thisRunVariant = activeVariants[row]
        switch tableColumn?.identifier{
        case NSUserInterfaceItemIdentifier.rvNameColumn:
            let nameView = nameCellView(thisInput: thisRunVariant)
            return nameView
        case NSUserInterfaceItemIdentifier.rvCurValueColumn:
            var paramValueView: ParamValueView?
            if thisRunVariant is EnumGroupRunVariant {
                paramValueView = runVariantPopupCellView(thisVariant: thisRunVariant, option: nil)
            } else if thisRunVariant is BoolRunVariant {
                paramValueView = runVariantCheckboxCellView(thisVariant: thisRunVariant, option: nil)
            } else {
                paramValueView = runVariantTextValueCellView(thisVariant: thisRunVariant, option: nil)
            }
            paramValueView?.action = #selector(didChangeParamValue(_:))
            paramValueView?.target = self
            return paramValueView
        case NSUserInterfaceItemIdentifier.rvVariantTypeColumn:
            return runVariantTypeCellView(thisInput: thisRunVariant)
        case NSUserInterfaceItemIdentifier.rvSummaryColumn:
            return runVariantSummaryCellView(thisInput: thisRunVariant)
        default:
            return nil
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return activeVariants.count
    }
    
    // MARK: Callbacks
    
    @objc func editVariantType(_ sender: Any) {
        guard let senderTypeButton = sender as? RunVariantTypeView else { return }
        let curRunVariant = senderTypeButton.runVariant
        let oldType = curRunVariant?.variantType
        let newType = RunVariantType(rawValue: senderTypeButton.title) ?? .single
        curRunVariant?.variantType = newType
        if newType == .trade && oldType != .trade {
            parentVC.tradesVC.padTradeValues(runVariant: curRunVariant!)
            parentVC.tradesVC.addRemoveTradeVariantCol(shouldAdd: true, runVariant: curRunVariant!)
        } else if oldType == .trade && newType != .trade {
            parentVC.tradesVC.addRemoveTradeVariantCol(shouldAdd: false, runVariant: curRunVariant!)
        }
        if !analysis.useGroupedVariants {
            parentVC.tradesVC.reloadPermutationsView()
        }
        parentVC.mcTableView.reloadData()
        tableView.reloadData()
        parentVC.updateNumRuns()
    }
    
    /** Deactivates a run variant and updates views accordingly */
    func deactivateRunVariant(_ index: Int){
        let thisParam = activeVariants[index]
        analysis.disableParam(param: thisParam.parameter)
        parentVC.inputsViewController?.updateParamValueView(for: thisParam.paramID)
        parentVC.inputsViewController?.updateParamSelectorView(for: thisParam.paramID)
        if thisParam.variantType == .trade {
            parentVC.tradesVC.addRemoveTradeVariantCol(shouldAdd: false, runVariant: thisParam)
            parentVC.tradesVC.reloadPermutationsView()
        }
    }
    
    @objc func removeVariantPressed(_ sender: Any) {
        let button = sender as! NSView
        let row = tableView.row(for: button)
        deactivateRunVariant(row)
    }
    @objc func didChangeParamValue(_ sender: Any) {
        if let thisSelector = sender as? ParamValueView {
            guard let param = thisSelector.parameter else {return}
            param.setValue(to: thisSelector.stringValue)
            parentVC.inputsViewController?.updateParamValueView(for: param.id)
            thisSelector.update()
        }
    }
    
    // MARK: Custom Cell Views
    private func nameCellView(thisInput: RunVariant)->RunVariantButtonNameCellView?{
        guard let newView = tableView.makeView(withIdentifier: .rvAddRemoveNameCellView, owner: RunVariantButtonNameCellView.self) as? RunVariantButtonNameCellView else {
            return nil
        }
        newView.nameTextField!.stringValue = thisInput.displayName
        newView.addRemoveButton.action = #selector(removeVariantPressed(_:))
        newView.addRemoveButton.target = self
        return newView
    }
    
    private func runVariantTypeCellView(thisInput: RunVariant?)->RunVariantTypeView?{
        guard thisInput != nil else {return nil}
        guard let newView = tableView.makeView(withIdentifier: .rvVariantPopupCellView, owner: self) as? RunVariantTypeView else { return nil }

        newView.runVariant = thisInput
        newView.selectItem(withTitle: thisInput!.variantType.rawValue)

        newView.action = #selector(editVariantType(_:))
        newView.target = self
        return newView
    }
    
    private func runVariantSummaryCellView(thisInput: RunVariant?)->NSTableCellView?{
        guard thisInput != nil else {return nil}
        let newView = tableView.makeView(withIdentifier: .rvSummaryCellView, owner: RunVariantViewController.self) as? NSTableCellView
        if let textField = newView?.textField {
            textField.stringValue = thisInput?.paramVariantSummary ?? ""
        }
        return newView
    }
    
    // MARK: Param Value Views
    private func runVariantTextValueCellView(thisVariant: RunVariant!, option: Int?)->ParamValueTextField? {
        guard thisVariant != nil else {return nil}
        let newView = tableView.makeView(withIdentifier: .rvTextValueField, owner: self) as? ParamValueTextField
        newView?.parameter = thisVariant.parameter
        var curOption: StringValue?
        if option != nil {
            guard thisVariant.tradeValues.count >= option! else { return nil }
            curOption = thisVariant.tradeValues[option!]
        } else { curOption = thisVariant.curValue }
        if let curVal = curOption?.valuestr {
            newView?.stringValue = curVal
        } else {
            newView?.stringValue = ""
        }
        return newView
    }
    private func runVariantPopupCellView(thisVariant: RunVariant!, option: Int?)->ParamValuePopupView? {
        guard thisVariant != nil else {return nil}
        var curOption: StringValue?
        let newView = tableView.makeView(withIdentifier: .rvPopupValueCellView, owner: self) as? ParamValuePopupView
        newView?.removeAllItems()
        newView?.parameter = thisVariant.parameter
        if option != nil {
            newView?.addItems(withTitles: thisVariant!.tradeValues.filter({$0 != nil}).map( {$0!.valuestr }))
            guard thisVariant.tradeValues.count >= option! else { return nil }
            curOption = thisVariant.tradeValues[option!]
        } else {
            newView?.addItems(withTitles: thisVariant!.options.map({$0.valuestr}))
            curOption = thisVariant.curValue
        }
        newView?.selectItem(withTitle: curOption!.valuestr)
        return newView
    }
    private func runVariantCheckboxCellView(thisVariant: RunVariant!, option: Int?)->ParamValueCheckboxView? {
        guard thisVariant != nil else {return nil}
        let newView = tableView.makeView(withIdentifier: .rvCheckboxValueCellView, owner: self) as? ParamValueCheckboxView
        newView?.parameter = thisVariant.parameter
        var enabled: Bool
        if option == nil {
            enabled = (thisVariant as? BoolRunVariant)?.paramEnabled ?? false
        } else { enabled = option! >= 1 }
        if !enabled {
            newView?.state = .off
            newView?.title = "Off"
        } else {
            newView?.state = .on
            newView?.title = "On"
        }
        return newView
    }
    
    override func keyDown(with event: NSEvent) {
        let thisKey = event.keyCode
        let thisRow = tableView.selectedRow

        guard thisRow >= 0 else { return }
        if thisKey == 117 || thisKey == 51 { // Delete and Backspace key
            guard thisRow < activeVariants.count else { return }
            deactivateRunVariant(thisRow)
        } else {
            super.keyDown(with: event)
        }
    }
    
}

/** Selector button for variant type */
class RunVariantTypeView: NSPopUpButton {
    var runVariant: RunVariant! {
        didSet {
            self.removeAllItems()
            self.addItem(withTitle: RunVariantType.single.rawValue)
            if runVariant is MCRunVariant {
                self.addItem(withTitle: RunVariantType.montecarlo.rawValue)
            }
            self.addItem(withTitle: RunVariantType.trade.rawValue)
        }
    }
}

class RunVariantButtonNameCellView: NSView {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var addRemoveButton: NSButton!
}

class AddTradeValueCellView: NSTableCellView {
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var label: NSTextField!
}

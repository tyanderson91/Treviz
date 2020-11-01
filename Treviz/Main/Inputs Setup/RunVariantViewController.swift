//
//  ParamTableViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/5/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSStoryboardSegue.Identifier{
    static let paramTableViewSegue = "ParamTableViewControllerSegue"
}

class RunVariantViewController: TZViewController , NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    var params : [Parameter] { return analysis.parameters }
    var paramSettings: [RunVariant] { return analysis.runVariants.filter({$0.isActive}) }
    var inputsViewController: InputsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 18
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return paramSettings.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let thisRunVariant = paramSettings[row]
        let thisParam = thisRunVariant.parameter
        switch tableColumn?.identifier{
        case NSUserInterfaceItemIdentifier.paramNameColumn:
            return InputsViewController.nameCellView(view: tableView, thisInput: thisParam)
        case NSUserInterfaceItemIdentifier.paramValueColumn:
            if let thisEnumParam = thisParam as? EnumGroupParam {
                let newView = InputsViewController.paramPopupCellView(view: tableView, thisInput: thisEnumParam)
                return newView
            } else if let thisBoolParam = thisParam as? BoolParam {
                return InputsViewController.paramCheckboxCellView(view: tableView, thisInput: thisBoolParam)
            } else {
                return InputsViewController.paramValueCellView(view: tableView, thisInput: thisParam)
            }
        case NSUserInterfaceItemIdentifier.paramTypeColumn:
            return InputsViewController.paramTypeCellView(view: tableView, thisInput: thisRunVariant)
        case NSUserInterfaceItemIdentifier.paramSummaryColumn:
            return InputsViewController.paramSummaryCellView(view: tableView, thisInput: thisRunVariant)
        default:
            return nil
        }
    }
    
    private func tableView(_ tableView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let thisSetting = item as? Variable{
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn: return thisSetting.name
            case NSUserInterfaceItemIdentifier.paramValueColumn: return thisSetting.value
            case NSUserInterfaceItemIdentifier.unitsColumn: return thisSetting.units
            default: return nil
            }
        }
        if let thisSetting = item as? Parameter{
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn:
                inputsViewController?.reloadParams()
                return thisSetting.name
            default: return nil
            }
        }
        return nil
    }
    
    @IBAction func removeParamPressed(_ sender: Any) {
        let button = sender as! NSView
        let row = tableView.row(for: button)
        let thisParam = paramSettings[row]
        analysis.disableParam(param: thisParam.parameter)
        inputsViewController?.updateParamValueView(for: thisParam.paramID)
        inputsViewController?.updateParamSelectorView(for: thisParam.paramID)
    }
    
    @IBAction func editValues(_ sender: Any) {

        if let paramTextView = sender as? NSTextField {
            guard let parentParamView = paramTextView.superview as? ParamValueView
            else { return }
            let param = parentParamView.parameter
            param?.setValue(to: paramTextView.stringValue)
            inputsViewController?.updateParamValueView(for: param?.id ?? "")
        } else if let paramPopupView = sender as? ParamValuePopupView {
            guard let param = paramPopupView.parameter else { return }
            if let value = paramPopupView.selectedItem?.title { param.setValue(to: value) }
            inputsViewController?.updateParamValueView(for: param.id)
        } else if let paramCheckboxView = sender as? ParamValueCheckboxView {
            guard let param = paramCheckboxView.parameter else { return }
            if paramCheckboxView.state == .on { param.setValue(to: "True")}
            else { param.setValue(to: "False") }
            inputsViewController?.updateParamValueView(for: param.id)
        }
    }
}
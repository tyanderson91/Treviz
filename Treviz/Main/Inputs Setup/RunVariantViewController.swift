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

extension InputsViewController {
    static func distributionCellView(view: NSTableView, thisInput: MCRunVariant)->NSPopUpButton?{
        guard let newView = view.makeView(withIdentifier: .distributionCellView, owner: self) as? NSPopUpButton else { return nil }
        newView.addItems(withTitles: DistributionType.allCases.map{$0.rawValue})
        newView.selectItem(withTitle: thisInput.distributionType.rawValue)
        return newView
    }
    
    static func distributionParamCellView(view: NSTableView, thisInput: MCRunVariant, distributionParamIndex: Int)->NSTableCellView?{
        var stringValue: String
        if let paramValue = thisInput.distributionParams[distributionParamIndex] {
            stringValue = paramValue.valuestr
        } else { stringValue = "" }
        let paramName = thisInput.distributionParamNames[distributionParamIndex]
        guard let newView = view.makeView(withIdentifier: .distributionParamCellView, owner: self) as? NSTableCellView else { return nil }
        if let textField = newView.textField {
            textField.stringValue = stringValue
            textField.placeholderString = paramName
            textField.identifier = NSUserInterfaceItemIdentifier("param\(distributionParamIndex)")
        }
        return newView
    }
}

class RunVariantOverviewTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    var analysis: Analysis!
    var paramSettings: [RunVariant] { return analysis?.runVariants.filter({$0.isActive}) ?? [] }
    var parentVC: RunVariantViewController!
    
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
                parentVC.inputsViewController?.reloadParams()
                return thisSetting.name
            default: return nil
            }
        }
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return paramSettings.count
    }
}

fileprivate extension MCRunVariant {
    var distributionParams: [VarValue?] {
        get {
            switch self.distributionType {
            case .normal: return [mean, sigma]
            case .uniform: return [min, max]
            }
        } set {
            switch self.distributionType {
            case .normal:
                mean = newValue[0]; sigma = newValue[1]
            case .uniform:
                min = newValue[0]; max = newValue[1]
            }
        }
    }
    var distributionParamNames: [String] {
        get {
            switch self.distributionType {
            case .normal: return ["mean", "sigma"]
            case .uniform: return ["min", "max"]
            }
        }
    }
}
class RunVariantMCTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var analysis: Analysis!
    var paramSettings: [MCRunVariant] { return analysis?.runVariants.filter({$0.isActive && $0.variantType == .montecarlo}) as! [MCRunVariant] }
    var parentVC: RunVariantViewController!
    var tableView: NSTableView!
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let thisRunVariant = paramSettings[row]
        let thisParam = thisRunVariant.parameter
        switch tableColumn?.identifier{
        case NSUserInterfaceItemIdentifier.paramNameColumn:
            return InputsViewController.nameCellView(view: tableView, thisInput: thisParam)
        case NSUserInterfaceItemIdentifier.distributionColumn:
            return InputsViewController.distributionCellView(view: tableView, thisInput: thisRunVariant)
        case NSUserInterfaceItemIdentifier.distributionParam0Column:
            return InputsViewController.distributionParamCellView(view: tableView, thisInput: thisRunVariant, distributionParamIndex: 0)
        case NSUserInterfaceItemIdentifier.distributionParam1Column:
            return InputsViewController.distributionParamCellView(view: tableView, thisInput: thisRunVariant, distributionParamIndex: 1)
        default:
            return nil
        }
    }
    
    private func tableView(_ tableView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let thisSetting = item as? MCRunVariant{
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn: return thisSetting.parameter.name
            case NSUserInterfaceItemIdentifier.distributionColumn: return thisSetting.distributionType
            case NSUserInterfaceItemIdentifier.distributionParam0Column: return thisSetting.distributionParams[0]
            case NSUserInterfaceItemIdentifier.distributionParam1Column: return thisSetting.distributionParams[1]
            default: return nil
            }
        }
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return paramSettings.count
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        var thisParam = paramSettings[row]
        var paramIndex: Int
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier.distributionParam0Column: paramIndex = 0
        case NSUserInterfaceItemIdentifier.distributionParam1Column: paramIndex = 1
        default: paramIndex = -1
        }
        let newNum = object as? VarValue
        let newStr = object as? String
        thisParam.distributionParams[paramIndex] = VarValue(stringLiteral: newStr!)
    }
    @IBAction func didEditMCParamValue(_ sender: Any) {
        guard let thisView = sender as? NSTextField else { return }
        let newVal = VarValue(stringLiteral: thisView.stringValue)
        let variantIndex = tableView.row(for: thisView)
        var curVariant = paramSettings[variantIndex]
        switch thisView.identifier?.rawValue {
        case "param0":
            curVariant.distributionParams[0] = newVal
        case "param1":
            curVariant.distributionParams[1] = newVal
        default:
            return
        }
    }
    private func setParamPlaceholderNames(rowNum: Int) {
        let curVariant = paramSettings[rowNum]
        let startParamColumn = 2
        for thisParam in 0...1 {
            let paramView = tableView.view(atColumn: thisParam + startParamColumn, row: rowNum, makeIfNecessary: false) as? NSTableCellView
            let textField = paramView?.textField
            textField?.placeholderString = curVariant.distributionParamNames[thisParam]
        }
    }
    
    @IBAction func didChangeDistributionType(_ sender: Any) {
        guard let thisView = sender as? NSPopUpButton else { return }
        if let newDistribution = DistributionType(rawValue: thisView.selectedItem?.title ?? "") ?? nil {
            let variantIndex = tableView.row(for: thisView)
            var curVariant = paramSettings[variantIndex]
            curVariant.distributionType = newDistribution
            setParamPlaceholderNames(rowNum: variantIndex)
        }
    }
    
}

class RunVariantViewController: TZViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    var params : [Parameter] { return analysis.parameters }
    var paramSettings: [RunVariant] { return analysis?.runVariants.filter({$0.isActive}) ?? [] }
    var inputsViewController: InputsViewController?
    var overviewDelegate = RunVariantOverviewTableDelegate()
    @IBOutlet var mcDelegate: RunVariantMCTableDelegate!
    @IBOutlet weak var mcRunVariantTableView: NSTableView!
    @IBOutlet weak var tradesRunVariantTableView: NSTableView!
    @IBOutlet weak var numMCRunsTextField: NSTextField!
    @IBOutlet weak var numRunsTotalTextField: NSTextField!
    @IBOutlet weak var groupTradesRadioButton: NSButton!
    @IBOutlet weak var permuteTradesRadioButton: NSButton!
    
    override func viewDidLoad() {
        overviewDelegate.analysis = analysis
        overviewDelegate.parentVC = self
        mcDelegate.analysis = analysis
        mcDelegate.parentVC = self
        super.viewDidLoad()
        tableView.delegate = overviewDelegate
        tableView.dataSource = overviewDelegate
        tableView.rowHeight = 18
        mcRunVariantTableView.delegate = mcDelegate
        mcRunVariantTableView.dataSource = mcDelegate
        mcDelegate.tableView = mcRunVariantTableView
        mcRunVariantTableView.rowHeight = 18
        
        numMCRunsTextField.stringValue = analysis.numMonteCarloRuns.valuestr
        numRunsTotalTextField.stringValue = analysis.numRuns.valuestr
        
        if analysis.useGroupedVariants { groupTradesRadioButton.state = .on }
        else { permuteTradesRadioButton.state = .on }
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
    
    @IBAction func editVariantType(_ sender: Any) {
        guard let senderTypeButton = sender as? RunVariantTypeView else { return }
        senderTypeButton.runVariant.variantType = RunVariantType(rawValue: senderTypeButton.title) ?? .single
        mcRunVariantTableView.reloadData()
    }
    
    @IBAction func editNumMCRuns(_ sender: Any) {
        if let newNumRuns = Int(stringLiteral: numMCRunsTextField.stringValue) {
            analysis.numMonteCarloRuns = newNumRuns
        }
        numRunsTotalTextField.stringValue = analysis.numRuns.valuestr
    }
    @IBAction func editTradesType(_ sender: Any) {
        guard let button = sender as? NSButton else { return }
        switch button.identifier?.rawValue {
        case "groupTradesRadioButton":
            permuteTradesRadioButton.state = .off
        case "permuteTradesRadioButton":
            groupTradesRadioButton.state = .off
        default:
            return
        }
    }
}

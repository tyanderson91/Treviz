//
//  RunVariantMCViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/10/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

/** This extension is used to create distribution param views depending on the distribution type */
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

extension NSUserInterfaceItemIdentifier {
    static let rvDistributionCellView = NSUserInterfaceItemIdentifier.init("distributionTypePopupView")
    static let rvDistributionParamCellView = NSUserInterfaceItemIdentifier.init("distributionParamCellView")
    static let rvMCNameTableCellView = NSUserInterfaceItemIdentifier.init("rvMCNameTableCellView")
}
/**
 This View Controller displays and allows editing of data related to the Monte-Carlo aspects of the analysis
 */
class RunVariantMCViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource {
    var parentVC: RunVariantViewController! { return parent as? RunVariantViewController }
    let paramStartCol = 2 // First column to start showing distribution param views
    @IBOutlet weak var numMCRunsTextField: NSTextField!
    var mcVariants: [MCRunVariant] { return analysis?.mcRunVariants ?? [] }
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numMCRunsTextField.stringValue = analysis.numMonteCarloRuns.valuestr
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let thisRunVariant = mcVariants[row]
        switch tableColumn!.identifier{
        case .rvNameColumn:
            let newView = tableView.makeView(withIdentifier: .rvMCNameTableCellView, owner: self) as? NSTableCellView
            newView?.textField?.stringValue = (thisRunVariant as! RunVariant).displayName
            return newView
        case .rvDistributionColumn:
            return distributionCellView(thisInput: thisRunVariant)
        case .rvDistributionParam0Column:
            return distributionParamCellView(thisInput: thisRunVariant, distributionParamIndex: 0)
        case .rvDistributionParam1Column:
            return distributionParamCellView(thisInput: thisRunVariant, distributionParamIndex: 1)
        default:
            return nil
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return mcVariants.count
    }

    // MARK: Callbacks
    func updateDistributionParamViews(runVariantNum: Int) {
        let param1View = tableView.view(atColumn: paramStartCol, row: runVariantNum, makeIfNecessary: false) as? NSTableCellView
        let param2View = tableView.view(atColumn: paramStartCol+1, row: runVariantNum, makeIfNecessary: false) as? NSTableCellView
        let matchingVariant = mcVariants[runVariantNum]
        param1View?.textField?.stringValue = matchingVariant.distributionParams[0]?.valuestr ?? ""
        param2View?.textField?.stringValue = matchingVariant.distributionParams[1]?.valuestr ?? ""
    }
    
    @IBAction func didEditMCParamValue(_ sender: Any) {
        guard let thisView = sender as? NSTextField else { return }
        let newVal = VarValue(stringLiteral: thisView.stringValue)
        let variantIndex = tableView.row(for: thisView)
        var curVariant = mcVariants[variantIndex]
        switch thisView.identifier?.rawValue {
        case "param0":
            curVariant.distributionParams[0] = newVal
        case "param1":
            curVariant.distributionParams[1] = newVal
        default:
            return
        }
        parentVC.overviewTableView.reloadData()
    }
    
    // Sets placeholders for distribution parameter names (e.g. 'mean', 'sigma', 'min', 'max')
    private func setParamPlaceholderNames(rowNum: Int) {
        let curVariant = mcVariants[rowNum]
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
            var curVariant = mcVariants[variantIndex]
            curVariant.distributionType = newDistribution
            setParamPlaceholderNames(rowNum: variantIndex)
            updateDistributionParamViews(runVariantNum: variantIndex)
        }
        parentVC.overviewTableView.reloadData()
    }
    
    @IBAction func editNumMCRuns(_ sender: Any) {
        if let newNumRuns = Int(stringLiteral: numMCRunsTextField.stringValue) {
            analysis.numMonteCarloRuns = newNumRuns
        }
        parentVC.numRunsTotalTextField.stringValue = analysis.numRuns.valuestr
    }
    
    // MARK: Custom Cell Views
    private func distributionCellView(thisInput: MCRunVariant)->NSPopUpButton?{
        let newView = tableView.makeView(withIdentifier: .rvDistributionCellView, owner: self) as! NSPopUpButton
        newView.removeAllItems()
        newView.addItems(withTitles: DistributionType.allCases.map {$0.rawValue})
        newView.selectItem(withTitle: thisInput.distributionType.rawValue)
        return newView
    }
    
    private func distributionParamCellView(thisInput: MCRunVariant, distributionParamIndex: Int)->NSTableCellView?{
        var stringValue: String
        if let paramValue = thisInput.distributionParams[distributionParamIndex] {
            stringValue = paramValue.valuestr
        } else { stringValue = "" }
        let paramName = thisInput.distributionParamNames[distributionParamIndex]
        guard let newView = tableView.makeView(withIdentifier: .rvDistributionParamCellView, owner: self) as? NSTableCellView else { return nil }
        if let textField = newView.textField {
            textField.stringValue = stringValue
            textField.placeholderString = paramName
            textField.identifier = NSUserInterfaceItemIdentifier("param\(distributionParamIndex)")
        }
        return newView
    }
    
    override func keyDown(with event: NSEvent) {
        let thisKey = event.keyCode
        let thisRow = tableView.selectedRow
        guard thisRow >= 0 && thisRow < mcVariants.count else { return }
        let thisVariant = mcVariants[thisRow]
        if thisKey == 117 || thisKey == 51 { // Delete and Backspace key
            (thisVariant as? RunVariant)?.variantType = .single // Deleting an MC variant just turns its type back to single
            tableView.removeRows(at: IndexSet(integer: thisRow), withAnimation: .slideDown)
            parentVC.overviewVC.tableView.reloadData()
        } else { super.keyDown(with: event) }
    }
}

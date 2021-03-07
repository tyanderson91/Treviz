//
//  RunVariantTradesViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/10/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

extension NSUserInterfaceItemIdentifier {
    static let tradeGroupNameCellView = NSUserInterfaceItemIdentifier.init("tradeGroupNameCellView")
    static let addPermutationValueButton = NSUserInterfaceItemIdentifier.init("addPermutationValueButton")
}

/**
 This View Controller shows the data related to trade studies, and allows switching between a trade groups setting and a permutations setting
 */
class RunVariantTradesViewController: TZViewController {
    var parentVC: RunVariantViewController! { return parent as? RunVariantViewController }
    let minTradesColumnWidth: CGFloat = 35

    @IBOutlet weak var groupTradesRadioButton: NSButton!
    @IBOutlet weak var permuteTradesRadioButton: NSButton!
    @IBOutlet weak var tradeViewsStackView: CollapsibleStackView!
    
    @IBOutlet var groupsDelegate: GroupedTradeTableDelegate!
    @IBOutlet weak var groupsTableView: NSTableView!
    
    @IBOutlet weak var permutationsStackView: NSStackView!
    var permutationsTableViews: [NSTableView] = []
    var permutationsDelegates: [PermutationTradeTableViewController] = []
    
    override func viewDidLoad() {
        if analysis.useGroupedVariants {
            groupTradesRadioButton.state = .on
            tradeViewsStackView.showHideViews(.hide, index: [1])
        }
        else {
            permuteTradesRadioButton.state = .on
            tradeViewsStackView.showHideViews(.hide, index: [0])
        }
        groupsDelegate.analysis = analysis
        groupsDelegate.tableView = groupsTableView
        groupsDelegate.tradesVC = self
        let newNib = NSNib(nibNamed: "RunVariantCellViews", bundle: .main)
        groupsDelegate.tableView.register(newNib, forIdentifier: .rvAddRemoveNameCellView)
        groupsDelegate.tableView.register(newNib, forIdentifier: .rvTextValueField)
        groupsDelegate.tableView.register(newNib, forIdentifier: .rvCheckboxValueCellView)
        groupsDelegate.tableView.register(newNib, forIdentifier: .rvPopupValueCellView)
        
        for thisVariant in groupsDelegate.runVariants {
            addRemoveTradeVariantCol(shouldAdd: true, runVariant: thisVariant)
        }
    }
    
    /** This function allows adding or removing of run variant columns in the Grouped trades table view */
    func addRemoveTradeVariantCol(shouldAdd: Bool, runVariant: RunVariant){
        let identifier = NSUserInterfaceItemIdentifier(rawValue: runVariant.paramID)
        if shouldAdd {
            let newCol = NSTableColumn(identifier: identifier)
            newCol.minWidth = minTradesColumnWidth
            newCol.title = runVariant.displayName
            newCol.headerCell.alignment = .center
            groupsTableView.addTableColumn(newCol)
        } else {
            let matchingColNum = groupsTableView.column(withIdentifier: identifier)
            let matchingCol = groupsTableView.tableColumns[matchingColNum]
            groupsTableView.removeTableColumn(matchingCol)
        }
        groupsTableView.reloadData()
        parentVC.tradesVC.groupsTableView.sizeToFit()
    }
    
    /** Switches between grouped and permutation type */
    @IBAction func editTradesType(_ sender: Any) {
        guard let button = sender as? NSButton else { return }
        switch button.identifier?.rawValue {
        case "groupTradesRadioButton":
            permuteTradesRadioButton.state = .off
            tradeViewsStackView.showHideViews(.hide, index: [1])
            tradeViewsStackView.showHideViews(.show, index: [0])
            analysis.useGroupedVariants = true
            analysis.tradeRunVariants.forEach({padTradeValues(runVariant: $0)})
            groupsTableView.reloadData()
        case "permuteTradesRadioButton":
            groupTradesRadioButton.state = .off
            tradeViewsStackView.showHideViews(.hide, index: [0])
            analysis.useGroupedVariants = false
            reloadPermutationsView()
            tradeViewsStackView.showHideViews(.show, index: [1])
        default:
            return
        }
        parentVC.updateNumRuns()
    }
    
    /** This is required to fill out rows of the grouped trades table when a run variant does not have enough trade values (e.g. when it is created) */
    func padTradeValues(runVariant: RunVariant) {
        let totalGroups = analysis.numTradeGroups
        var curVals = runVariant.tradeValues
        if totalGroups == curVals.count { return }
        else {
            var nilVal: StringValue? = nil
            if let boolVariant = runVariant as? BoolRunVariant {
                nilVal = boolVariant.curValue
            }
            for _ in curVals.count...totalGroups-1 {
                curVals.append(nilVal)
            }
            runVariant.tradeValues = curVals
        }
    }
     // TODO: make the naming of trade groups more robust within the analysis model
    @objc func renameTradeGroup(_ sender: Any) {
        guard let button = sender as? NSTextField else { return }
        let curRow = groupsTableView.row(for: button)
        var matchingGroup = analysis.tradeGroups[curRow]
        matchingGroup.groupDescription = button.stringValue
    }
    
    private func removeTradeGroup(index: Int) {
        guard index < analysis.numTradeGroups else { return }
        groupsDelegate.runVariants.forEach( { $0.tradeValues.remove(at: index) } )
        analysis.tradeGroups.remove(at: index)
        groupsTableView.removeRows(at: IndexSet(integer: index), withAnimation: .slideDown)
        parentVC.updateNumRuns()
        parentVC.overviewVC.tableView.reloadData()
    }
    @objc func removeTradeGroupPressed(_ sender: Any) {
        guard let senderButton = sender as? NSButton else { return }
        let matchingGroupNum = groupsTableView.row(for: senderButton)
        removeTradeGroup(index: matchingGroupNum)
    }
    @IBAction func addTradeGroup(_ sender: Any) {
        let nilVal: StringValue? = nil
        analysis.tradeRunVariants.forEach({$0.tradeValues.append(nilVal)})
        analysis.tradeGroups.append(RunGroup())
        let lastRow = analysis.tradeRunVariants.first!.tradeValues.count - 1
        groupsTableView.insertRows(at: IndexSet(integer: lastRow), withAnimation: .slideUp)
        
        parentVC.updateNumRuns()
    }
    
    /** This function sets up all of the columns and data formats required for the permutations view */
    func reloadPermutationsView() {
        for thisVariant in analysis.tradeRunVariants {
            thisVariant.tradeValues.removeAll(where: {$0 == nil})
        }
        permutationsDelegates = []
        permutationsTableViews = []
        permutationsStackView.arrangedSubviews.forEach({permutationsStackView.removeArrangedSubview($0)})
        permutationsStackView.subviews = []
        for thisVariant in analysis.tradeRunVariants {
            let thisNam = thisVariant.parameter.name
            let storyboard = NSStoryboard(name: "RunVariants", bundle: nil)
            let newController: PermutationTradeTableViewController = storyboard.instantiateController(identifier: "permutationsTableViewController")
            newController.representedVariant = thisVariant
            newController.tradesVC = self
            permutationsDelegates.append(newController)
            permutationsStackView.addArrangedSubview(newController.view)
            newController.tableView.reloadData()
            newController.column?.title = thisNam
            newController.view.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 900), for: .horizontal)
        }
    }
    
    // MARK: Cell Views
    fileprivate func groupNameCellView(groupName: String?, groupNum: Int?)->RunVariantButtonNameCellView?{
        let newView = groupsTableView.makeView(withIdentifier: .rvAddRemoveNameCellView, owner: self) as? RunVariantButtonNameCellView
        if let textField = newView?.nameTextField{
            if groupName != nil && groupName != "" {
                textField.stringValue = groupName!
            } else if groupNum != nil {
                textField.stringValue = "Group \(groupNum!+1)"
            }
        }
        newView?.nameTextField.isEditable = true
        newView?.nameTextField.action = #selector(renameTradeGroup(_:))
        newView?.nameTextField.target = self
        newView?.addRemoveButton.action = #selector(removeTradeGroupPressed(_:))
        newView?.addRemoveButton.target = self
        return newView
    }
    
    fileprivate func runVariantTextValueCellView(tableView: NSTableView, thisVariant: RunVariant!, option: Int?)->ParamValueTextField? {
        guard thisVariant != nil else {return nil}
        let newView = tableView.makeView(withIdentifier: .rvTextValueField, owner: self) as? ParamValueTextField
        newView?.parameter = thisVariant.parameter
        var curOption: StringValue?
        if option != nil {
            guard thisVariant.tradeValues.count > option! else { return nil }
            curOption = thisVariant.tradeValues[option!]
        } else { curOption = thisVariant.curValue }
        if let curVal = curOption?.valuestr {
            newView?.stringValue = curVal
        } else {
            newView?.stringValue = ""
        }
        return newView
    }
    fileprivate func runVariantPopupCellView(tableView: NSTableView, thisVariant: RunVariant!, row: Int?)->ParamValuePopupView? {
        guard thisVariant != nil else {return nil}
        let newView = tableView.makeView(withIdentifier: .rvPopupValueCellView, owner: self) as? ParamValuePopupView
        newView?.removeAllItems()
        newView?.parameter = thisVariant.parameter
        if row != nil {
            newView?.addItems(withTitles: thisVariant!.options.map( {$0.valuestr }))
            if let curOption = thisVariant.tradeValues[row!] { // Select an existing trade value
                newView?.selectItem(withTitle: curOption.valuestr)
            } else { // Leave the selection blank if a trade value doesn't exist
                newView?.selectItem(at: -1)
            }
        } else { // Use the current value if not being used for trade values
            newView?.addItems(withTitles: thisVariant!.options.map({$0.valuestr}))
            newView?.selectItem(withTitle: thisVariant.curValue.valuestr)
        }
        return newView
    }
    fileprivate func runVariantCheckboxCellView(tableView: NSTableView, thisVariant: RunVariant!, option: Int?)->ParamValueCheckboxView? {
        guard thisVariant != nil else {return nil}
        let newView = tableView.makeView(withIdentifier: .rvCheckboxValueCellView, owner: self) as? ParamValueCheckboxView
        newView?.parameter = thisVariant.parameter
        var enabled: Bool
        let curVal = (thisVariant as? BoolRunVariant)?.paramEnabled ?? false
        if option == nil {
            enabled = curVal
        } else { enabled = thisVariant.tradeValues[option!] as? Bool ?? curVal }
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
        let thisRow = groupsTableView.selectedRow
        guard thisRow >= 0 else { return }
        if thisKey == 36 { // Enter
            if thisRow == analysis.numTradeGroups { addTradeGroup(self) }
            groupsTableView.selectRowIndexes(IndexSet(integer: thisRow+1), byExtendingSelection: false)
        } else if thisKey == 117 || thisKey == 51 { // Delete and Backspace key
            removeTradeGroup(index: thisRow)
        } else {
            super.keyDown(with: event)
        }
    }
}

/** A PermutationTradeTableViewController is created for each run variant if the analysis is using the permutations mode trade */
class PermutationTradeTableViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource {
    var representedVariant: RunVariant!
    var column: NSTableColumn? { return tableView?.tableColumns.first ?? nil}
    var tradesVC: RunVariantTradesViewController!
    @IBOutlet weak var scrollView: SinglePermutationScrollView!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newNib = NSNib(nibNamed: "RunVariantCellViews", bundle: .main)
        tableView.register(newNib, forIdentifier: .rvTextValueField)
        tableView.register(newNib, forIdentifier: .rvCheckboxValueCellView)
        tableView.register(newNib, forIdentifier: .rvPopupValueCellView)
    }
    
    // MARK: TableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Value cell views
        if row >= representedVariant.tradeValues.count {
            let thisButton = tableView.makeView(withIdentifier: .addPermutationValueButton, owner: self)
            return thisButton
        } else {
            var valueCellView: ParamValueView?
            if let thisEnumVariant = representedVariant as? EnumGroupRunVariant {
                valueCellView = tradesVC.runVariantPopupCellView(tableView: tableView, thisVariant: thisEnumVariant, row: row)
            } else if let thisBoolVariant = representedVariant as? BoolRunVariant {
                valueCellView = tradesVC.runVariantCheckboxCellView(tableView: tableView, thisVariant: thisBoolVariant, option: row)
            } else {
                valueCellView = tradesVC.runVariantTextValueCellView(tableView: tableView, thisVariant: representedVariant, option: row)
            }
            valueCellView?.action = #selector(editTradeGroupValue(_:))
            valueCellView?.target = self
            return valueCellView
        }
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return representedVariant.tradeValues.count + 1
    }
    
    // MARK: Callbacks
    @IBAction func addValue(_ sender: Any) {
        representedVariant.tradeValues.append(nil)
        let thisRow = representedVariant.tradeValues.count
        self.tableView.insertRows(at: IndexSet(integer: thisRow-1), withAnimation: .slideUp)
        tradesVC.parentVC.updateNumRuns()
    }
    
    @objc func editTradeGroupValue(_ sender: Any) {
        guard let button = sender as? ParamValueView else { return }
        let newVal = button.stringValue
        let matchingRow = tableView.row(for: button)
        
        switch type(of: representedVariant!) {
        case is SingleNumberRunVariant.Type, is VariableRunVariant.Type:
            representedVariant.tradeValues[matchingRow] = VarValue(stringLiteral: newVal)!
        case is EnumGroupRunVariant.Type:
            let matchingVal = (representedVariant as! EnumGroupRunVariant).enumType.init(stringLiteral: newVal)
            representedVariant.tradeValues[matchingRow] = matchingVal
        case is BoolRunVariant.Type:
            let boolType = Bool(stringLiteral: newVal)!
            representedVariant.tradeValues[matchingRow] = boolType
            (button as? NSButton)?.title = boolType ? "On" : "Off"
        default: return
        }
        tradesVC.parentVC.overviewTableView.reloadData()
    }
    
    override func keyDown(with event: NSEvent) {
        let thisKey = event.keyCode
        let thisRow = tableView.selectedRow

        guard thisRow >= 0 else { return }
        if thisKey == 36 { // Enter
            if thisRow == representedVariant.tradeValues.count { addValue(self) }
            tableView.selectRowIndexes(IndexSet(integer: thisRow), byExtendingSelection: false)
        } else if thisKey == 117 || thisKey == 51 { // Delete and Backspace key
            guard thisRow < representedVariant.tradeValues.count else { return }
            representedVariant.tradeValues.remove(at: thisRow)
            tableView.removeRows(at: IndexSet(integer: thisRow), withAnimation: .slideDown)
            tradesVC.parentVC.updateNumRuns()
            tradesVC.parentVC.overviewVC.tableView.reloadData()
        } else { super.keyDown(with: event) }
    }
}

/** Enclosing scroll view for the permutations table view */
class SinglePermutationScrollView: NSScrollView {
    public override func scrollWheel(with event: NSEvent) {
        if abs(event.scrollingDeltaY) == 0 { // If purely horizontal, scroll the super view of all permutation views
            enclosingScrollView?.scrollWheel(with: event)
        } else {
            super.scrollWheel(with: event)
        }
    }
}

/** A GroupedTradeTableDelegate is simply an object that serves to control the aspects of the Grouped Trades table view */
class GroupedTradeTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var analysis: Analysis!
    var tableView: NSTableView!
    var tradesVC: RunVariantTradesViewController!
    var runVariants: [RunVariant]! { return analysis?.tradeRunVariants ?? []}
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let curIndex = tableView.column(withIdentifier: tableColumn!.identifier)
        if curIndex == 0 { // Group name
            if row == analysis.numTradeGroups {
                let newView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("newTradeGroupButton"), owner: self)
                return newView
            }
            var groupName : String?
            if row < analysis.tradeGroups.count {
                groupName = analysis.tradeGroups[row].groupDescription
            }
            let groupView = tradesVC.groupNameCellView(groupName: groupName, groupNum: row)
            return groupView
        }
        let numTradeRuns = runVariants.map({$0.tradeValues.count}).max()
        if row == numTradeRuns { return nil }
        
        guard let matchingVariant = analysis.tradeRunVariants.first(where: {$0.paramID == tableColumn?.identifier.rawValue}) else { return nil }
        
        // Value cell views
        var valueCellView: ParamValueView?
        if let thisEnumVariant = matchingVariant as? EnumGroupRunVariant {
            valueCellView = tradesVC.runVariantPopupCellView(tableView: tableView, thisVariant: thisEnumVariant, row: row)
        } else if let thisBoolVariant = matchingVariant as? BoolRunVariant {
            valueCellView = tradesVC.runVariantCheckboxCellView(tableView: tableView, thisVariant: thisBoolVariant, option: row)
        } else {
            valueCellView = tradesVC.runVariantTextValueCellView(tableView: tableView, thisVariant: matchingVariant, option: row)
        }
        valueCellView?.action = #selector(editTradeGroupValue(_:))
        valueCellView?.target = self
        return valueCellView
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return analysis.numTradeGroups + 1
    }
    
    @IBAction func editTradeGroupValue(_ sender: Any) {
        guard let button = sender as? ParamValueView else { return }
        let newVal = button.stringValue
        let matchingRow = tableView.row(for: button)
        let matchingColumn = tableView.column(for: button) - 1
        let matchingVariant = runVariants[matchingColumn]
        
        switch type(of: matchingVariant) {
        case is SingleNumberRunVariant.Type, is VariableRunVariant.Type:
            matchingVariant.tradeValues[matchingRow] = VarValue(stringLiteral: newVal) ?? nil
        case is EnumGroupRunVariant.Type:
            let matchingVal = (matchingVariant as! EnumGroupRunVariant).enumType.init(stringLiteral: newVal)
            matchingVariant.tradeValues[matchingRow] = matchingVal
        case is BoolRunVariant.Type:
            let boolType = Bool(stringLiteral: newVal)!
            matchingVariant.tradeValues[matchingRow] = boolType
            (button as? NSButton)?.title = boolType ? "On" : "Off"
        default: return
        }
        tradesVC.parentVC.overviewTableView.reloadData()
    }
}

//
//  ConditionsViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/28/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSUserInterfaceItemIdentifier {
    static let singleConditionTypeSelectorInterval = NSUserInterfaceItemIdentifier.init("singleConditionTypeSelector.interval")
    static let singleConditionTypeSelectorEqual = NSUserInterfaceItemIdentifier.init("singleConditionTypeSelector.equal")
    static let singleConditionTypeSelectorOther = NSUserInterfaceItemIdentifier.init("singleConditionTypeSelector.other")

    static let varNameColumn = NSUserInterfaceItemIdentifier.init("VarNameColumn")
    static let descripColumn = NSUserInterfaceItemIdentifier.init("DescriptionColumn")
    static let varNameCellView = NSUserInterfaceItemIdentifier.init("VarNameCellView")
    static let descripCellView = NSUserInterfaceItemIdentifier.init("DescriptionCellView")
}

class ConditionsViewController: TZViewController {

    @objc var curCondition = Condition()
    @objc var allConditions : [Condition]?
    @objc var selectedConditionIndices = IndexSet()
    var curConditionObjectController = NSObjectController()
    private var canAddSubCondition = false
    //var initVars : [Variable] = []
    
    @IBOutlet weak var tableView: ConditionsTableView!
    @IBOutlet weak var compoundConditionButton: NSButton!
    @IBOutlet weak var addConditionButton: NSButton!
    @IBOutlet weak var unionTypeDropdown: NSPopUpButton!
    @IBOutlet weak var newConditionStackView: NSStackView!
    @IBOutlet weak var methodStackView: NSStackView!
    @IBOutlet weak var conditionNameTextBox: NSTextField!
    @IBOutlet var allConditionsArrayController: NSArrayController!
    @IBOutlet var addConditionTypeMenu: NSMenu!
    @IBOutlet var comparisonLabel: NSButton!
    
    override func viewDidLoad() {
        // Do view setup here.
        allConditions = analysis?.conditions
        allConditionsArrayController.content = allConditions
        conditionNameTextBox.isHidden = true
        
        let trackingArea = NSTrackingArea(rect: self.compoundConditionButton.bounds,
                                          options: [NSTrackingArea.Options.mouseEnteredAndExited,
                                                    NSTrackingArea.Options.activeAlways,
                                                    //NSTrackingArea.Options.inVisibleRect
                                                    ],
                                          owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
        curConditionObjectController.bind(.content, to: self, withKeyPath: "curCondition", options: nil)
        tableView.tableSelector = self.tableViewSelected
        super.viewDidLoad()
    }
    
    init?(coder: NSCoder, analysis anAnalysis: Analysis){
        super.init(coder: coder)
        analysis = anAnalysis
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func addRemoveConditionButtonClicked(_ sender: Any) {
        
        if addConditionButton.title == "Add New" {
            curCondition = Condition()
            analysis.conditions.append(curCondition)
            allConditionsArrayController.addObject(curCondition)
            
            let newCondition = SingleCondition()
            newCondition.varID = "t"
            curCondition.conditions.append(newCondition)
            showConditionView(condition: newCondition)
            tableView.reloadData()
            tableView.selectRowIndexes([(analysis.conditions.firstIndex(of: curCondition) ?? analysis.conditions.count)], byExtendingSelection: false)
            canAddSubCondition = true
            conditionNameTextBox.isHidden = false
            conditionNameTextBox.becomeFirstResponder()
        } else if addConditionButton.title == "Delete" {
            if let conditionIndex = analysis.conditions.firstIndex(of: curCondition)
            { deleteCondition(at: conditionIndex) }
        }
    }
    
    
    @IBAction func addSubCondition(_ sender: Any) {
        if newConditionStackView.views.count == 1 {
            let firstViewController = self.children[0] as! AddConditionViewController
            firstViewController.removeConditionButton.isHidden = false
        }
        var condition: EvaluateCondition!
        if let buttonID = (sender as? NSButton)?.identifier?.rawValue {
            if buttonID == "compoundConditionButton" {
                condition = SingleCondition()
            }
        } else if let senderMenuItem = (sender as? NSMenuItem){
            if senderMenuItem.identifier!.rawValue == "addNewConditionMenuItem" { condition = SingleCondition() }
            else if senderMenuItem.identifier!.rawValue == "addExistingConditionMenuItem" { condition = Condition() }
        }
        curCondition.conditions.append(condition)
        if curCondition.conditions.count > 1 && curCondition.unionType == .single {
            unionTypeDropdown.selectItem(withTitle: "and")
            curCondition.unionType = .and
        }
        _ = showConditionView(condition: condition)
    }
    
    private func formatConditionEditor(){
        if newConditionStackView.arrangedSubviews.count > 1{
            newConditionStackView.layer?.borderWidth = 1
            newConditionStackView.layer?.borderColor = CGColor.init(gray: 0.35, alpha: 1)
            methodStackView.isHidden = false
        } else if newConditionStackView.arrangedSubviews.count == 1 {
            newConditionStackView.layer?.borderWidth = 0
            methodStackView.isHidden = true
        } else if newConditionStackView.arrangedSubviews.count == 0 {
            canAddSubCondition = false
            addConditionButton.title = "Add New"
            conditionNameTextBox.isHidden = true
            methodStackView.isHidden = true
        }
    }

    func eraseView(){
        for thisVC in self.children {
            if let condVC = thisVC as? AddConditionViewController {
                condVC.deleteView()
            }
        }
        conditionNameTextBox.stringValue = ""
        unionTypeDropdown.selectItem(at: 0)
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        // Mouse entered the header area, show disclosure button.
        super.mouseEntered(with: theEvent)
        if canAddSubCondition { compoundConditionButton.isHidden = false }
    }
    override func mouseExited(with theEvent: NSEvent) {
        // Mouse exited the header area, hide disclosure button.
        super.mouseExited(with: theEvent)
        compoundConditionButton.isHidden = true
    }
    
    @IBAction func conditionNameTextFieldChanged(_ sender: Any) {
        curCondition.name = (sender as! NSTextField).stringValue
        tableView.reloadData()
    }
    @IBAction func joinTypePopupButtonClicked(_ sender: Any) {
        if curCondition.conditions.count == 1 {
            curCondition.unionType = .single
        } else {
            curCondition.unionType = BoolType(rawValue: unionTypeDropdown.indexOfSelectedItem + 1)!
        }
        tableView.reloadData()
    }
    
    @IBAction func tableViewSelected(_ sender: NSTableView) {
        let tableRow = tableView.selectedRow
        if tableRow != -1 {
            curCondition = analysis.conditions[tableRow]
            eraseView()
            conditionNameTextBox.stringValue = curCondition.name
            unionTypeDropdown.selectItem(withTitle: curCondition.unionType.stringValue())
            for thisCondition in curCondition.conditions {
                showConditionView(condition: thisCondition)
            }
            tableView.selectRowIndexes(IndexSet(integer: tableRow), byExtendingSelection: false)  // TODO: find out why rows sometimes get deselected without this
            canAddSubCondition = true
            addConditionButton.title = "Delete"
            conditionNameTextBox.isHidden = false
        } else {
            eraseView()
        }
        formatConditionEditor()
    }
    
    func deleteCondition(at index: Int) {
        //let conditionToRemove = analysis.conditions[index]
        analysis.conditions.remove(at: index)
        allConditionsArrayController.remove(atArrangedObjectIndex: index)
        //conditionToRemove.deinit()
        NotificationCenter.default.post(name: .didRemoveCondition, object: nil)
        eraseView()
        tableView.selectRowIndexes([], byExtendingSelection: false)
        formatConditionEditor()
    }
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 51 {//NSDeleteCharacter {
            if tableView.selectedRow != -1 {
                deleteCondition(at: tableView.selectedRow)
            }
        }
    }
    
    func showConditionView(condition: EvaluateCondition){
        var viewController: AddConditionViewController!
        let storyboard = NSStoryboard(name: "Conditions", bundle: nil)
        var storyboardID = ""
        
        if condition is SingleCondition {
            storyboardID = "addNewConditionViewController"
        } else if condition is Condition {
            storyboardID = "addExistingConditionViewController"
        }
        viewController = storyboard.instantiateController(withIdentifier: storyboardID) as? AddConditionViewController
        viewController.analysis = analysis
        viewController.representedCondition = condition
        newConditionStackView.addArrangedSubview(viewController.view)
        self.addChild(viewController)
        viewController.initLoadAll()
        formatConditionEditor()
        
        viewController.populateWithCondition(condition)
    }
    
    /*
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let thisCondition = analysis.conditions[row]
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier.varNameColumn:
            let newView = tableView.makeView(withIdentifier: .varNameCellView, owner: self) as? NSTableCellView
            newView?.textField?.stringValue = thisCondition.name
            return newView
        case NSUserInterfaceItemIdentifier.descripColumn:
            let newView = tableView.makeView(withIdentifier: .descripCellView, owner: self) as? NSTableCellView
            var dstring = ""
            for thisCond in thisCondition.conditions {
                if let singleCond = thisCond as? SingleCondition {
                    if singleCond.equality != nil {
                        dstring += "\(singleCond.varID)=\(singleCond.equality ?? 0)"
                    }
                    else {
                        let lbstr = singleCond.lbound == nil ? "" : "\(singleCond.lbound!) < "
                        let ubstr = singleCond.ubound == nil ? "" : " < \(singleCond.ubound!)"
                        dstring += lbstr + "\(singleCond.varID)" + ubstr
                    }
                }
            }
            newView?.textField?.stringValue = dstring
            return newView
        default:
            let newView : NSView? = nil
            return newView
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return analysis.conditions.count
    }*/
}

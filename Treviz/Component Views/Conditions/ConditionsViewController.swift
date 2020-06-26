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

    static let conditionNameColumn = NSUserInterfaceItemIdentifier.init("ConditionNameColumn")
    static let conditionDescripColumn = NSUserInterfaceItemIdentifier.init("DescriptionColumn")
    static let conditionNameCellView = NSUserInterfaceItemIdentifier.init("ConditionNameCellView")
    static let conditionDescripCellView = NSUserInterfaceItemIdentifier.init("DescriptionCellView")
}

class ConditionsViewController: TZViewController, VariableGetter, NSTableViewDelegate, NSTableViewDataSource {

    var curCondition = Condition()
    var allConditions : [Condition] { return analysis.conditions }
    //@objc var selectedConditionIndices = IndexSet()
    //var curConditionObjectController = NSObjectController()
    private var canAddSubCondition = false
    //var initVars : [Variable] = []
    
    @IBOutlet weak var tableView: ConditionsTableView!
    @IBOutlet weak var compoundConditionButton: NSButton!
    @IBOutlet weak var addConditionButton: NSButton!
    @IBOutlet weak var unionTypeDropdown: NSPopUpButton!
    @IBOutlet weak var newConditionStackView: NSStackView!
    @IBOutlet weak var methodStackView: NSStackView!
    @IBOutlet weak var conditionNameTextBox: NSTextField!
    //@IBOutlet var allConditionsArrayController: NSArrayController!
    @IBOutlet var addConditionTypeMenu: NSMenu!
    @IBOutlet var comparisonLabel: NSButton!
    
    override func viewDidLoad() {
        // Do view setup here.
        // allConditionsArrayController.content = allConditions
        conditionNameTextBox.isHidden = true
        
        let trackingArea = NSTrackingArea(rect: self.compoundConditionButton.bounds,
                                          options: [NSTrackingArea.Options.mouseEnteredAndExited,
                                                    NSTrackingArea.Options.activeAlways,
                                                    //NSTrackingArea.Options.inVisibleRect
                                                    ],
                                          owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
        //curConditionObjectController.bind(.content, to: self, withKeyPath: "curCondition", options: nil)
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
        
        if addConditionButton.title == "New" {
            curCondition = Condition()
            curCondition.name = "Condition \(analysis.conditions.count)"
            
            let newCondition = SingleCondition()
            newCondition.varID = "t"
            curCondition.conditions.append(newCondition)
            showConditionView(condition: newCondition)
            canAddSubCondition = true
            conditionNameTextBox.isHidden = false
            conditionNameTextBox.placeholderString = curCondition.name
            conditionNameTextBox.becomeFirstResponder()
            addConditionButton.title = "Add"
        } else if addConditionButton.title == "Delete" {
            if let conditionIndex = analysis.conditions.firstIndex(where: {$0 === curCondition})
            { deleteCondition(at: conditionIndex) }
        } else if addConditionButton.title == "Add" {
            guard curCondition.isValid() else {
                analysis.logMessage("Condition is invalid. Please fill in all required fields")
                NSSound.beep()
                return
            }
            //allConditionsArrayController.addObject(curCondition)
            analysis.conditions.append(curCondition)
            tableView.reloadData()
            tableView.selectRowIndexes([(analysis.conditions.firstIndex(where: {$0 === curCondition}) ?? analysis.conditions.count)], byExtendingSelection: false)
            NotificationCenter.default.post(name: .didAddCondition, object: nil)
            addConditionButton.title = "Delete"
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
            addConditionButton.title = "New"
            conditionNameTextBox.isHidden = true
            methodStackView.isHidden = true
        }
    }
    
    func variableDidChange(_ sender: VariableSelectorViewController) {
        tableView.reloadData()
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
        guard let textField = sender as? NSTextField else { return }
        let thisName = textField.stringValue
        if thisName == "" {
            curCondition.name = textField.placeholderString ?? ""
        } else {
            curCondition.name = thisName
        }
        NotificationCenter.default.post(name: .didAddCondition, object: nil)
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
            unionTypeDropdown.selectItem(withTitle: String(describing: curCondition.unionType))
            for thisCondition in curCondition.conditions {
                showConditionView(condition: thisCondition)
            }
            if curCondition.conditions.count == 1 {
                for child in self.children {
                    if let vc = child as? AddConditionViewController { vc.removeConditionButton.isHidden = true }
                }
            }
            canAddSubCondition = true
            addConditionButton.title = "Delete"
            conditionNameTextBox.isHidden = false
        } else {
            eraseView()
        }
        formatConditionEditor()
    }
    
    func deleteCondition(at index: Int) {
        let conditionToRemove = analysis.conditions[index]
        let parentConditions = analysis.conditions.filter( {$0.containsCondition(conditionToRemove) })
        guard parentConditions.count == 0 else {
            analysis.logMessage("Cannot delete condition '\(conditionToRemove.name)'. It is being referenced by the following conditions: \n\t\(parentConditions.compactMap({$0.name}).joined(separator: "\n\t"))")
            NSSound.beep()
            return
        }
        analysis.conditions.remove(at: index)
        //allConditionsArrayController.remove(atArrangedObjectIndex: index)
        //conditionToRemove.deinit()
        NotificationCenter.default.post(name: .didRemoveCondition, object: nil)
        eraseView()
        tableView.selectRowIndexes([], byExtendingSelection: false)
        formatConditionEditor()
        tableView.reloadData()
    }
    
    override func keyDown(with event: NSEvent) {
        let kc = event.keyCode
        if kc == 117 || kc == 51 {//NSDeleteCharacter {
            if tableView.selectedRow != -1 {
                deleteCondition(at: tableView.selectedRow)
            }
        }
    }
    
    func showConditionView(condition: EvaluateCondition) {
        var viewController: AddConditionViewController!
        let storyboard = NSStoryboard(name: "Conditions", bundle: nil)
        var storyboardID : String!
        
        if condition is SingleCondition {
            storyboardID = "addNewConditionViewController"
            viewController = storyboard.instantiateController(identifier: storyboardID) { aDecoder in
                AddNewConditionViewController(coder: aDecoder, analysis: self.analysis, condition: condition)
            }
        } else if condition is Condition {
            storyboardID = "addExistingConditionViewController"
            viewController = storyboard.instantiateController(identifier: storyboardID) { aDecoder in
                AddExistingConditionViewController(coder: aDecoder, analysis: self.analysis, condition: condition)
            }
        }
        newConditionStackView.addArrangedSubview(viewController.view)
        self.addChild(viewController)
        viewController.subConditionIndex = newConditionStackView.arrangedSubviews.count - 1
        formatConditionEditor()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let thisCondition = allConditions[row]
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier.conditionNameColumn:
            let newView = tableView.makeView(withIdentifier: .conditionNameCellView, owner: self) as? NSTableCellView
            newView?.textField?.stringValue = thisCondition.name
            return newView
        case NSUserInterfaceItemIdentifier.conditionDescripColumn:
            let newView = tableView.makeView(withIdentifier: .conditionDescripCellView, owner: self) as? NSTableCellView
            newView?.textField?.stringValue = thisCondition.summary
            return newView
        default:
            let newView : NSView? = nil
            return newView
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return analysis.conditions.count
    }
}

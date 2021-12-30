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
    static let singleConditionTypeSelectorCompound = NSUserInterfaceItemIdentifier.init("singleConditionTypeSelector.compound")
    
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
    @IBOutlet weak var removeConditionButton: NSButton!
    @IBOutlet weak var tableView: ConditionsTableView!
    @IBOutlet weak var compoundConditionButton: NSButton!
    @IBOutlet weak var addConditionButton: NSButton!
    @IBOutlet weak var unionTypeDropdown: NSPopUpButton!
    @IBOutlet weak var newConditionStackView: NSStackView!
    @IBOutlet weak var methodStackView: NSStackView!
    @IBOutlet weak var conditionNameTextBox: NSTextField!
    //@IBOutlet var allConditionsArrayController: NSArrayController!
    @IBOutlet var addConditionTypeMenu: NSMenu!
    
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
        compoundConditionButton.isHidden = true
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
    
    @IBAction func addConditionButtonClicked(_ sender: Any) {
        curCondition = Condition()
        curCondition.name = "Condition \(analysis.conditions.count)"
        
        let newCondition = SingleCondition()
        curCondition.conditions.append(newCondition)
        eraseView()
        showConditionView(condition: newCondition)
        canAddSubCondition = true
        conditionNameTextBox.isHidden = false
        compoundConditionButton.isHidden = false
        conditionNameTextBox.placeholderString = curCondition.name
        conditionNameTextBox.becomeFirstResponder()
        
        analysis.conditions.append(curCondition)
        tableView.reloadData()
    }
    @IBAction func removeConditionButtonClicked(_ sender: Any) {
        if let conditionIndex = analysis.conditions.firstIndex(where: {$0 === curCondition})
        { deleteCondition(at: conditionIndex) }
    }
    
    
    @IBAction func addSubCondition(_ sender: Any) {
        if newConditionStackView.views.count == 2 { // One condition and one Add Condition button
            let firstViewController = self.children[0] as! AddConditionViewController
            firstViewController.removeConditionButton.isHidden = false
        }
        var condition: EvaluateCondition!
        if let buttonID = (sender as? NSButton)?.identifier?.rawValue {
            condition = SingleCondition()
        } else if let senderMenuItem = (sender as? NSMenuItem){
            if senderMenuItem.identifier!.rawValue == "addNewConditionMenuItem" { condition = SingleCondition() }
            else if senderMenuItem.identifier!.rawValue == "addExistingConditionMenuItem" { condition = Condition() }
        }
        curCondition.conditions.append(condition)
        if curCondition.conditions.count > 1 && curCondition.unionType == .single {
            unionTypeDropdown.selectItem(withTitle: "and")
            curCondition.unionType = .and
        }
        showConditionView(condition: condition)
    }
    
    private func formatConditionEditor(){
        if newConditionStackView.arrangedSubviews.count > 2 {
            newConditionStackView.layer?.borderWidth = 1
            newConditionStackView.layer?.borderColor = CGColor.init(gray: 0.35, alpha: 1)
            methodStackView.isHidden = false
            conditionNameTextBox.isHidden = false
        } else if newConditionStackView.arrangedSubviews.count == 2 {
            newConditionStackView.layer?.borderWidth = 0
            methodStackView.isHidden = true
            conditionNameTextBox.isHidden = false
        } else if newConditionStackView.arrangedSubviews.count == 1 {
            newConditionStackView.layer?.borderWidth = 0
            compoundConditionButton.isHidden = true
            canAddSubCondition = false
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
    
    /*
    override func mouseEntered(with theEvent: NSEvent) {
        // Mouse entered the header area, show disclosure button.
        super.mouseEntered(with: theEvent)
        if canAddSubCondition { compoundConditionButton.isHidden = false }
    }
    override func mouseExited(with theEvent: NSEvent) {
        // Mouse exited the header area, hide disclosure button.
        super.mouseExited(with: theEvent)
        compoundConditionButton.isHidden = true
    }*/
    
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
        guard let selection: String = (sender as? NSPopUpButton)?.selectedItem?.title else { return }
        if curCondition.conditions.count == 1 {
            curCondition.unionType = .single
        } else {
            curCondition.unionType = BoolType(rawValue: selection) ?? .single
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
            compoundConditionButton.isHidden = false
            canAddSubCondition = true
            
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
        compoundConditionButton.isHidden = true
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
        } else if kc == 53 {//Escape
            self.dismiss(parent)
        }
    }
    
    func showConditionView(condition: EvaluateCondition) {
        var viewController: AddConditionViewController!
        let storyboard = NSStoryboard(name: "Conditions", bundle: nil)
        var storyboardID : String!
        
        if true {//condition is SingleCondition {
            storyboardID = "addNewConditionViewController"
            viewController = storyboard.instantiateController(identifier: storyboardID) { aDecoder in
                let subConditionIndex = self.curCondition.conditions.firstIndex(where: {$0 === condition})
                let ac = AddConditionViewController(coder: aDecoder, analysis: self.analysis, parentCondition: self.curCondition, newCondition: condition, location: self.newConditionStackView.arrangedSubviews.count - 2)
                ac?.subConditionIndex = subConditionIndex!
                return ac
            }
        }/* else if condition is Condition {
            storyboardID = "addExistingConditionViewController"
            viewController = storyboard.instantiateController(identifier: storyboardID) { aDecoder in
                AddExistingConditionViewController(coder: aDecoder, analysis: self.analysis, condition: condition)
            }
        }*/
        newConditionStackView.insertArrangedSubview(viewController.view, at: newConditionStackView.arrangedSubviews.count - 1)
        //addArrangedSubview(viewController.view)
        self.addChild(viewController)
        //viewController.subConditionIndex = newConditionStackView.arrangedSubviews.count - 1
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

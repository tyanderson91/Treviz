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

class ConditionsViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource {

    var curCondition = Condition()
    var initVars : [Variable] = []
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var compoundConditionButton: NSButton!
    @IBOutlet weak var unionTypeDropdown: NSPopUpButton!
    @IBOutlet weak var newConditionStackView: NSStackView!
    @IBOutlet weak var methodStackView: NSStackView!
    @IBOutlet weak var conditionNameTextBox: NSTextField!
    
    
    @IBAction func addConditionButtonClicked(_ sender: Any) {
        if conditionNameTextBox.stringValue == "" {
            conditionNameTextBox.becomeFirstResponder() //Set focus to the name field if it is empty
            return
        } else if conditionNameTextBox.stringValue == "terminal" {
            conditionNameTextBox.stringValue = "" // TODO: throw error message for reserved keyword "terminal"
            conditionNameTextBox.becomeFirstResponder()
            return
        }
        curCondition = Condition()
        curCondition.name = conditionNameTextBox.stringValue

        for curConditionVC in (self.children as? Array<addConditionViewController> ?? []) {
            let varindex = curConditionVC.variableSelector.indexOfSelectedItem
            if varindex == -1 {curConditionVC.variableSelector.becomeFirstResponder(); return}
            
            let newSingleCondition = SingleCondition(initVars[varindex].id)
            
            switch curConditionVC.selectedType {
            case .interval:
                newSingleCondition.lbound = VarValue(curConditionVC.lowerBoundTextField.stringValue) ?? -VarValue.infinity
                newSingleCondition.ubound = VarValue(curConditionVC.upperBoundTextField.stringValue) ?? VarValue.infinity
            case .equality:
                newSingleCondition.equality = VarValue(curConditionVC.upperBoundTextField.stringValue)
            case .other:
                print("Other")
            }
            curCondition.conditions.append(newSingleCondition)
        }
        if curCondition.conditions.count == 1 {
            curCondition.unionType = .single
            
        } else {
            curCondition.unionType = BoolType(rawValue: unionTypeDropdown.indexOfSelectedItem - 1)!
        }// Minus 1 because index 0 is reserved for 'single' union type
        analysis.conditions.append(curCondition)
        NotificationCenter.default.post(name: .didAddCondition, object: nil)
        tableView.reloadData()
    }
    
    
    @IBAction func compoundConditionButtonClicked(_ sender: Any) {
        if newConditionStackView.views.count == 1 {
            let firstViewController = self.children[0] as! addConditionViewController
            firstViewController.removeConditionButton.isHidden = false
        }
        _ = addConditionView()
    }
    
    @IBOutlet var comparisonLabel: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //print(analysis!.name)
        initVars = (analysis?.varList)!
        
        let newVC = addConditionView()
        newVC.removeConditionButton.isHidden = true

        //addConditionButtonStackView.showHideViews(.hide, index: [0])
        
        let trackingArea = NSTrackingArea(rect: self.compoundConditionButton.bounds,
                                          options: [NSTrackingArea.Options.mouseEnteredAndExited,
                                                    NSTrackingArea.Options.activeAlways,
                                                    //NSTrackingArea.Options.inVisibleRect
                                                    ],
                                          owner: self,
                                          userInfo: nil)
        view.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with theEvent: NSEvent) {
        // Mouse entered the header area, show disclosure button.
        super.mouseEntered(with: theEvent)
        compoundConditionButton.isHidden = false
    }
    override func mouseExited(with theEvent: NSEvent) {
        // Mouse exited the header area, hide disclosure button.
        super.mouseExited(with: theEvent)
        compoundConditionButton.isHidden = true
    }
    
    func addConditionView()->addConditionViewController {
        let storyboard = NSStoryboard(name: "Conditions", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "addConditionViewController") as! addConditionViewController
        newConditionStackView.addArrangedSubview(viewController.view)
        self.addChild(viewController)
        if newConditionStackView.arrangedSubviews.count > 1{
            newConditionStackView.layer?.borderWidth = 1
            newConditionStackView.layer?.borderColor = CGColor.init(gray: 0.35, alpha: 1)
            methodStackView.isHidden = false
        } else {
            newConditionStackView.layer?.borderWidth = 0
            methodStackView.isHidden = true
        }
        
        viewController.variableList = initVars
        return viewController
    }
    
    
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
    }
    
    /*
    private func tableView(_ tableView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let thisCondition = item as? InputSetting{
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn: return thisSetting.name
            case NSUserInterfaceItemIdentifier.paramValueColumn: return thisSetting.value//TODO: make logic for inputting various parameter values
            case NSUserInterfaceItemIdentifier.unitsColumn: return thisSetting.units
            default: return nil
            }
        }
        return nil
    }*/
    
}


// New View Controller
enum singleConditionType : String {
    case interval = "interval"
    case equality = "equality"
    case other = "other"
}

class addConditionViewController: NSViewController, NSComboBoxDataSource {
    @IBOutlet weak var variableSelector: NSComboBox!
    @IBAction func variableSelectorClicked(_ sender: Any) {
    }
    @IBOutlet weak var intervalTypeRadioButton: NSButton!
    @IBOutlet weak var equalityTypeRadioButton: NSButton!
    @IBOutlet weak var comparisonLabelCell: NSTextFieldCell!
    @IBOutlet weak var conditionInputStackView: CollapsibleStackView!
    @IBOutlet weak var lowerBoundTextField: NSTextField!
    @IBOutlet weak var upperBoundTextField: NSControl!//NSTextField!
    @IBOutlet weak var removeConditionButton: NSButton!
    var selectedType : singleConditionType = .interval
    var variableList : [Variable] = []
    
    override func viewDidLoad() {
        variableSelector.usesDataSource = true
        variableSelector.dataSource = self
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        // anArray is an Array variable containing the objects
        return variableList.count
    }
    
    // Returns the object that corresponds to the item at the specified index in the combo box
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return variableList[index].name
    }
    
    @IBAction func removeConditonButtonClicked(_ sender: Any) {
        let parent = self.parent as! ConditionsViewController
        if parent.newConditionStackView.arrangedSubviews.count == 1 {return}
        parent.newConditionStackView.removeArrangedSubview(self.view)
        self.view.removeFromSuperview()
        self.removeFromParent()
        if parent.newConditionStackView.arrangedSubviews.count == 1 {
            let lastVC = parent.children[0] as! addConditionViewController
            lastVC.removeConditionButton.isHidden = true
            parent.newConditionStackView.layer?.borderWidth = 0
            parent.methodStackView.isHidden = true
        }
    }
    
    
    @IBAction func typeWasSelected(_ sender: NSButton) {
        switch(sender.identifier){
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorInterval:
            comparisonLabelCell.stringValue = "<"
            conditionInputStackView.showHideViews(.show, index: [0,1])
            selectedType = .interval
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorEqual:
            comparisonLabelCell.stringValue = "="
            conditionInputStackView.showHideViews(.hide, index: [0,1])
            selectedType = .equality
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorOther:
            comparisonLabelCell.stringValue = "is"
            conditionInputStackView.showHideViews(.hide, index: [0,1])
            selectedType = .other
        default:
            return
        }
    }
    
}

//
//  AddConditionViewControllers.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/12/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//
import Cocoa
import Foundation

enum ConditionType : String {
    case interval = "interval"
    case equality = "equality"
    case other = "other"
    case compound = "compound"
}

class AddConditionViewController: TZViewController, VariableGetter {
    @IBOutlet weak var removeConditionButton: NSButton!
    @IBOutlet weak var compoundTypePopup: NSPopUpButton!
    @IBOutlet weak var compoundTypeRadioButton: NSButton!
    @IBOutlet weak var intervalTypeRadioButton: NSButton!
    @IBOutlet weak var equalityTypeRadioButton: NSButton!
    @IBOutlet weak var specialTypeRadioButton: NSButton!
    @IBOutlet weak var comparisonLabelCell: NSTextFieldCell!
    @IBOutlet weak var conditionInputStackView: CollapsibleStackView!
    @IBOutlet weak var lowerBoundTextField: NSTextField!
    @IBOutlet weak var upperBoundTextField: NSControl!
    @IBOutlet weak var specialTypePopup: NSPopUpButton!
    
    var selectedType : ConditionType = .interval
    var representedSingleCondition = SingleCondition()
    var representedCondition = Condition()
    var varObservation : NSKeyValueObservation!
    var conditionViewController : ConditionsViewController? {
        return self.parent as? ConditionsViewController ?? nil
    }
    var variableSelectorViewController : VariableSelectorViewController?
    var existingConditions: [Condition]!
    var menuConditions: [Condition] { return existingConditions.filter { !$0.containsCondition(representedCondition) }
    }
    var parentCondition: Condition!

    func populateWithCondition(_ thisCondition: EvaluateCondition){}
    var subConditionIndex: Int = -1
    
    func initLoadAll(){}
    
    @IBAction func removeConditionButtonClicked(_ sender: Any)
    {
        let parent = self.parent as! ConditionsViewController
        if parent.newConditionStackView.arrangedSubviews.count == 1 {return}
        else {
            deleteView()
            parent.curCondition.conditions.removeAll { $0.summary == representedCondition.summary }
        }
        if parent.newConditionStackView.arrangedSubviews.count == 1 {
            let lastVC = parent.children[0] as! AddConditionViewController
            lastVC.removeConditionButton.isHidden = true
            parent.newConditionStackView.layer?.borderWidth = 0
            parent.methodStackView.isHidden = true
        }
        parent.tableView.reloadData()
    }
    
    func deleteView(){
        let parent = self.parent as! ConditionsViewController
        parent.newConditionStackView.removeArrangedSubview(self.view)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis, parentCondition: Condition, newCondition: EvaluateCondition, location: Int){
        self.init(coder: coder)
        if let cc = newCondition as? Condition {
            representedCondition = cc
        } else if let sc = newCondition as? SingleCondition {
            representedSingleCondition = sc
        }
        analysis = curAnalysis
        self.parentCondition = parentCondition
        subConditionIndex = location
    }
    
    override func viewDidLoad() {
        if representedCondition.name != "" { // Represented condition set
            configureCompoundPopup()
            compoundTypeRadioButton.state = .on
            formatAll(as: .compound)
            compoundTypePopup.selectItem(withTitle: representedCondition.name)
        } else if representedSingleCondition.isEmpty { // Brand new
            formatAll(as: .interval)
        } else { // Use some form of single condition
            if representedSingleCondition.lbound != nil {
                lowerBoundTextField.stringValue = "\(representedSingleCondition.lbound!)"
                intervalTypeRadioButton.state = .on
            }
            if representedSingleCondition.ubound != nil {
                upperBoundTextField.stringValue = "\(representedSingleCondition.ubound!)"
                intervalTypeRadioButton.state = .on
            }
            else if representedSingleCondition.equality != nil {
                upperBoundTextField.stringValue = "\(representedSingleCondition.equality!)"
                equalityTypeRadioButton.state = .on
                formatAll(as: .equality)
            } else {equalityTypeRadioButton.state = .off}
            if representedSingleCondition.ubound != nil || representedSingleCondition.lbound != nil {
                formatAll(as: .interval)
            }
            if representedSingleCondition.specialCondition != nil {
                specialTypeRadioButton.state = .on
                specialTypePopup.selectItem(at: representedSingleCondition.specialCondition?.rawValue ?? 0)
                formatAll(as: .other)
            }
        }
        super.viewDidLoad()
    }
    
    func configureCompoundPopup() { // Add menu options and select the current, if applicable
        existingConditions = analysis.conditions
        compoundTypePopup.removeAllItems()
        compoundTypePopup.addItems(withTitles: menuConditions.compactMap { $0.name })
        guard menuConditions.contains(where: {$0 === representedCondition}) else { return }
        if representedCondition.name != "" {
            compoundTypePopup.selectItem(withTitle: representedCondition.name)
        }
    }

    func variableDidChange(_ sender: VariableSelectorViewController) {
        representedSingleCondition.varID = sender.selectedVariable?.id
        if let parent = parent as? ConditionsViewController {
            parent.variableDidChange(sender)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "variableSelectorSegue" {
            guard let viewController = segue.destinationController as? VariableSelectorViewController else {return}
            variableSelectorViewController = viewController
            variableSelectorViewController!.analysis = analysis
            variableSelectorViewController?.selectedVariable = analysis.varList.first { $0.id == representedSingleCondition.varID }
        }
    }
    
    func changeConditionType(oldType: ConditionType, newType: ConditionType) {
        if newType != .compound { // Required variable selector initialization for single types
            self.variableSelectorViewController?.variableGetter = self
        }
        if oldType != .compound && newType != .compound { return }
        if oldType != .compound && newType == .compound {
            parentCondition.conditions[subConditionIndex] = representedCondition
            representedSingleCondition = SingleCondition()
            configureCompoundPopup()
        }
        else if oldType == .compound && newType != .compound {
            parentCondition.conditions[subConditionIndex] = representedSingleCondition
            representedCondition = Condition()
        }
    }
    
    @IBAction func compoundTypeWasSelected(_ sender: Any) {
        
        if let matchingCond = menuConditions.first(where: {
            $0.name == compoundTypePopup.selectedItem?.title
        }) {
            representedCondition = matchingCond
            parentCondition.conditions[subConditionIndex] = representedCondition
        }
        conditionViewController?.tableView.reloadData()
    }
    
    @IBAction func customTypeWasSelected(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else {return}
        if selectedType == .other { representedSingleCondition.specialCondition = SpecialConditionType(rawValue: popup.indexOfSelectedItem) }
        conditionViewController?.tableView.reloadData()
    }
    
    func intervalWasSet() {
        let uVal = VarValue(upperBoundTextField.stringValue)
        let lVal = VarValue(lowerBoundTextField.stringValue)
        if selectedType == .interval {
            representedSingleCondition.ubound = uVal
            representedSingleCondition.lbound = lVal
        }
        conditionViewController?.tableView.reloadData()
    }
    @IBAction func upperBoundWasSet(_ sender: Any) {
        let varVal = VarValue(upperBoundTextField.stringValue)
        if selectedType == .interval {
            representedSingleCondition.ubound = varVal
        } else if selectedType == .equality {
            representedSingleCondition.equality = varVal
        }
        conditionViewController?.tableView.reloadData()
        
    }
    @IBAction func lowerBoundWasSet(_ sender: Any) {
        if selectedType == .interval { representedSingleCondition.lbound = VarValue(lowerBoundTextField.stringValue) }
        conditionViewController?.tableView.reloadData()
    }
    
    private func formatAll(as type: ConditionType){
        //changeConditionType(oldType: selectedType, newType: type)
        switch type {
        case .equality:
            comparisonLabelCell.stringValue = "="
            conditionInputStackView.showHideViews(.show, index: [2,3,4])
            conditionInputStackView.showHideViews(.hide, index: [0,1,5,6])
            selectedType = .equality
            representedSingleCondition.ubound = nil
            representedSingleCondition.lbound = nil
            representedSingleCondition.specialCondition = nil
            upperBoundWasSet(self)
        case .interval:
            comparisonLabelCell.stringValue = "<"
            conditionInputStackView.showHideViews(.show, index: [0,1,2,3,4])
            conditionInputStackView.showHideViews(.hide, index: [5,6])
            selectedType = .interval
            representedSingleCondition.equality = nil
            representedSingleCondition.specialCondition = nil
            intervalWasSet()
        case .other:
            comparisonLabelCell.stringValue = "is"
            conditionInputStackView.showHideViews(.show, index: [2,3,5])
            conditionInputStackView.showHideViews(.hide, index: [0,1,4,6])
            selectedType = .other
            representedSingleCondition.lbound = nil
            representedSingleCondition.ubound = nil
            representedSingleCondition.equality = nil
            customTypeWasSelected(self)
        case .compound:
            selectedType = .compound
            conditionInputStackView.showHideViews(.show, index: [6])
            conditionInputStackView.showHideViews(.hide, index: [0,1,2,3,4,5])
            compoundTypeWasSelected(self)
        }
    }
    
    @IBAction func typeWasSelected(_ sender: NSButton) {
        var newType: ConditionType
        switch(sender.identifier){
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorInterval:
            newType = .interval
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorEqual:
            newType = .equality
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorOther:
            newType = .other
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorCompound:
            newType = .compound
        default:
            return
        }
        changeConditionType(oldType: selectedType, newType: newType)
        formatAll(as: newType)
    }
}

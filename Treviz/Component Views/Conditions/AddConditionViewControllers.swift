//
//  AddConditionViewControllers.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/12/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//
import Cocoa
import Foundation

enum singleConditionType : String {
    case interval = "interval"
    case equality = "equality"
    case other = "other"
}

class AddConditionViewController: TZViewController {
    @IBOutlet weak var removeConditionButton: NSButton!
    @objc var representedCondition: EvaluateCondition!
    func populateWithCondition(_ thisCondition: EvaluateCondition){}
    var subConditionIndex: Int = -1
    func initLoadAll(){}
    
    @IBAction func removeConditionButtonClicked(_ sender: Any)
    {
        let parent = self.parent as! ConditionsViewController
        if parent.newConditionStackView.arrangedSubviews.count == 1 {return}
        else { deleteView()
            parent.curCondition.conditions.removeAll { $0 === self.representedCondition }
        }
        if parent.newConditionStackView.arrangedSubviews.count == 1 {
            let lastVC = parent.children[0] as! AddConditionViewController
            lastVC.removeConditionButton.isHidden = true
            parent.newConditionStackView.layer?.borderWidth = 0
            parent.methodStackView.isHidden = true
        }
    }
    
    func deleteView(){
        let parent = self.parent as! ConditionsViewController
        parent.newConditionStackView.removeArrangedSubview(self.view)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

class AddExistingConditionViewController: AddConditionViewController {
    @IBOutlet weak var conditionSelectorPopup: NSPopUpButton!
    @IBOutlet var existingConditionsArrayController: NSArrayController!
    @objc var existingConditions: [Condition]!
    @objc var menuConditions: [Condition] { return existingConditions.filter { !$0.containsCondition(representedCondition) }
    }
    override func viewDidLoad() {
        //initLoadAll()
        
        super.viewDidLoad()
    }
    override func initLoadAll(){
        existingConditions = analysis.conditions
        representedCondition = existingConditions[0]
        existingConditionsArrayController.content = menuConditions
        let parent = self.parent as! ConditionsViewController
        subConditionIndex = parent.newConditionStackView.arrangedSubviews.count - 1
    }
    @IBAction func didChangeSelection(_ sender: Any) {
        representedCondition = conditionSelectorPopup.selectedItem?.representedObject as! Condition
        let parent = self.parent as! ConditionsViewController
        let curConditionArray = parent.curCondition.conditions
        if (subConditionIndex < curConditionArray.count && subConditionIndex >= 0) {
            parent.curCondition.conditions[subConditionIndex] = representedCondition
        }
        parent.tableView.reloadData()
    }
    override func populateWithCondition(_ thisCondition: EvaluateCondition){
        guard let condition = thisCondition as? Condition else { return }
        initLoadAll()
        representedCondition = condition
        existingConditionsArrayController.content = menuConditions
        conditionSelectorPopup.selectItem(withTitle: condition.name)
    }
}

class AddNewConditionViewController: AddConditionViewController {

    @IBOutlet weak var intervalTypeRadioButton: NSButton!
    @IBOutlet weak var equalityTypeRadioButton: NSButton!
    @IBOutlet weak var comparisonLabelCell: NSTextFieldCell!
    @IBOutlet weak var conditionInputStackView: CollapsibleStackView!
    @IBOutlet weak var lowerBoundTextField: NSTextField!
    @IBOutlet weak var upperBoundTextField: NSControl!//NSTextField!
    var selectedType : singleConditionType = .interval
    var variableList : [Variable] = []
    @objc var representedSingleCondition : SingleCondition { return representedCondition as! SingleCondition }
    var varObservation : NSKeyValueObservation!
    var conditionViewController : ConditionsViewController?
    { return self.parent as? ConditionsViewController ?? nil }
    
    @objc var variableSelectorViewController : VariableSelectorViewController?
    @objc var selectedVariable: Variable!
    @IBOutlet var singleConditionObjectController: NSObjectController!
    
    override func viewDidLoad() {
        representedCondition = SingleCondition()
        super.viewDidLoad()
    }
    
    override func populateWithCondition(_ thisCondition: EvaluateCondition){
        guard thisCondition is SingleCondition else { return }
        representedCondition = thisCondition
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
        } else {equalityTypeRadioButton.state = .off}
        if representedSingleCondition.specialCondition != nil {
            
        }
        variableSelectorViewController?.selectVariable(with: representedSingleCondition.varID)
        //else if singleCondition.specialCondition != nil { }
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "variableSelectorSegue" {
            guard let viewController = segue.destinationController as? VariableSelectorViewController else {return}
            variableSelectorViewController = viewController
        }
    }
    
    override func initLoadAll(){
        guard variableSelectorViewController != nil else {return}
        variableSelectorViewController!.analysis = analysis
        variableSelectorViewController!.initLoadVars()
        singleConditionObjectController.bind(.content, to: self, withKeyPath: "representedSingleCondition", options: nil)
        subConditionIndex = conditionViewController!.newConditionStackView.arrangedSubviews.count - 1
        self.varObservation = variableSelectorViewController!.observe(\.selectedVariable?, changeHandler: {
            (varVC, change) in
            if let varID = varVC.selectedVariable?.id { self.representedSingleCondition.varID = varID }
            self.conditionViewController!.tableView.reloadData()
        })
        
    }
    
    
    @IBAction func customTypeWasSelected(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else {return}
        let specialOptions: Array<SpecialConditionType> = [.globalMax, .globalMin, .localMax, .localMin]
        if selectedType == .other { representedSingleCondition.specialCondition = specialOptions[popup.indexOfSelectedItem] }
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
    @IBAction func typeWasSelected(_ sender: NSButton) {
        switch(sender.identifier){
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorInterval:
            comparisonLabelCell.stringValue = "<"
            conditionInputStackView.showHideViews(.show, index: [0,1,4])
            conditionInputStackView.showHideViews(.hide, index: [5])
            selectedType = .interval
            representedSingleCondition.equality = nil
            representedSingleCondition.specialCondition = nil
            intervalWasSet()
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorEqual:
            comparisonLabelCell.stringValue = "="
            conditionInputStackView.showHideViews(.show, index: [4])
            conditionInputStackView.showHideViews(.hide, index: [0,1,5])
            selectedType = .equality
            representedSingleCondition.ubound = nil
            representedSingleCondition.lbound = nil
            representedSingleCondition.specialCondition = nil
            upperBoundWasSet(self)
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorOther:
            comparisonLabelCell.stringValue = "is"
            conditionInputStackView.showHideViews(.hide, index: [0,1,4])
            conditionInputStackView.showHideViews(.show, index: [5])
            selectedType = .other
            representedSingleCondition.lbound = nil
            representedSingleCondition.ubound = nil
            representedSingleCondition.equality = nil
            customTypeWasSelected(self)
        default:
            return
        }
    }
}

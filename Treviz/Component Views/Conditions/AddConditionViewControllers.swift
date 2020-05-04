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
    var representedCondition: EvaluateCondition!
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
    var existingConditions: [Condition]!
    @objc var menuConditions: [Condition] { return existingConditions.filter { !$0.containsCondition(representedCondition) }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis, condition: EvaluateCondition){
        self.init(coder: coder)
        representedCondition = condition
        analysis = curAnalysis
    }
    
    override func viewDidLoad() {
        if let condition = representedCondition as? Condition { // Should always be the case
            existingConditions = analysis.conditions
            //existingConditionsArrayController.content = menuConditions
            
            conditionSelectorPopup.addItems(withTitles: menuConditions.compactMap { $0.name })
            guard menuConditions.contains(representedCondition as! Condition) else { return }
            
            conditionSelectorPopup.selectItem(withTitle: condition.name)
            
            //let menuItem = conditionSelectorPopup.itemArray.first(where: { $0.representedObject === condition })
        }
        super.viewDidLoad()
    }
    
    @IBAction func didChangeSelection(_ sender: Any) {
        let selectedTitle = conditionSelectorPopup.selectedItem?.title
        guard let selectedCondition = existingConditions.first(where: { $0.name == selectedTitle }) else { return }
        representedCondition = selectedCondition
        if let parent = self.parent as? ConditionsViewController {
            // TODO: Maybe only need the reload data?
            let curConditionArray = parent.curCondition.conditions
            if (subConditionIndex < curConditionArray.count && subConditionIndex >= 0) {
                parent.curCondition.conditions[subConditionIndex] = representedCondition
            }
            parent.tableView.reloadData()
        }
    }

}

class AddNewConditionViewController: AddConditionViewController, VariableGetter {
    
    @IBOutlet weak var intervalTypeRadioButton: NSButton!
    @IBOutlet weak var equalityTypeRadioButton: NSButton!
    @IBOutlet weak var specialTypeRadioButton: NSButton!
    @IBOutlet weak var comparisonLabelCell: NSTextFieldCell!
    @IBOutlet weak var conditionInputStackView: CollapsibleStackView!
    @IBOutlet weak var lowerBoundTextField: NSTextField!
    @IBOutlet weak var upperBoundTextField: NSControl!//NSTextField!
    @IBOutlet weak var specialTypePopup: NSPopUpButton!
    var selectedType : singleConditionType = .interval
    @objc var representedSingleCondition : SingleCondition { return representedCondition as! SingleCondition }
    var varObservation : NSKeyValueObservation!
    var conditionViewController : ConditionsViewController?
    { return self.parent as? ConditionsViewController ?? nil }    
    var variableSelectorViewController : VariableSelectorViewController?

    @IBOutlet var singleConditionObjectController: NSObjectController!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis, condition: EvaluateCondition){
        self.init(coder: coder)
        representedCondition = condition
        analysis = curAnalysis
    }
    
    override func viewDidLoad() {
        //representedCondition = SingleCondition()
        singleConditionObjectController.bind(.content, to: self, withKeyPath: "representedSingleCondition", options: nil)
        
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
        
        super.viewDidLoad()
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
            /* TODO: handle observing some other way
            self.varObservation = variableSelectorViewController!.observe(\.selectedVariable?, changeHandler: {
                (varVC, change) in
                if let varID = varVC.selectedVariable?.id { self.representedSingleCondition.varID = varID }
                self.conditionViewController!.tableView.reloadData()
            })*/
        }
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
    
    private func formatAll(as type: singleConditionType){
        switch type {
        case .equality:
            comparisonLabelCell.stringValue = "="
            conditionInputStackView.showHideViews(.show, index: [4])
            conditionInputStackView.showHideViews(.hide, index: [0,1,5])
            selectedType = .equality
            representedSingleCondition.ubound = nil
            representedSingleCondition.lbound = nil
            representedSingleCondition.specialCondition = nil
            upperBoundWasSet(self)
        case .interval:
            comparisonLabelCell.stringValue = "<"
            conditionInputStackView.showHideViews(.show, index: [0,1,4])
            conditionInputStackView.showHideViews(.hide, index: [5])
            selectedType = .interval
            representedSingleCondition.equality = nil
            representedSingleCondition.specialCondition = nil
            intervalWasSet()
        case .other:
            comparisonLabelCell.stringValue = "is"
            conditionInputStackView.showHideViews(.hide, index: [0,1,4])
            conditionInputStackView.showHideViews(.show, index: [5])
            selectedType = .other
            representedSingleCondition.lbound = nil
            representedSingleCondition.ubound = nil
            representedSingleCondition.equality = nil
            customTypeWasSelected(self)
        }
    }
    
    @IBAction func typeWasSelected(_ sender: NSButton) {
        switch(sender.identifier){
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorInterval:
            formatAll(as: .interval)
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorEqual:
            formatAll(as: .equality)
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorOther:
            formatAll(as: .other)
        default:
            return
        }
    }
}

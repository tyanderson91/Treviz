//
//  AddConditionViewControllers.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/12/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//
import Cocoa

enum singleConditionType : String {
    case interval = "interval"
    case equality = "equality"
    case other = "other"
}

class AddConditionViewController: TZViewController {
    @IBOutlet weak var removeConditionButton: NSButton!
    @objc var representedSingleCondition: SingleCondition! // TODO: deal with this in a more consistent way
    @objc var representedExistingCondition: Condition! // TODO: deal with this in a more consistent way
    var representedCondition: EvaluateCondition? {
        if representedSingleCondition != nil { return representedSingleCondition }
        else if representedExistingCondition != nil { return representedExistingCondition }
        else {return nil}
    }
    
    func populateWithCondition(_ thisCondition: EvaluateCondition){}
    
    @IBAction func removeConditionButtonClicked(_ sender: Any)
    {
        let parent = self.parent as! ConditionsViewController
        if parent.newConditionStackView.arrangedSubviews.count == 1 {return}
        else { deleteView() }
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
        parent.curCondition.conditions.removeAll { (c1: EvaluateCondition)->Bool in
            if let c1s = c1 as? SingleCondition { return c1s == self.representedSingleCondition }
            else if let c1s = c1 as? Condition { return c1s == self.representedExistingCondition}
            else {return false}
        }
    }
}

class AddExistingConditionViewController: AddConditionViewController {
    @IBOutlet weak var conditionSelectorPopup: NSPopUpButton!
    @IBOutlet var existingConditionsArrayController: NSArrayController!
    @objc var existingConditions: [Condition]!
    override func viewDidLoad() {
        //initLoadAll()
        super.viewDidLoad()
    }
    func initLoadAll(){
        existingConditions = analysis.conditions
        representedExistingCondition = existingConditions[0]
        existingConditionsArrayController.content = existingConditions
    }
    override func populateWithCondition(_ thisCondition: EvaluateCondition){
        guard let condition = thisCondition as? Condition else { return }
        initLoadAll()
        representedExistingCondition = condition
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

    @objc var variableSelectorViewController : VariableSelectorViewController?
    @objc var selectedVariable: Variable!
    @IBOutlet var singleConditionObjectController: NSObjectController!
    
    override func viewDidLoad() {
        representedSingleCondition = SingleCondition()
        super.viewDidLoad()
    }
    
    override func populateWithCondition(_ thisCondition: EvaluateCondition){
        guard let singleCondition = thisCondition as? SingleCondition else { return }
        representedSingleCondition = singleCondition
        if singleCondition.lbound != nil {
            lowerBoundTextField.stringValue = "\(singleCondition.lbound!)"
            intervalTypeRadioButton.state = .on
        }
        if singleCondition.ubound != nil {
            upperBoundTextField.stringValue = "\(singleCondition.ubound!)"
            intervalTypeRadioButton.state = .on
        }
        else if singleCondition.equality != nil {
            upperBoundTextField.stringValue = "\(singleCondition.equality!)"
            equalityTypeRadioButton.state = .on
        } else {equalityTypeRadioButton.state = .off}
        if singleCondition.specialCondition != nil {
            
        }
        variableSelectorViewController?.selectVariable(with: singleCondition.varID)
        //else if singleCondition.specialCondition != nil { }
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "variableSelectorSegue" {
            guard let viewController = segue.destinationController as? VariableSelectorViewController else {return}
            variableSelectorViewController = viewController
        }
    }
    
    func initLoadVars(){
        guard variableSelectorViewController != nil else {return}
        variableSelectorViewController!.representedObject = analysis
        variableSelectorViewController!.initLoadVars()
        /*
        _ = self.observe(\.variableSelectorViewController) { object, change in
            self.singleCondition.varID = self.variableSelectorViewController?.selectedVariable?.id
            print(self.variableSelectorViewController?.selectedVariable?.id)
         }*/ // TODO: get this observer working
        
    }
    func getVariable(){
        representedSingleCondition.varID = self.variableSelectorViewController!.selectedVariable!.id
        
    }
    
    
    @IBAction func customTypeWasSelected(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else {return}
        let specialOptions: Array<SpecialConditionType> = [.globalMax, .globalMin, .localMax, .localMin]
        if selectedType == .other { representedSingleCondition.specialCondition = specialOptions[popup.indexOfSelectedItem] }
    }
    @IBAction func upperBoundWasSet(_ sender: Any) {
        let varVal = VarValue(upperBoundTextField.stringValue)
        if selectedType == .interval {
            representedSingleCondition.ubound = varVal
        } else if selectedType == .equality {
            representedSingleCondition.equality = varVal
        }
    }
    @IBAction func lowerBoundWasSet(_ sender: Any) {
        if selectedType == .interval { representedSingleCondition.lbound = VarValue(lowerBoundTextField.stringValue) }
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
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorEqual:
            comparisonLabelCell.stringValue = "="
            conditionInputStackView.showHideViews(.show, index: [4])
            conditionInputStackView.showHideViews(.hide, index: [0,1,5])
            selectedType = .equality
            representedSingleCondition.ubound = nil
            representedSingleCondition.lbound = nil
            representedSingleCondition.specialCondition = nil
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorOther:
            comparisonLabelCell.stringValue = "is"
            conditionInputStackView.showHideViews(.hide, index: [0,1,4])
            conditionInputStackView.showHideViews(.show, index: [5])
            selectedType = .other
            representedSingleCondition.lbound = nil
            representedSingleCondition.ubound = nil
            representedSingleCondition.equality = nil
        default:
            return
        }
    }
}

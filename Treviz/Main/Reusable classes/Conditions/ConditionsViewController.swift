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
    //var initVars : [Variable] = []
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var compoundConditionButton: NSButton!
    @IBOutlet weak var unionTypeDropdown: NSPopUpButton!
    @IBOutlet weak var newConditionStackView: NSStackView!
    @IBOutlet weak var methodStackView: NSStackView!
    @IBOutlet weak var conditionNameTextBox: NSTextField!
    @IBOutlet var allConditionsArrayController: NSArrayController!
    
    @IBAction func addConditionButtonClicked(_ sender: Any) {
        if conditionNameTextBox.stringValue == "" {
            conditionNameTextBox.becomeFirstResponder() //Set focus to the name field if it is empty
            return
        }
        for thisVC in self.children {
            guard let condVC = thisVC as? AddConditionViewController else {continue}
            condVC.getVariable() //TODO: handle this more automatically
        }
        analysis.conditions.append(curCondition)
        allConditionsArrayController.addObject(curCondition)
        NotificationCenter.default.post(name: .didAddCondition, object: nil)
        tableView.reloadData()
    }
    
    
    @IBAction func compoundConditionButtonClicked(_ sender: Any) {
        if newConditionStackView.views.count == 1 {
            let firstViewController = self.children[0] as! AddConditionViewController
            firstViewController.removeConditionButton.isHidden = false
        }
        _ = addConditionView()
    }
    
    @IBOutlet var comparisonLabel: NSButton!
    
    override func viewDidLoad() {
        // Do view setup here.
        allConditions = analysis?.conditions
        
        let newVC = addConditionView()
        newVC.removeConditionButton.isHidden = true
        allConditionsArrayController.content = allConditions
        
        let trackingArea = NSTrackingArea(rect: self.compoundConditionButton.bounds,
                                          options: [NSTrackingArea.Options.mouseEnteredAndExited,
                                                    NSTrackingArea.Options.activeAlways,
                                                    //NSTrackingArea.Options.inVisibleRect
                                                    ],
                                          owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
        super.viewDidLoad()
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
    
    @IBAction func conditionNameTextFieldChanged(_ sender: Any) {
        curCondition.name = (sender as! NSTextField).stringValue
    }
    @IBAction func joinTypePopupButtonClicked(_ sender: Any) {
        if curCondition.conditions.count == 1 {
            curCondition.unionType = .single
        } else {
            curCondition.unionType = BoolType(rawValue: unionTypeDropdown.indexOfSelectedItem - 1)!
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 51 {//NSDeleteCharacter {
            if tableView.selectedRow != -1 {
                //let outputToRemove = allConditions![tableView.selectedRow]
                analysis.conditions.remove(at: tableView.selectedRow)
                allConditionsArrayController.remove(atArrangedObjectIndex: tableView.selectedRow)
                NotificationCenter.default.post(name: .didRemoveCondition, object: nil)
            }
        }
    }
    
    func addConditionView()->AddConditionViewController {
        let storyboard = NSStoryboard(name: "Conditions", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "addConditionViewController") as! AddConditionViewController
        viewController.representedObject = analysis
        newConditionStackView.addArrangedSubview(viewController.view)
        viewController.initLoadVars()
        // viewController.variableList = analysis!.varList
        // viewController.variableSelectorViewController?.variableSelectorArrayController.content = analysis!.varList // TODO: Do this MUCH more cleanly
        self.addChild(viewController)
        if newConditionStackView.arrangedSubviews.count > 1{
            newConditionStackView.layer?.borderWidth = 1
            newConditionStackView.layer?.borderColor = CGColor.init(gray: 0.35, alpha: 1)
            methodStackView.isHidden = false
            joinTypePopupButtonClicked(self)
        } else {
            newConditionStackView.layer?.borderWidth = 0
            methodStackView.isHidden = true
            curCondition.unionType = .single
        }
        
        curCondition.conditions.append(viewController.singleCondition)
        return viewController
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


// New View Controller
enum singleConditionType : String {
    case interval = "interval"
    case equality = "equality"
    case other = "other"
}

class AddConditionViewController: TZViewController {

    @IBOutlet weak var intervalTypeRadioButton: NSButton!
    @IBOutlet weak var equalityTypeRadioButton: NSButton!
    @IBOutlet weak var comparisonLabelCell: NSTextFieldCell!
    @IBOutlet weak var conditionInputStackView: CollapsibleStackView!
    @IBOutlet weak var lowerBoundTextField: NSTextField!
    @IBOutlet weak var upperBoundTextField: NSControl!//NSTextField!
    @IBOutlet weak var removeConditionButton: NSButton!
    var selectedType : singleConditionType = .interval
    var variableList : [Variable] = []
    @objc var variableSelectorViewController : VariableSelectorViewController?
    @objc var singleCondition = SingleCondition()
    @objc var selectedVariable: Variable!
    @IBOutlet var singleConditionObjectController: NSObjectController!
    
    override func viewDidLoad() {
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
    func getVariable(){ singleCondition.varID = self.variableSelectorViewController!.selectedVariable!.id }
    
    @IBAction func removeConditionButtonClicked(_ sender: Any) {
        let parent = self.parent as! ConditionsViewController
        if parent.newConditionStackView.arrangedSubviews.count == 1 {return}
        parent.newConditionStackView.removeArrangedSubview(self.view)
        self.view.removeFromSuperview()
        self.removeFromParent()
        parent.curCondition.conditions.removeAll { (c1: EvaluateCondition)->Bool in
            if let c1s = c1 as? SingleCondition {return c1s == self.singleCondition} else {return false} }
        if parent.newConditionStackView.arrangedSubviews.count == 1 {
            let lastVC = parent.children[0] as! AddConditionViewController
            lastVC.removeConditionButton.isHidden = true
            parent.newConditionStackView.layer?.borderWidth = 0
            parent.methodStackView.isHidden = true
        }
    }
    
    @IBAction func customTypeWasSelected(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else {return}
        let specialOptions: Array<SpecialConditionType> = [.globalMax, .globalMin, .localMax, .localMin]
        if selectedType == .other { singleCondition.specialCondition = specialOptions[popup.indexOfSelectedItem] }
    }
    @IBAction func upperBoundWasSet(_ sender: Any) {
        let varVal = VarValue(upperBoundTextField.stringValue)
        if selectedType == .interval {
            singleCondition.ubound = varVal
        } else if selectedType == .equality {
            singleCondition.equality = varVal
        }
    }
    @IBAction func lowerBoundWasSet(_ sender: Any) {
        if selectedType == .interval { singleCondition.lbound = VarValue(upperBoundTextField.stringValue) }
    }
    @IBAction func typeWasSelected(_ sender: NSButton) {
        switch(sender.identifier){
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorInterval:
            comparisonLabelCell.stringValue = "<"
            conditionInputStackView.showHideViews(.show, index: [0,1,4])
            conditionInputStackView.showHideViews(.hide, index: [5])
            selectedType = .interval
            singleCondition.equality = nil
            singleCondition.specialCondition = nil
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorEqual:
            comparisonLabelCell.stringValue = "="
            conditionInputStackView.showHideViews(.show, index: [4])
            conditionInputStackView.showHideViews(.hide, index: [0,1,5])
            selectedType = .equality
            singleCondition.ubound = nil
            singleCondition.lbound = nil
            singleCondition.specialCondition = nil
        case NSUserInterfaceItemIdentifier.singleConditionTypeSelectorOther:
            comparisonLabelCell.stringValue = "is"
            conditionInputStackView.showHideViews(.hide, index: [0,1,4])
            conditionInputStackView.showHideViews(.show, index: [5])
            selectedType = .other
            singleCondition.lbound = nil
            singleCondition.ubound = nil
            singleCondition.equality = nil
        default:
            return
        }
    }
    
}

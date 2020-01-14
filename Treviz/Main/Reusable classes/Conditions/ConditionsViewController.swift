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
    @IBOutlet weak var addConditionButton: NSButton!
    @IBOutlet weak var unionTypeDropdown: NSPopUpButton!
    @IBOutlet weak var newConditionStackView: NSStackView!
    @IBOutlet weak var methodStackView: NSStackView!
    @IBOutlet weak var conditionNameTextBox: NSTextField!
    @IBOutlet var allConditionsArrayController: NSArrayController!
    @IBOutlet var addConditionTypeMenu: NSMenu!
    @IBOutlet var comparisonLabel: NSButton!
    
    @IBAction func addConditionButtonClicked(_ sender: Any) {
        if conditionNameTextBox.stringValue == "" {
            conditionNameTextBox.becomeFirstResponder() //Set focus to the name field if it is empty
            return
        }
        for thisVC in self.children {
            if let condVC = thisVC as? AddNewConditionViewController {
                _ = condVC.variableSelectorViewController?.getSelectedItem()
                condVC.getVariable() //TODO: handle this more automatically
                curCondition.conditions.append(condVC.representedSingleCondition)
            } else if let condVC = thisVC as? AddExistingConditionViewController {
                condVC.representedExistingCondition = (condVC.conditionSelectorPopup.selectedItem?.representedObject as! Condition)
                curCondition.conditions.append(condVC.representedExistingCondition)
            }
        }
        
        //let dsum = curCondition.summary
        //curCondition.summary = dsum
        //print(curCondition.summary)
        analysis.conditions.append(curCondition)
        allConditionsArrayController.content = analysis.conditions
        NotificationCenter.default.post(name: .didAddCondition, object: nil)
        
        resetView()
        tableView.reloadData()
    }
    
    
    @IBAction func addSubCondition(_ sender: Any) {
        if newConditionStackView.views.count == 1 {
            let firstViewController = self.children[0] as! AddConditionViewController
            firstViewController.removeConditionButton.isHidden = false
        }
        if let buttonID = (sender as? NSButton)?.identifier?.rawValue {
            if buttonID == "compoundConditionButton" { _ = addNewConditionView() }
        } else if let senderMenuItem = (sender as? NSMenuItem){
            if senderMenuItem.identifier!.rawValue == "addNewConditionMenuItem" { _ = addNewConditionView() }
            else if senderMenuItem.identifier!.rawValue == "addExistingConditionMenuItem" { _ = addExistingConditionView() }
        }
        if newConditionStackView.arrangedSubviews.count > 1{
            newConditionStackView.layer?.borderWidth = 1
            newConditionStackView.layer?.borderColor = CGColor.init(gray: 0.35, alpha: 1)
            methodStackView.isHidden = false
            unionTypeDropdown.selectItem(at: 0)
            curCondition.unionType = .and
            joinTypePopupButtonClicked(self)
        } else {
            newConditionStackView.layer?.borderWidth = 0
            methodStackView.isHidden = true
            curCondition.unionType = .single
        }
    }
        
    override func viewDidLoad() {
        // Do view setup here.
        allConditions = analysis?.conditions
        
        let newVC = addNewConditionView()
        newVC.removeConditionButton.isHidden = true
        allConditionsArrayController.content = allConditions
        
        let trackingArea = NSTrackingArea(rect: self.compoundConditionButton.bounds,
                                          options: [NSTrackingArea.Options.mouseEnteredAndExited,
                                                    NSTrackingArea.Options.activeAlways,
                                                    //NSTrackingArea.Options.inVisibleRect
                                                    ],
                                          owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
        //let longPress = NSPressGestureRecognizer(target: self, action: #selector(longPressAddCondition(_:)))
        //compoundConditionButton.addGestureRecognizer(longPress)
        super.viewDidLoad()
    }

    func resetView(){
        eraseView()
        let newVC = addNewConditionView()
        newVC.removeConditionButton.isHidden = true
        newVC.initLoadVars()
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
            curCondition.unionType = BoolType(rawValue: unionTypeDropdown.indexOfSelectedItem + 1)!
        }
    }
    
    @IBAction func tableViewSelected(_ sender: NSTableView) {
        let tableRow = tableView.selectedRow
        if tableRow != -1 {
            curCondition = analysis.conditions[tableRow]
            eraseView()
            conditionNameTextBox.stringValue = curCondition.name
            unionTypeDropdown.selectItem(withTitle: curCondition.unionType.stringValue())
            for thisCondition in curCondition.conditions {
                var newVC: AddConditionViewController!
                if thisCondition is Condition {
                    newVC = addExistingConditionView()
                    newVC.representedExistingCondition = (thisCondition as! Condition)
                } else if thisCondition is SingleCondition {
                    newVC = addNewConditionView()
                    newVC.representedSingleCondition = (thisCondition as! SingleCondition)
                }
                newVC.populateWithCondition(thisCondition)
                newVC.removeConditionButton.isHidden = true
            }
            addConditionButton.isHidden = true
        } else {
            addConditionButton.isHidden = false
            resetView()
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
    
    func addExistingConditionView()->AddExistingConditionViewController {
        let storyboard = NSStoryboard(name: "Conditions", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "addExistingConditionViewController") as! AddExistingConditionViewController
        viewController.representedObject = analysis
        viewController.initLoadAll()
        newConditionStackView.addArrangedSubview(viewController.view)
        self.addChild(viewController)
        // curCondition.conditions.append(viewController.representedExistingCondition)
        return viewController
    }
    
    func addNewConditionView()->AddNewConditionViewController {
        let storyboard = NSStoryboard(name: "Conditions", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "addNewConditionViewController") as! AddNewConditionViewController
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
            unionTypeDropdown.selectItem(at: 0)
            joinTypePopupButtonClicked(self)
        } else {
            newConditionStackView.layer?.borderWidth = 0
            methodStackView.isHidden = true
            curCondition.unionType = .single
        }
        
        //curCondition.conditions.append(viewController.representedSingleCondition)
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

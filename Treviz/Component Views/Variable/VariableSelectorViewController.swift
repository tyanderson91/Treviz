//
//  VariableSelectorViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/23/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

protocol VariableGetter {
    func variableDidChange(_ sender: VariableSelectorViewController)
}

class VariableSelectorViewController: TZViewController {

    @IBOutlet weak var variableSelectorPopup: NSPopUpButton!
    //@IBOutlet var variableSelectorArrayController: NSArrayController!
    var selectedVariable : Variable? {
        didSet {
            guard selectedVariable != nil else { return }
            if let thisVarIndex = varList?.firstIndex(where: {$0.id == self.selectedVariable!.id }) {
                selectedVariable = varList?[thisVarIndex]
                variableSelectorPopup?.selectItem(at: thisVarIndex)
            }
        }
    }
    
    //var unwrappedVariable : Variable { return selectedVariable! }
    var varList: [Variable]! { analysis.varList }
    var variableGetter: VariableGetter?
    
    override func viewDidLoad() {
        //variableSelectorPopup.bind(.selectedObject, to: self, withKeyPath: "selectedVariable", options: nil)
        super.viewDidLoad()
        loadVars()
        /*NotificationCenter.default.addObserver(self, selector: #selector(self.addVariables(_:)), name: .didLoadAppDelegate, object: nil)
        if let thisAnalysis = self.representedObject as? Analysis { //TODO: use bindings rather than manually typing the name
            for thisVariable in thisAnalysis.varList! {
                variableSelectorPopup.addItem(withTitle: thisVariable.name)
            }
        }*/
        //initLoadVars()
        if selectedVariable != nil {
            selectVariable(with: selectedVariable!.id)
            //variableSelectorPopup.selectItem(at: varList?.firstIndex(of: selectedVariable!) ?? 0)
        }
    }

    
    func loadVars(){
        //variableSelectorArrayController.content = varList
        variableSelectorPopup.addItems(withTitles: varList.compactMap { $0.name } )
        //variableSelectorPopup.bind(.selectedObject, to: self, withKeyPath: "selectedVariable", options: nil)
    }
    
    func addVariables(_ notification: NSNotification){
        loadVars()
    }
    
    /*
    func getSelectedItem()->Variable?{
        guard let varTitle = self.variableSelectorPopup.titleOfSelectedItem else { return nil }
        if let thisVariable = self.analysis.varList.first(where: {$0.name == varTitle }) {
            selectedVariable = thisVariable
            return thisVariable
        }
        else { return nil }
    }*/
    
    @IBAction func didSelectVar(_ sender: Any) {
        if let button = sender as? NSPopUpButton {
            let selectedIndex = button.indexOfSelectedItem
            selectedVariable = varList[selectedIndex]
            
        }
        if variableGetter != nil { variableGetter!.variableDidChange(self) }
        else if let parentGetter = parent as? VariableGetter { parentGetter.variableDidChange(self) }
    }
    
    func selectVariable(with varid: VariableID?){
        if let thisVarIndex = varList?.firstIndex(where: {$0.id == varid }) {
            selectedVariable = varList?[thisVarIndex]
        }
    }
}

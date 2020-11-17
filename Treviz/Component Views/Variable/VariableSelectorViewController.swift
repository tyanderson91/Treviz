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
    var selectedVariable : Variable? {
        didSet {
            guard selectedVariable != nil else { return }
            if let thisVarIndex = varList?.firstIndex(where: {$0.id == self.selectedVariable!.id }) {
                selectedVariable = varList?[thisVarIndex]
                variableSelectorPopup?.selectItem(at: thisVarIndex+1)
            }
        }
    }
    
    var varList: [Variable]! { analysis.varList }
    var variableGetter: VariableGetter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVars()
        if selectedVariable != nil {
            selectVariable(with: selectedVariable!.id)
        }
    }

    
    func loadVars(){
        variableSelectorPopup.addItem(withTitle: "")
        variableSelectorPopup.addItems(withTitles: varList.compactMap { $0.name } )
    }
    
    func addVariables(_ notification: NSNotification){
        loadVars()
    }
    
    @IBAction func didSelectVar(_ sender: Any) {
        if let button = sender as? NSPopUpButton {
            let selectedIndex = button.indexOfSelectedItem
            if selectedIndex > 0 {
                selectedVariable = varList[selectedIndex-1]
            } else { selectedVariable = nil }
        }
        if variableGetter != nil { variableGetter!.variableDidChange(self) }
        else if let parentGetter = parent as? VariableGetter { parentGetter.variableDidChange(self) }
    }
    
    func selectVariable(with varid: ParamID?){
        if let thisVarIndex = varList?.firstIndex(where: {$0.id == varid }) {
            selectedVariable = varList?[thisVarIndex]
        }
    }
}

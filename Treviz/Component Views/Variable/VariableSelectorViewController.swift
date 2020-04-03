//
//  VariableSelectorViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/23/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class VariableSelectorViewController: TZViewController {

    @IBOutlet weak var variableSelectorPopup: NSPopUpButton!
    @IBOutlet var variableSelectorArrayController: NSArrayController!
    @objc dynamic var selectedVariable : Variable?
    @objc dynamic var unwrappedVariable : Variable { return selectedVariable! }
    @objc var varList: [Variable]? { return analysis != nil ? analysis.varList : nil }
    
    override func viewDidLoad() {
        variableSelectorPopup.bind(.selectedObject, to: self, withKeyPath: "selectedVariable", options: nil)
        super.viewDidLoad()
        /*NotificationCenter.default.addObserver(self, selector: #selector(self.addVariables(_:)), name: .didLoadAppDelegate, object: nil)
        if let thisAnalysis = self.representedObject as? Analysis { //TODO: use bindings rather than manually typing the name
            for thisVariable in thisAnalysis.varList! {
                variableSelectorPopup.addItem(withTitle: thisVariable.name)
            }
        }*/
        initLoadVars()
    }

    
    func initLoadVars(){
        variableSelectorArrayController.content = varList
        //variableSelectorPopup.bind(.selectedObject, to: self, withKeyPath: "selectedVariable", options: nil)
    }
    
    @objc func addVariables(_ notification: NSNotification){
        if analysis != nil { //TODO: use bindings rather than manually typing the name
            for thisVariable in analysis.varList! {
                variableSelectorPopup.addItem(withTitle: thisVariable.name)
            }
        }
    }
    
    func getSelectedItem()->Variable?{
        guard let varTitle = self.variableSelectorPopup.titleOfSelectedItem else { return nil }
        if let thisVariable = self.analysis.varList.first(where: {$0.name == varTitle }) {
            selectedVariable = thisVariable
            return thisVariable
        }
        else { return nil }
    }
    
    func selectVariable(with varid: VariableID?){
        if let thisVarIndex = varList?.firstIndex(where: {$0.id == varid }) {
            selectedVariable = varList?[thisVarIndex]
        }
    }
}

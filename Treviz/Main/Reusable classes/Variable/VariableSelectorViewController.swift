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
    //var analysis : Analysis?
    var selectedVariable : Variable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addVariables()
        
        // Do view setup here.
    }
    
    override func viewWillAppear() { //TODO : figure out why the 'analysis'' object is not loaded by the time viewDidLoad is called, forcing me to put this part in viewDidAppear
        self.addVariables()
    }
    
    func addVariables(){//_ vars : [Variable]){// TODO : make more automatic from parent analysis
        
        //if let parentViewController = self.parent as? ViewController {
        if let thisAnalysis = self.representedObject as? Analysis {
            //self.representedObject = thisAnalysis
            for thisVariable in thisAnalysis.analysisData.initVars! {
                variableSelectorPopup.addItem(withTitle: thisVariable.name)
            }
        }
        //}
        /*
        
        if let theseVars = self.analysis!.analysisData.initVars {
            for thisVariable in self.analysis!.analysisData.initVars! {
                variableSelectorPopup.addItem(withTitle: thisVariable.name)
            }
        }*/
    }
    
    func getSelectedItem()->Variable?{
        guard let varTitle = self.variableSelectorPopup.titleOfSelectedItem else { return nil }
        if let thisVariable = Variable.getVar(fromName: varTitle, inputList: (analysis?.analysisData.initVars!)!) {
            return thisVariable
        }
        return nil
    }
    
}

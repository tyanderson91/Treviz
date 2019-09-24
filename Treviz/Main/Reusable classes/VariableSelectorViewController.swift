//
//  VariableSelectorViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/23/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class VariableSelectorViewController: NSViewController {

    @IBOutlet weak var variableSelectorPopup: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addVariables()
        
        // Do view setup here.
    }
    
    override func viewWillAppear() { //TODO : figure out why the 'analysis'' object is not loaded by the time viewDidLoad is called, forcing me to put this part in viewDidAppear
        self.addVariables()
    }
    func addVariables(){//_ vars : [Variable]){// TODO : make more automatic from parent analysis
        if let parentViewController = self.parent as? ViewController {
            if let analysis = parentViewController.representedObject as? Analysis {
                for thisVariable in analysis.analysisData.initVars! {
                    variableSelectorPopup.addItem(withTitle: thisVariable.name)
                }
            }
        }
        /*
        for thisVariable in vars {
            variableSelectorPopup.addItem(withTitle: thisVariable.name)
        }*/
    }
    
}

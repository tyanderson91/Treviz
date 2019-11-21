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
    var selectedVariable : Variable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.addVariables(_:)), name: .didLoadAppDelegate, object: nil)
    }
    
    override func viewWillAppear() {
    }
    
    @objc func addVariables(_ notification: NSNotification){
        if let thisAnalysis = self.representedObject as? Analysis { //TODO: use bindings rather than manually typing the name
            for thisVariable in thisAnalysis.varList! {
                variableSelectorPopup.addItem(withTitle: thisVariable.name)
            }
        }
    }
    
    func getSelectedItem()->Variable?{
        guard let varTitle = self.variableSelectorPopup.titleOfSelectedItem else { return nil }
        if let thisVariable = self.analysis.varList.first(where: {$0.name == varTitle })
        {return thisVariable}
        else {return nil}
    }
}

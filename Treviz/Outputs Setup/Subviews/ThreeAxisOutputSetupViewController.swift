//
//  ThreeAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class ThreeAxisOutputSetupViewController: AddOutputViewController {
    
    @IBOutlet weak var gridView: CollapsibleGridView!
    
    @IBOutlet weak var variableGridView: NSGridView!
    
    override func headerTitle() -> String { return NSLocalizedString("Three Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        let var1ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        self.addChild(var1ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 0).contentView = var1ViewController.view
        
        let var2ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        self.addChild(var2ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var2ViewController.view
        
        let var3ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        self.addChild(var3ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 2).contentView = var3ViewController.view
        // Do view setup here.
        plotTypeSelector = { (thisPlotType : PlotType)->(Bool) in return thisPlotType.nAxis == 3 }
    }
        
    override func didDisclose() {
        if disclosureState == .closed {
            gridView.showHideCols(.hide, index: [0,1,2])
        } else {
            gridView.showHideCols(.show, index: [0,1,2])
        }
    }
}

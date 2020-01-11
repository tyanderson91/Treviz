//
//  ThreeAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class ThreeAxisOutputSetupViewController: AddOutputViewController {
    
    var var1ViewController : VariableSelectorViewController!
    var var2ViewController : VariableSelectorViewController!
    var var3ViewController : VariableSelectorViewController!
    override func plotTypeSelector(_ plotType: TZPlotType)->(Bool){ return plotType.nAxis == 3 }

    
    @IBOutlet weak var gridView: CollapsibleGridView!
    
    @IBOutlet weak var variableGridView: NSGridView!
    
    override func headerTitle() -> String { return NSLocalizedString("Three Axis", comment: "") }
    
    override func viewDidLoad() {
        
        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        var1ViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        var1ViewController.representedObject = self.analysis
        self.addChild(var1ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 0).contentView = var1ViewController.view
        
        var2ViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        var2ViewController.representedObject = self.analysis
        self.addChild(var2ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var2ViewController.view
        
        var3ViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        var3ViewController.representedObject = self.analysis
        self.addChild(var3ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 2).contentView = var3ViewController.view
        
        super.viewDidLoad()

        var1ViewController.selectedVariable = self.representedOutput.var1
        var2ViewController.selectedVariable = self.representedOutput.var2
        var3ViewController.selectedVariable = self.representedOutput.var3
        // Do view setup here.
        /*setWidth(component: var1ViewController!, width: varSelectorWidth)
        setWidth(component: var2ViewController!, width: varSelectorWidth)
        setWidth(component: var3ViewController!, width: varSelectorWidth)*/
    }
    
    override func createOutput()->TZOutput? {// TODO : expand for all plot types
        //TODO : Allow 3 variables
        
        guard let plotType = plotTypePopupButton.selectedItem?.title else {return nil}
        var var1 : Variable?
        var var2 : Variable?
        guard let var1Name = var1ViewController.variableSelectorPopup.selectedItem?.title else {return nil}
        guard let var2Name = var2ViewController.variableSelectorPopup.selectedItem?.title else {return nil}
        var1 = analysis.varList.first(where: {$0.name == var1Name} )
        var2 = analysis.varList.first(where: {$0.name == var2Name} )
        
        let newPlot = TZPlot(id: maxPlotID+1, vars: [var1!, var2!], plotType: TZPlotType.getPlotTypeByName(plotType)!)
        //newPlot.setName()
        return newPlot
        //return nil
    }
    
    override func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        return
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
}

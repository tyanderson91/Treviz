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
    
    @IBOutlet weak var gridView: CollapsibleGridView!
    
    @IBOutlet weak var variableGridView: NSGridView!
    
    override func headerTitle() -> String { return NSLocalizedString("Three Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        var1ViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        self.addChild(var1ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 0).contentView = var1ViewController.view
        
        var2ViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        self.addChild(var2ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var2ViewController.view
        
        var3ViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        self.addChild(var3ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 2).contentView = var3ViewController.view
        // Do view setup here.
        plotTypeSelector = { return $0.nAxis == 3 }
        
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
        var1 = analysis.initVars.first(where: {$0.name == var1Name} )
        var2 = analysis.initVars.first(where: {$0.name == var2Name} )
        
        let newPlot = TZPlot(id: maxPlotID+1, vars: [var1!, var2!], plotType: PlotType.getPlotTypeByName(plotType)!)
        //newPlot.setName()
        return newPlot
        //return nil
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
}

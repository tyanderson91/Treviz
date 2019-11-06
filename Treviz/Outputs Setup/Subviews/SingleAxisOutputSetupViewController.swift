//
//  SettingStackViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class SingleAxisOutputSetupViewController: AddOutputViewController {

    @IBOutlet weak var gridView: CollapsibleGridView!
    var variableSelectorViewController : VariableSelectorViewController!
    
    override func createOutput() -> TZOutput? {// TODO : expand for all plot types
        guard let plotType = plotTypePopupButton.selectedItem?.title else {return nil}
        let var1 = variableSelectorViewController?.getSelectedItem()
        let newOutput = TZOutput(id: maxPlotID+1, vars: [var1!], plotType: PlotType.getPlotTypeByName(plotType)!)
        let condIndex = conditionsComboBox.indexOfSelectedItem
        if condIndex>=0 { newOutput.condition = analysis.conditions[condIndex] }
        return newOutput
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Single Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        variableSelectorViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        self.addChild(variableSelectorViewController)
        gridView.cell(atColumnIndex: 0, rowIndex: 1).contentView = variableSelectorViewController.view
        
        plotTypeSelector = { return $0.nAxis == 1 }
        
        // setWidth(component: variableSelectorViewController!, width: varSelectorWidth)
        
        //let variableSelectorViewController = VariableSelectorViewController()
        //self.addChild(variableSelectorViewController)
        //gridView.cell(atColumnIndex: 0, rowIndex: 1).contentView = variableSelectorViewController.view
        //variableSelectorViewController.addVariables()
       // didDisclose()
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
    
}

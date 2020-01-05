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
    override func plotTypeSelector(_ plotType: TZPlotType)->(Bool){ return plotType.nAxis == 1 }
    
    override func createOutput() -> TZOutput? {// TODO : expand for all plot types
        guard let plotType = plotTypePopupButton.selectedItem?.title else {return nil}
        let var1 = variableSelectorViewController?.getSelectedItem()
        let newOutput = TZOutput(id: maxPlotID+1, vars: [var1!], plotType: TZPlotType.getPlotTypeByName(plotType)!)
        //let condIndex = conditionsComboBox.indexOfSelectedItem
        //if condIndex>=0 { newOutput.condition = analysis.conditions[condIndex] }
        return newOutput
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Single Axis", comment: "") }
    
    override func viewDidLoad() {
        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        variableSelectorViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        super.viewDidLoad()
        
        variableSelectorViewController.representedObject = self.analysis
        self.addChild(variableSelectorViewController)
        gridView.cell(atColumnIndex: 0, rowIndex: 1).contentView = variableSelectorViewController.view
        self.variableSelectorViewController.view.becomeFirstResponder()
    }
    
    override func loadAnalysis(_ analysis: Analysis?) {
        super.loadAnalysis(analysis)
        if analysis != nil {
            variableSelectorViewController.representedObject = analysis!
            variableSelectorViewController.variableSeletorArrayController.content = analysis?.varList
        }
    }

    override func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        let output = text == nil ? plot : text as! TZOutput
        // variableSelectorViewController.selectedVariable = output
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
    
}

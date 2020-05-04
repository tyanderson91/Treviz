//
//  TwoAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class TwoAxisOutputSetupViewController: AddOutputViewController {
    
    
    override func plotTypeSelector(_ plotType: TZPlotType)->(Bool){ return plotType.nAxis == 2 }

    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var variableGridView: CollapsibleGridView!

    @IBOutlet weak var plottingStackView: NSStackView!

    @objc var var1ViewController: VariableSelectorViewController!
    @objc var var2ViewController: VariableSelectorViewController!
    @objc var var3ViewController: VariableSelectorViewController!
    
    override func createOutput()->TZOutput? {// TODO : expand for all plot types
        /*
        if let plotType = plotTypeDropDown.selectedItem?.title{
            let newPlot = TZPlot1line2d()
            newPlot.plotType = PlotType(rawValue: plotType)!
            //newPlot.var1 = variableSelectorViewController?.getSelectedItem()
            newPlot.setName()
            return newPlot
        }*/
        return nil
    }
    
    override func getHeaderTitle() -> String { return NSLocalizedString("Two Axis", comment: "") }
    
    override func viewDidLoad() {
        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        var1ViewController = storyboard.instantiateController(identifier: "variableSelectorViewController") { aDecoder in VariableSelectorViewController(coder: aDecoder, analysis: self.analysis) }
        self.addChild(var1ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 0).contentView = var1ViewController.view
        
        var2ViewController = storyboard.instantiateController(identifier: "variableSelectorViewController") { aDecoder in VariableSelectorViewController(coder: aDecoder, analysis: self.analysis) }
        self.addChild(var2ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var2ViewController.view
        
        var3ViewController = storyboard.instantiateController(identifier: "variableSelectorViewController") { aDecoder in VariableSelectorViewController(coder: aDecoder, analysis: self.analysis) }
        self.addChild(var3ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 2).contentView = var3ViewController.view
        
        loadAnalysis(analysis)
        super.viewDidLoad()

        /*
        setWidth(component: var1ViewController, width: varSelectorWidth)
        setWidth(component: var2ViewController, width: varSelectorWidth)
        setWidth(component: var3ViewController, width: varSelectorWidth)*/
    }
    
    override func variableDidChange(_ sender: VariableSelectorViewController) {
        representedOutput.var1 = var1ViewController.selectedVariable
        representedOutput.var2 = var2ViewController.selectedVariable
        representedOutput.var3 = var3ViewController.selectedVariable
    }
    
    override func loadAnalysis(_ analysis: Analysis?) {
        super.loadAnalysis(analysis)
        if analysis != nil {
            for varname in ["var1", "var2", "var3"] {
                if let vc = self.value(forKey: varname + "ViewController") as? VariableSelectorViewController {
                    vc.representedObject = analysis!
                    vc.selectedVariable = representedOutput.value(forKey: varname) as? Variable ?? nil
                    //vc.variableSelectorArrayController.content = analysis?.varList
                    //vc.variableSelectorPopup.bind(.selectedObject, to: representedOutput as Any, withKeyPath: varname, options: nil)
                }
            }
        }
    }
    
    override func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        var1ViewController.selectedVariable = self.representedOutput.var1
        var2ViewController.selectedVariable = self.representedOutput.var2
        var3ViewController.selectedVariable = self.representedOutput.var3

        if representedOutput.plotType.nVars == 2 {
            let vg = variableGridView
            vg!.showHide(.hide, .row, index: [2])
        }
        return
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
}


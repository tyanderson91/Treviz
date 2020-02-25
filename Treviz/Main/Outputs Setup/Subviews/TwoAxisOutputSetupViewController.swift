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
    @IBOutlet weak var variableGridView: NSGridView!

    @IBOutlet weak var plottingStackView: NSStackView!

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
        let var1ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        var1ViewController.representedObject = self.analysis
        self.addChild(var1ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 0).contentView = var1ViewController.view
        
        let var2ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        var2ViewController.representedObject = self.analysis
        self.addChild(var2ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var2ViewController.view
        
        let var3ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        var3ViewController.representedObject = self.analysis
        self.addChild(var3ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 2).contentView = var3ViewController.view
        
        super.viewDidLoad()
        var1ViewController.selectedVariable = self.representedOutput.var1
        var2ViewController.selectedVariable = self.representedOutput.var2
        var3ViewController.selectedVariable = self.representedOutput.var3

        /*
        setWidth(component: var1ViewController, width: varSelectorWidth)
        setWidth(component: var2ViewController, width: varSelectorWidth)
        setWidth(component: var3ViewController, width: varSelectorWidth)*/
    }
    
    override func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        return
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
}


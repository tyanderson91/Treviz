//
//  TwoAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class TwoAxisOutputSetupViewController: AddOutputViewController {
    
    @IBOutlet weak var variable1View: NSView!
    @IBOutlet weak var variable2View: NSView!
    @IBOutlet weak var variable3View: NSView!
    @IBOutlet weak var plotTypeDropDown: NSPopUpButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var variableGridView: NSGridView!
    
    
    var conditions : [Condition] = []

    
    @IBOutlet weak var plottingStackView: NSStackView!
    var strongAddButtonLeadingConstraint1 : NSLayoutConstraint? = nil
    var strongAddButtonLeadingConstraint2 : NSLayoutConstraint? = nil
    
    @IBAction func plotTypeSelected(_ sender: Any) {
    }
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
        switch includeTextCheckbox.state {
        case .on:
            gridView.showHideCols(.show, index: [2])
        case .off:
            gridView.showHideCols(.hide, index: [2])
        default:
            print("Unknown state")
        }
    }

    override func createPlot()->TZPlot? {// TODO : expand for all plot types
        if let plotType = plotTypeDropDown.selectedItem?.title{
            let newPlot = TZPlot1line2d()
            newPlot.plotType = PlotType(rawValue: plotType)!
            //newPlot.var1 = variableSelectorViewController?.getSelectedItem()
            newPlot.setName()
            return newPlot
        }
        return nil
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Two Axis", comment: "") }
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
    }
    
    override func didDisclose() {//TODO : collapse grid columns (animated) when view is collapsed

        if disclosureState == .open {
            //gridView.isHidden = false
            gridView.showHideCols(.show, index: [0,1,2])
        } else {
            //gridView.isHidden = true
            gridView.showHideCols(.hide, index : [0,1,2])
        }
    }
}


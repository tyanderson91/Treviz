//
//  SettingStackViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class SingleAxisOutputSetupViewController: AddOutputViewController {

    @IBOutlet weak var plotTypeDropDown: NSPopUpButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    @IBOutlet weak var gridView: CollapsibleGridView!
    var conditions : [Condition] = []
    var variableSelectorViewController : VariableSelectorViewController?
    
    override func createPlot()->TZPlot? {// TODO : expand for all plot types
        if let plotType = plotTypeDropDown.selectedItem?.title{
            let newPlot = TZPlot1line2d()
            newPlot.plotType = PlotType(rawValue: plotType)!
            newPlot.var1 = variableSelectorViewController?.getSelectedItem()
            newPlot.setName()
            return newPlot
        }
        return nil
    }
    
    @IBAction func plotTypeSelected(_ sender: Any) {
    }
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
        switch includeTextCheckbox.state{
        case .on:
            print("on")
            gridView.showHideCols(.show, index: [2])
        case .off:
            print("off")
            gridView.showHideCols(.hide, index: [2])
        default:
            print("nada")
        }
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Single Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let asys = self.analysis {
            conditions = asys.conditions!
        }

        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        let var1ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        self.addChild(var1ViewController)
        gridView.cell(atColumnIndex: 0, rowIndex: 1).contentView = var1ViewController.view
        
        //let variableSelectorViewController = VariableSelectorViewController()
        //self.addChild(variableSelectorViewController)
        //gridView.cell(atColumnIndex: 0, rowIndex: 1).contentView = variableSelectorViewController.view
        //variableSelectorViewController.addVariables()
       // didDisclose()
    }
    
    override func didDisclose() {
        if disclosureState == .closed {
            gridView.showHideCols(.hide, index: [0,1,2])
        } else {
            gridView.showHideCols(.show, index: [0,1,2])
        }
    }
    
}

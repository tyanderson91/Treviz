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
    
    override func createPlot()->TZPlot? {// TODO : expand for all plot types
        var maxPlotID = self.outputSetupViewController.maxPlotNum
        
        guard let plotType = plotTypePopupButton.selectedItem?.title else {return nil}
        var var1 : Variable?
        if let var1Name = variableSelectorViewController?.variableSelectorPopup.selectedItem?.title {
            var1 = varList.first(where: { (thisVar:Variable) -> Bool in
                return thisVar.name == var1Name})//] Variable.getVar(fromName: var1Name, inputList: analysis.appDelegate!.initVars)
        } else {return nil}
        
        let newPlot = TZPlot(id: maxPlotID+1, vars: [var1!], plotType: PlotType.getPlotByName(plotType)!)
        maxPlotID += 1
        //newPlot.setName()
        return newPlot
        //return nil
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Single Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        variableSelectorViewController = (storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController)
        self.addChild(variableSelectorViewController)
        gridView.cell(atColumnIndex: 0, rowIndex: 1).contentView = variableSelectorViewController.view
        
        plotTypeSelector = { (thisPlotType : PlotType)->(Bool) in return thisPlotType.nAxis == 1 }
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

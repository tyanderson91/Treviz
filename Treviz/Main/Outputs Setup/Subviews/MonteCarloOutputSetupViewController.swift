//
//  MonteCarloOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/20/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class MonteCarloOutputSetupViewController: AddOutputViewController {
    
    var var1ViewController : VariableSelectorViewController!
    override func plotTypeSelector(_ plotType: TZPlotType)->(Bool){ return plotType.nAxis == 1 }

    @IBOutlet weak var gridView: CollapsibleGridView!
    
    override func getHeaderTitle() -> String { return NSLocalizedString("Monte-Carlo Run Statistics", comment: "") }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        var1ViewController = storyboard.instantiateController(identifier: "variableSelectorViewController") { aDecoder in VariableSelectorViewController(coder: aDecoder, analysis: self.analysis) }
        super.viewDidLoad()

        var1ViewController.selectedVariable = representedOutput.var1
        self.addChild(var1ViewController)
        gridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var1ViewController.view

    }

    override func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        return
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
        
}

//
//  MonteCarloOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/20/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class MonteCarloOutputSetupViewController: AddOutputViewController {
    
    
    @IBOutlet weak var gridView: CollapsibleGridView!
    var conditions : [Condition] = []
    
    @IBAction func addOutputClicked(_ sender: Any) {
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Monte-Carlo Run Statistics", comment: "") }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if let asys = analysis {
            conditions = asys.conditions!
        }

        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        let var1ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        self.addChild(var1ViewController)
        gridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var1ViewController.view

        didDisclose()
    }
    

    override func didDisclose() {
        if disclosureState == .closed {
            gridView.showHideCols(.hide, index: [0,1,2])
        } else {
            gridView.showHideCols(.show, index: [0,1,2])
        }
    }
        
}

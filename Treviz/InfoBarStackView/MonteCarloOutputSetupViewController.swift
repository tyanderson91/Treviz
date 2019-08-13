//
//  MonteCarloOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/20/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class MonteCarloOutputSetupViewController: BaseViewController {
    
    @IBAction func addOutputClicked(_ sender: Any) {
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Monte-Carlo Run Statistics", comment: "") }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        didDisclose()
    }
    
    /*
    override func didDisclose() {
        if disclosureState == .open {
            addButtonLeadingConstraint2.isActive = false
            addButtonLeadingConstraint1 = strongAddButtonLeadingConstraint1
            addButtonLeadingConstraint1.isActive = true
        } else {
            addButtonLeadingConstraint1.isActive = false
            addButtonLeadingConstraint2 = strongAddButtonLeadingConstraint2
            addButtonLeadingConstraint2.isActive = true
        }
    }*/
        
}

//
//  PhasedViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/30/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 A Phase View Controller is a view controller that displays an input setting dependent on the analysis phase. It contains a few functions and variables useful for displaying, updating, and passing around phase information
 */
class PhasedViewController: BaseViewController {

    var phase: TZPhase!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis, phase curPhase: TZPhase) {
        self.init(coder: coder, analysis: curAnalysis)
        phase = curPhase
    }
    
}

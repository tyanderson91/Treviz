//
//  AnalysisProgressReporter.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/23/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 This protocol is adapted by any object or struct that wants to report real-time progress of a running analysis. One example would be the owner of a progress bar. The primary functionality is to take the initial state, terminal condition, and current condition and estimate a percentage completion
 */
protocol AnalysisProgressReporter {
    func updateProgress(at currentState: StateArray)
    func startProgressTracking()
    func endProgressTracking()
    
    var initialState: StateArray { get }
    var terminalCondition: Condition { get set }
}

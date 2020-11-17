//
//  Output Handling Protocols.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/5/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**This protocol is adopted by any object or view that handles IO aspects of presenting text outputs*/
protocol TZTextOutputViewer {
    func clearOutput()
    func printOutput(curOutput: TZTextOutput) throws
}

/**This protocol is adopted by any object or view that handles IO aspects of presenting plots*/
protocol TZPlotOutputViewer {
    func clearPlots()
    func createPlot(plot: TZPlot) throws
}


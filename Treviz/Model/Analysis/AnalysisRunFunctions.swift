//
//  AnalysisRunFunctions.swift
//  Treviz
//
//  Contains all the code required to actually run an analysis, including the main run loop
//
//  Created by Tyler Anderson on 10/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension Analysis {
        
    func runAnalysis() {
        do {
            try createRunsFromVariants()
        } catch { logMessage(error.localizedDescription) }
        
        switch runMode {
        case .parallel:
            for thisRun in self.runs {
                analysisDispatchQueue.async {
                    thisRun.progressReporter = self.progressReporter
                    thisRun.run()
                }
            }
        case .serial:
            for thisRun in self.runs {
                thisRun.progressReporter = self.progressReporter
                thisRun.run()
            }
        }
    }
    
    /**
     Called by a run once it is finished running. This function takes care of processing the run and kicking off any new runs, or ending the analysis once all runs are complete
     */
    func processRun(_ run: TZRun) {
        let returnCodes = runs.compactMap({$0.returnCode})
        if returnCodes.allSatisfy({$0.rawValue > 0}){ // If all runs have been run
            self.progressReporter?.endProgressTracking()
            self.isRunning = false
            progressReporter?.completeAnalysis()
            processOutputs()
        }
    }
    
    func processOutputs() {
        self.textOutputViewer?.clearOutput()
        self.plotOutputViewer?.clearPlots()

        for curOutput in plots {
            do { try curOutput.assertValid() }
            catch {
                logMessage(error.localizedDescription)
                continue
            }
            curOutput.curTrajectory = varList // TODO: remove
            curOutput.runData = runs
            
            if curOutput is TZTextOutput {
                do {
                    try self.textOutputViewer?.printOutput(curOutput: curOutput as! TZTextOutput)
                } catch {
                    logMessage("Error in output set '\(curOutput.title)': \(error.localizedDescription)")
                }
            }
            else if curOutput is TZPlot {
                do {
                    try plotOutputViewer?.createPlot(plot: curOutput as! TZPlot)
                } catch {
                    logMessage("Error in plot '\(curOutput.title)': \(error.localizedDescription)")
                }
            }
        }
    }
}

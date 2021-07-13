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
        numComplete = 0
        createRunsFromVariants()
        guard !runs.isEmpty else {
            logMessage("No runs found to process. Aborting")
            return
        }
        
        runs.forEach {
            $0.runMode = self.runMode
            $0.progressReporter = self.progressReporter
        }
        self.isRunning = true
        switch runMode {
        case .parallel:
            for thisRun in self.runs {
                dispatchGroup.enter()
                analysisDispatchQueue.async {
                    if self.isRunning {
                        thisRun.run()
                        DispatchQueue.main.async {
                            self.numComplete += 1
                            self.progressReporter?.updateProgress(at: self.numComplete)
                        }
                    }
                    self.dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) { self.cleanupAllRuns() }
        case .serial:
            for thisRun in self.runs {
                thisRun.run()
                self.numComplete += 1
                self.progressReporter?.updateProgress(at: self.numComplete)
            }
            self.cleanupAllRuns()
        }
    }
    
    /**
     Called by a run once it is finished running. This function takes care of processing the run and kicking off any new runs, or ending the analysis once all runs are complete
     */
    /*
    func processRun(_ run: TZRun) {
        numComplete += 1
        progressReporter?.updateProgress(at: numComplete)
        logMessage("Run \(run.id) Complete, \(numComplete) of \(runs.count)")
        let returnCodes = runs.compactMap({$0.returnCode})
        /*if returnCodes.allSatisfy({$0.rawValue > 0}){ // If all runs have been run
            cleanupAllRuns()
        }*/
    }*/
    func cleanupAllRuns() {
        self.isRunning = false
        progressReporter?.endProgressTracking()
        progressReporter?.completeAnalysis()
        logMessage("Analysis Complete! Processing Outputs...")
        DispatchQueue.main.async {
            self.progressReporter?.changeType(indeterminate: true)
            self.processOutputs()
            self.showVisualization()
            self.logMessage("Done")
            self.progressReporter?.changeType(indeterminate: false)
        }
    }
    
    func processOutputs() {
        self.textOutputViewer?.clearOutput()
        self.plotOutputViewer?.clearPlots()

        for curOutput in plots {
            dispatchGroup.enter()
            DispatchQueue.main.async { [self] in
                do {
                    try curOutput.assertValid()
                    curOutput.curTrajectory = varList // TODO: remove
                    curOutput.runData = runs
                }
                catch {
                    logMessage(error.localizedDescription)
                }
                
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
                dispatchGroup.leave()
            }
        }
    }
    
    func showVisualization(){
        visualViewer?.loadTrajectoryData()
    }
}

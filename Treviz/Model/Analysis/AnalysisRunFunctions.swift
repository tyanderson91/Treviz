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
        let dxRunVariant = VariableRunVariant(param: phases[0].allParams.first(where: {$0.id == "default.dx"})!)!
        dxRunVariant.tradeValues = [3, 9, 33.6]
        dxRunVariant.variantType = .trade
        let dyRunVariant = VariableRunVariant(param: phases[0].allParams.first(where: {$0.id == "default.dy"})!)!
        dyRunVariant.tradeValues = [50, 30, 15]
        dyRunVariant.variantType = .trade
        let y0RunVariant = VariableRunVariant(param: phases[0].allParams.first(where: {$0.id == "default.y"})!)!
        y0RunVariant.min = 0
        y0RunVariant.max = 5
        y0RunVariant.variantType = .montecarlo
        y0RunVariant.distributionType = .uniform
        
        let x0RunVariant = VariableRunVariant(param: phases[0].allParams.first(where: {$0.id == "default.x"})!)!
        x0RunVariant.min = 0
        x0RunVariant.max = 5
        x0RunVariant.variantType = .montecarlo
        x0RunVariant.distributionType = .uniform
        self.numMonteCarloRuns = 3
        
        plots[2].categoryVar = dxRunVariant.parameter
        plots[2].plotType = .multiLine2d
        if plots.count == 5 { plots.remove(at: 3) }
        self.runVariants = [dxRunVariant, dyRunVariant, y0RunVariant, x0RunVariant]
        self.useGroupedVariants = true
        createRunsFromVariants()

        guard !runs.isEmpty else {
            logMessage("No runs found to process. Aborting")
            return
        }
        
        runs.forEach {
            $0.runMode = self.runMode
            $0.progressReporter = self.progressReporter
        }
        switch runMode {
        case .parallel:
            for thisRun in self.runs {
                analysisDispatchQueue.async {
                    thisRun.run()
                }
            }
        case .serial:
            for thisRun in self.runs {
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

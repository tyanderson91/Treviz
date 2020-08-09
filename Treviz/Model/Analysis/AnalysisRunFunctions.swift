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
        for thisPhase in self.phases {
            analysisDispatchQueue.async {
                thisPhase.progressReporter = self.progressReporter
                thisPhase.runAnalysis()
            }
        }
    }
    /**
     Called by a phase once it is finished running. This function takes care of processing the phase and kicking off any new phases, or ending the analysis once all phases are complete
     */
    func processPhase(_ phase: TZPhase) {
        var trajArray = phase.traj!
        if let calcVars = phase.varList.filter({phase.requestedVarIDs.contains($0.id.baseVarID())}) as? [StateCalcVariable] {
            for thisVar in calcVars {
                thisVar.calculate(from: &trajArray)
            }
        }
        
        let returnCodes = phases.compactMap({$0.returnCode})
        
        if returnCodes.allSatisfy({$0.rawValue > 0}){ // If all phases have been run
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
            curOutput.curTrajectory = varList
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

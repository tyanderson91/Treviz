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
        self.progressReporter?.completeAnalysis()
    }
}

//
//  TZRun.swift
//  Treviz
//
//  Created by Tyler Anderson on 12/12/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

enum TZRunError: Error {
    case MissingParamID
    case UnequalTradeGroupNumbers
}

class TZRun {
    let phases: [TZPhase]
    var parameters: [Parameter] {
        var tmpParam = [Parameter]()
        for thisPhase in phases {
            tmpParam.append(contentsOf: thisPhase.allParams)
        }
        return tmpParam
    }
    let seed: Double = 0.0
    var returnCode : ReturnCode = .NotStarted
    var analysis: Analysis!
    var runMode : AnalysisRunMode {
        get { return analysis.runMode }
        set { phases.forEach {$0.runMode = newValue} }
    }
    var progressReporter: AnalysisProgressReporter?
    var isRunning: Bool = false
    var trajData : [Variable]! {
        if phases.count == 1 {
            let onlyPhase = phases[0]
            var summaryVars = onlyPhase.varList.compactMap({$0.copyWithoutPhase()})
            summaryVars.append(contentsOf: onlyPhase.varList)
            return summaryVars
        } else { return nil }
    }
    
    var inputSettings : [Parameter] {
        var tempSettings = [Parameter]()
        for thisPhase in phases {
            tempSettings.append(contentsOf: thisPhase.allParams)
        }
        //return phases.compactMap({$0.allParams})
        return tempSettings
    }
    var runVariantSettings: [ParamID: String] = [:]
    var tradeGroupNum: Int = -1
    
    enum AnalysisCodingKeys: String, CodingKey {
        case phases
    }
    
    init(trajData: State) {
        let phase = TZPhase(id: "default")
        phase.traj = StateDictArray(from: trajData)
        phase.varList.updateFromDict(traj: phase.traj)
        self.phases = [phase]
    }
    
    convenience init(analysis: Analysis, paramSettings: [ParamID: String] = [:]) throws {
        let asysData = try analysis.copyForRuns()
        try self.init(analysisData: asysData, paramSettings: paramSettings)
    }
    init(analysisData: Data, paramSettings: [ParamID: String]) throws {
        let decoder = JSONDecoder()
        decoder.userInfo = [CodingUserInfoKey.simpleIOKey: false, CodingUserInfoKey.deepCopyKey: true]
        phases = try decoder.decode(Array<TZPhase>.self, from: analysisData)
        for (thisParamID, thisParamValue) in paramSettings {
            if let matchingParam = parameters.first(where: {$0.id == thisParamID}) {
                matchingParam.setValue(to: thisParamValue)
            } else { throw TZRunError.MissingParamID }
        }
        phases.forEach({$0.parentRun = self})
    }
    
    func run() {
        switch runMode {
        case .parallel:
            for thisPhase in self.phases {
                analysis.analysisDispatchQueue.async {
                    thisPhase.progressReporter = self.progressReporter
                    thisPhase.runAnalysis()
                }
            }
        case .serial:
            for thisPhase in self.phases {
                thisPhase.progressReporter = self.progressReporter
                thisPhase.runAnalysis()
            }
        }
    }
    /**
     Called by a phase once it is finished running. This function takes care of processing the phase and kicking off any new phases, or ending the run once all phases are complete
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
            self.returnCode = .Success
            self.progressReporter?.endProgressTracking()
            self.isRunning = false
            progressReporter?.completeAnalysis()
            self.analysis.processRun(self)
        }
    }
}

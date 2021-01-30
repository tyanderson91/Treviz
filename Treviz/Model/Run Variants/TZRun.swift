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
    let id: String
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
    var tradeGroupName: String = ""
    
    enum AnalysisCodingKeys: String, CodingKey {
        case phases
    }
    
    init(trajData: State) {
        id = ""
        let phase = TZPhase(id: "default")
        phase.traj = StateDictArray(from: trajData)
        phase.varList.updateFromDict(traj: phase.traj)
        self.phases = [phase]
    }
    
    convenience init(analysis: Analysis, paramSettings: [ParamID: String] = [:]) throws {
        let asysData = try analysis.copyForRuns()
        try self.init(analysisData: asysData, paramSettings: paramSettings)
    }
    init(analysisData: Data, paramSettings: [ParamID: String], id idIn: String = "") throws {
        id = idIn
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

// MARK: Analysis extension for creating runs
struct RunGenerator {
    let analysisData: Data
    var paramSettings: [ParamID: String]
    let mcVariants: [MCRunVariant]
    var curTradeGroupNum: Int
    var tradeGroupDescriptions: [String] = []
    var runID: String = ""
}

extension Analysis {
    var numRuns: Int {
        let mcRunVariants = runVariants.filter {$0.variantType == .montecarlo}
        let numMCRuns: Int = mcRunVariants.isEmpty ? 1 : numMonteCarloRuns
        return numTradeGroups * numMCRuns
    }
    
    func copyData(analysis: Analysis) throws->Data {
        let encoder = JSONEncoder()
        encoder.userInfo = [CodingUserInfoKey.simpleIOKey: false, CodingUserInfoKey.deepCopyKey: true]
        let data = try encoder.encode(analysis.phases)

        return data
    }
    
    func createRunsFromVariants() {
        var tradeVariants = runVariants.filter({$0.variantType == .trade})
        var mcVariants = runVariants.filter({$0.variantType == .montecarlo && $0 is MCRunVariant}) as! [MCRunVariant]
        
        do {
            self.runs = []
            let analysisData = try self.copyForRuns()
            if tradeVariants.count == 0 { tradeVariants = [DummyRunVariant]() }
            if mcVariants.count == 0 { mcVariants = [DummyRunVariant]() }
            var allRuns = [TZRun]()
            if self.tradeGroups.count != numTradeGroups {
                self.tradeGroups = Array<RunGroup>.init(repeating: RunGroup(), count: numTradeGroups)
            }
            
            let runGenerator = RunGenerator(analysisData: analysisData, paramSettings: [ParamID: String](), mcVariants: mcVariants, curTradeGroupNum: 0)
            
            if tradeVariants.isEmpty && mcVariants.isEmpty {
                allRuns = try [TZRun(analysisData: analysisData, paramSettings: [ParamID: String]() )]
            }
            else if tradeVariants.isEmpty { allRuns = createAllMCRuns(runGenerator: runGenerator) }
            else if self.useGroupedVariants {
                allRuns = try createTradeGroups(runGenerator: runGenerator, tradeVariants: tradeVariants)
            } else {
                allRuns = createTradePermutations(runGenerator: runGenerator, remainingVariants: tradeVariants)
            }
            allRuns.forEach {$0.analysis = self}
            self.runs = allRuns
        } catch {
            logMessage("Error creating runs: \(error.localizedDescription)")
        }
    }
    
    private func createTradeGroups(runGenerator inputRunGenerator : RunGenerator, tradeVariants: [RunVariant]) throws->[TZRun]{
        let numGroups = tradeVariants.first!.tradeValues.count
        guard tradeVariants.allSatisfy({$0.tradeValues.count == numGroups}) else { throw TZRunError.UnequalTradeGroupNumbers }
        var allRuns = [TZRun]()
        var runGenerator = inputRunGenerator
        for i in 0...numGroups-1 {
            runGenerator.tradeGroupDescriptions = []
            for thisVariant in tradeVariants {
                let paramID = thisVariant.paramID
                let paramVal = thisVariant.tradeValues[i]?.valuestr
                runGenerator.paramSettings[paramID] = paramVal ?? thisVariant.parameter.stringValue
                runGenerator.tradeGroupDescriptions.append("\(paramID)=\(paramVal ?? "?")")
            }
            runGenerator.curTradeGroupNum = i
            let curTradeGroup = self.tradeGroups[runGenerator.curTradeGroupNum]
            if curTradeGroup.groupDescription.isEmpty {
                self.tradeGroups[i].groupDescription = runGenerator.tradeGroupDescriptions.joined(separator: ", ")
            }
            runGenerator.runID = runGenerator.tradeGroupDescriptions.joined(separator: "_")
            let curGroupRuns = createAllMCRuns(runGenerator: runGenerator)
            self.tradeGroups[i].runs = curGroupRuns
            allRuns.append(contentsOf: curGroupRuns)
        }
        
        return allRuns
    }
    
    private func createTradePermutations(runGenerator inputRunGenerator: RunGenerator, remainingVariants: [RunVariant])->[TZRun]{
        var curRuns = [TZRun]()
        let curVariant = remainingVariants.first!
        let otherVariants = Array(remainingVariants.dropFirst())
        var runGenerator = inputRunGenerator
        let inputGroupDescriptions = inputRunGenerator.tradeGroupDescriptions
        for thisValue in curVariant.tradeValues {
            let paramID = curVariant.paramID
            let paramVal = thisValue?.valuestr ?? curVariant.parameter.stringValue
            runGenerator.paramSettings[paramID] = paramVal
            runGenerator.tradeGroupDescriptions = inputGroupDescriptions
            runGenerator.tradeGroupDescriptions.append("\(paramID)=\(paramVal)")
            var thisVariantRuns = [TZRun]()
            if otherVariants.isEmpty { // Reached the end of recursion
                let curTradeGroup = self.tradeGroups[runGenerator.curTradeGroupNum]
                if curTradeGroup.groupDescription.isEmpty {
                    self.tradeGroups[runGenerator.curTradeGroupNum].groupDescription = runGenerator.tradeGroupDescriptions.joined(separator: ", ")
                }
                runGenerator.runID = runGenerator.tradeGroupDescriptions.joined(separator: "_")

                thisVariantRuns = createAllMCRuns(runGenerator: runGenerator)
                self.tradeGroups[runGenerator.curTradeGroupNum].runs = thisVariantRuns
                runGenerator.curTradeGroupNum += 1
            } else { // continue recursion
                thisVariantRuns = createTradePermutations(runGenerator: runGenerator, remainingVariants: otherVariants)
                runGenerator.curTradeGroupNum = thisVariantRuns.last!.tradeGroupNum + 1
            }
            curRuns.append(contentsOf: thisVariantRuns)
        }
        return curRuns
    }
    
    private func createAllMCRuns(runGenerator inputRunGenerator: RunGenerator)->[TZRun]{
        guard inputRunGenerator.mcVariants.count > 0 && numMonteCarloRuns > 0 else { // Return a single run if there are no variations
            return [createMCRun(runGenerator: inputRunGenerator)]
        }
        var tmpMCRun = [TZRun]()
        var runGenerator = inputRunGenerator
        for i in 0...numMonteCarloRuns-1 {
            runGenerator = inputRunGenerator
            runGenerator.runID = "\(inputRunGenerator.runID)_mc\(i.valuestr)"
            let newSeed = Double.random(in: 0.0...1.0)
            let newRun = createMCRun(runGenerator: runGenerator, seed: newSeed)
            tmpMCRun.append(newRun)
        }
        return tmpMCRun
    }
    
    private func createMCRun(runGenerator: RunGenerator, seed: Double = 0.0)->TZRun {
        var paramSettings = runGenerator.paramSettings
        for thisVariant in runGenerator.mcVariants {
            let randomNum = thisVariant.randomValue(seed: seed)
            paramSettings[thisVariant.paramID] = randomNum.valuestr
        }
        let outputRun = try! TZRun(analysisData: runGenerator.analysisData, paramSettings: paramSettings, id: runGenerator.runID)
        outputRun.tradeGroupNum = runGenerator.curTradeGroupNum
        outputRun.tradeGroupName = self.tradeGroups[outputRun.tradeGroupNum].groupDescription
        
        return outputRun
    }
}


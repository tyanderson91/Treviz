//
//  AnalysisCreateRuns.swift
//  Treviz
//
//  Created by Tyler Anderson on 12/20/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

struct RunGenerator {
    let analysisData: Data
    var paramSettings: [ParamID: String]
    let mcVariants: [MCRunVariant]
    var curTradeGroupNum: Int
    var tradeGroupDescriptions: [String] = []
}

extension Analysis {

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
                self.tradeGroups = Array<TradeGroup>.init(repeating: TradeGroup(), count: numTradeGroups)
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
                let paramVal = thisVariant.tradeValues[i].valuestr
                runGenerator.paramSettings[paramID] = paramVal
                runGenerator.tradeGroupDescriptions.append("\(paramID)=\(paramVal)")
            }
            runGenerator.curTradeGroupNum = i
            let curTradeGroup = self.tradeGroups[runGenerator.curTradeGroupNum]
            if curTradeGroup.groupDescription.isEmpty {
                self.tradeGroups[i].groupDescription = runGenerator.tradeGroupDescriptions.joined(separator: ", ")
            }
            let curGroupRuns = createAllMCRuns(runGenerator: runGenerator)
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
            let paramVal = thisValue.valuestr
            runGenerator.paramSettings[paramID] = paramVal
            runGenerator.tradeGroupDescriptions = inputGroupDescriptions
            runGenerator.tradeGroupDescriptions.append("\(paramID)=\(paramVal)")
            var thisVariantRuns = [TZRun]()
            if otherVariants.isEmpty { // Reached the end of recursion
                let curTradeGroup = self.tradeGroups[runGenerator.curTradeGroupNum]
                if curTradeGroup.groupDescription.isEmpty {
                    self.tradeGroups[runGenerator.curTradeGroupNum].groupDescription = runGenerator.tradeGroupDescriptions.joined(separator: ", ")
                }
                thisVariantRuns = createAllMCRuns(runGenerator: runGenerator)
                runGenerator.curTradeGroupNum += 1
            } else { // continue recursion
                thisVariantRuns = createTradePermutations(runGenerator: runGenerator, remainingVariants: otherVariants)
                runGenerator.curTradeGroupNum = thisVariantRuns.last!.tradeGroupNum + 1
            }
            curRuns.append(contentsOf: thisVariantRuns)
        }
        return curRuns
    }
    
    private func createAllMCRuns(runGenerator: RunGenerator)->[TZRun]{
        guard runGenerator.mcVariants.count > 0 && numMonteCarloRuns > 0 else { // Return a single run if there are no variations
            return [createMCRun(runGenerator: runGenerator)]
        }
        var tmpMCRun = [TZRun]()
        for _ in 0...numMonteCarloRuns-1 {
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
        let outputRun = try! TZRun(analysisData: runGenerator.analysisData, paramSettings: paramSettings)
        outputRun.tradeGroupNum = runGenerator.curTradeGroupNum
        
        return outputRun
    }
}


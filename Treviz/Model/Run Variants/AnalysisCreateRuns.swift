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
}

extension Analysis {

    func copyData(analysis: Analysis) throws->Data {
        let encoder = JSONEncoder()
        encoder.userInfo = [CodingUserInfoKey.simpleIOKey: false, CodingUserInfoKey.deepCopyKey: true]
        let data = try encoder.encode(analysis.phases)

        return data
    }
    
    func createRunsFromVariants() throws {
        var tradeVariants = runVariants.filter({$0.variantType == .trade})
        var mcVariants = runVariants.filter({$0.variantType == .montecarlo && $0 is MCRunVariant}) as! [MCRunVariant]
        
        let analysisData = try self.copyForRuns()
        if tradeVariants.count == 0 { tradeVariants = [DummyRunVariant]() }
        if mcVariants.count == 0 { mcVariants = [DummyRunVariant]() }
        var allRuns = [TZRun]()
        let runGenerator = RunGenerator(analysisData: analysisData, paramSettings: [ParamID: String](), mcVariants: mcVariants)
        
        if tradeVariants.isEmpty && mcVariants.isEmpty {
            allRuns = try [TZRun(analysisData: analysisData, paramSettings: [ParamID: String]() )]
        }
        else if tradeVariants.isEmpty { allRuns = createAllMCRuns(runGenerator: runGenerator) }
        else if self.useGroupedVariants {
            allRuns = createTradeGroups(runGenerator: runGenerator, tradeVariants: tradeVariants)
        } else {
            allRuns = createTradePermutations(runGenerator: runGenerator, remainingVariants: tradeVariants)
        }
        
        allRuns.forEach {$0.analysis = self}
        self.runs = allRuns
    }
    
    func createTradeGroups(runGenerator: RunGenerator, tradeVariants: [RunVariant])->[TZRun]{
        let numGroups = tradeVariants.first!.tradeValues.count
        assert(tradeVariants.allSatisfy({$0.tradeValues.count == numGroups})) // Make sure all variants have the same number of variant values
        var allRuns = [TZRun]()
        var newRunGenerator = runGenerator
        for i in 0...numGroups {
            for thisVariant in tradeVariants {
                newRunGenerator.paramSettings[thisVariant.paramID] = thisVariant.tradeValues[i].valuestr
            }
            let curGroupRuns = createAllMCRuns(runGenerator: newRunGenerator)
            allRuns.append(contentsOf: curGroupRuns)
        }
        
        return allRuns
    }
    
    func createTradePermutations(runGenerator: RunGenerator, remainingVariants: [RunVariant])->[TZRun]{
        var curRuns = [TZRun]()
        let curVariant = remainingVariants.first!
        let otherVariants = Array(remainingVariants.dropFirst())
        var newRunGenerator = runGenerator
        for thisVariant in curVariant.tradeValues {
            newRunGenerator.paramSettings[curVariant.paramID] = thisVariant.valuestr
            let thisVariantRuns = createTradePermutations(runGenerator: newRunGenerator, remainingVariants: otherVariants)
            curRuns.append(contentsOf: thisVariantRuns)
        }
        return curRuns
    }
    
    func createAllMCRuns(runGenerator: RunGenerator)->[TZRun]{
        guard runGenerator.mcVariants.count > 0 else { // Return a single run if there are no variations
            return [createMCRun(runGenerator: runGenerator)]
        }
        var tmpMCRun = [TZRun]()
        for _ in 0...numMonteCarloRuns {
            let newSeed = Double.random(in: 0.0...1.0)
            let newRun = createMCRun(runGenerator: runGenerator, seed: newSeed)
            tmpMCRun.append(newRun)
        }
        return tmpMCRun
    }
    
    func createMCRun(runGenerator: RunGenerator, seed: Double = 0.0)->TZRun {
        var paramSettings = runGenerator.paramSettings
        for thisVariant in runGenerator.mcVariants {
            let randomNum = thisVariant.randomValue(seed: seed)
            paramSettings[thisVariant.paramID] = randomNum.valuestr
        }
        return try! TZRun(analysisData: runGenerator.analysisData, paramSettings: paramSettings)
    }
}


//
//  TZRunTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 12/24/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class TZRunTest: XCTestCase {
    
    var analysis = Analysis()
    
    func assertNumRuns(_ num: Int) {
        analysis.createRunsFromVariants()
        XCTAssertEqual(analysis.runs.count, num)
    }
    
    func testMakeRuns() throws {
        analysis = Analysis.initFromYaml(file: "TestAnalysis1", self: self)
        let curPhase = analysis.phases[0]
        analysis.createRunsFromVariants()
        XCTAssertEqual(analysis.runs.count, 1)
        
        let timestepVariant = SingleNumberRunVariant(param: curPhase.runSettings.defaultTimestep)!
        let tvariant = VariableRunVariant(param: curPhase.allParams.first(where: {$0.id.baseVarID() == "t"})! )!
        let xvariant = VariableRunVariant(param: curPhase.allParams.first(where: {$0.id.baseVarID() == "x"})! )!
        analysis.runVariants = [timestepVariant, tvariant, xvariant]
        assertNumRuns(1) // Adding single type variants does not increase the run count
        analysis.numMonteCarloRuns = 9
        assertNumRuns(1) // Adding mc runs does not matter if no variants are assigned as mc
        xvariant.variantType = .montecarlo
        assertNumRuns(9)
        timestepVariant.variantType = .trade
        tvariant.variantType = .trade
        timestepVariant.tradeValues = [0.1, 0.2, 0.3]
        tvariant.tradeValues = [0, 1, 2]
        analysis.useGroupedVariants = true
        assertNumRuns(9*3) // grouped trade groups times monte-carlos
        tvariant.tradeValues = [0, 1]
        assertNumRuns(0) // Fails to create runs if the group size are mis-matched
        analysis.useGroupedVariants = false
        assertNumRuns(2*3*9) // Permutations + MC
        analysis.numMonteCarloRuns = 1
        assertNumRuns(2*3*1)
        analysis.numMonteCarloRuns = 0
        assertNumRuns(2*3) // Just Permutations
    }
}

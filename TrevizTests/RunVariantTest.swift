//
//  RunVariantTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 12/24/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class RunVariantTest: XCTestCase {
    
    var analysis = Analysis()
    var timestepVariant:  SingleNumberRunVariant!
    var tvariant: VariableRunVariant!
    var xvariant: VariableRunVariant!
    var boolvariant: BoolRunVariant!
    var enumvariant: EnumGroupRunVariant!
    var testNum = NumberParam(id: "dt", name: "timestep", value: 0.1)
    
    func assertNumRuns(_ num: Int) {
        analysis.createRunsFromVariants()
        XCTAssertEqual(analysis.runs.count, num)
    }
    
    override func setUp() {
        analysis = Analysis.initFromYaml(file: "TestAnalysis1", self: self)
        let curPhase = analysis.phases[0]
        timestepVariant = SingleNumberRunVariant(param: curPhase.runSettings.defaultTimestep)!
        tvariant = VariableRunVariant(param: curPhase.allParams.first(where: {$0.id.baseVarID() == "t"})! )!
        xvariant = VariableRunVariant(param: curPhase.allParams.first(where: {$0.id.baseVarID() == "x"})! )!
        boolvariant = BoolRunVariant(param: curPhase.runSettings.useAdaptiveTimestep)
        enumvariant = EnumGroupRunVariant(param: curPhase.physicsSettings.centralBodyParam)
    }
    
    func testMakeRuns() throws {
        analysis.createRunsFromVariants()
        XCTAssertEqual(analysis.runs.count, 1)
        
        analysis.runVariants = [timestepVariant, tvariant, xvariant]
        analysis.runVariants.forEach({$0.isActive = true})
        assertNumRuns(1) // Adding single type variants does not increase the run count
        analysis.numMonteCarloRuns = 9
        assertNumRuns(1) // Adding mc runs does not matter if no variants are assigned as mc
        xvariant.variantType = .montecarlo
        xvariant.distributionType = .uniform
        xvariant.min = 0; xvariant.max = 10
        assertNumRuns(9)
        XCTAssert(analysis.numTradeGroups == 0)
        timestepVariant.variantType = .trade
        tvariant.variantType = .trade
        timestepVariant.tradeValues = [0.1, 0.2, 0.3]
        tvariant.tradeValues = [0, 1, 2]
        analysis.useGroupedVariants = true
        assertNumRuns(9*3) // grouped trade groups times monte-carlos
        XCTAssertEqual(3, analysis.numTradeGroups)
        tvariant.tradeValues = [0, 1]
        assertNumRuns(0) // Fails to create runs if the group size are mis-matched
        analysis.useGroupedVariants = false
        XCTAssertEqual(2*3, analysis.numTradeGroups)
        assertNumRuns(2*3*9) // Permutations + MC
        analysis.numMonteCarloRuns = 1
        assertNumRuns(2*3*1)
        analysis.numMonteCarloRuns = 0
        assertNumRuns(2*3) // Just Permutations
    }
    
    func testSetValue(){
        xvariant.setTradeValues(from: ["1.0","2.0"])
        xvariant.tradeValues = [1.0,2.0]
        boolvariant.setValue(from: "true")
        XCTAssertTrue(boolvariant.curValue as! Bool)
        enumvariant.setValue(from: "Mars")
        XCTAssertEqual((enumvariant.curValue as! CelestialBody).name, CelestialBody.mars.name)
        enumvariant.setValue(from: "notAPlanet")
        XCTAssertEqual((enumvariant.curValue as! CelestialBody).name, CelestialBody.mars.name)
    }
    
    func testMC() throws {
        let mcVar = SingleNumberRunVariant(param: testNum)!
        mcVar.min = 0.1; mcVar.max = 0.5
        mcVar.mean = 1.1; mcVar.sigma = 0.2
        mcVar.distributionType = .uniform
        var summary = "𝐔(0.1,0.5)"
        XCTAssertEqual(summary, mcVar.distributionSummary)
        mcVar.distributionType = .normal
        summary = "𝐍(1.1,0.2)"
        XCTAssertEqual(summary, mcVar.distributionSummary)
    }
    
    func testInit() {
        let analysis2 = Analysis.initFromYaml(file: "TestAnalysis2", self: self)
        let rv = analysis2.runVariants
        XCTAssertEqual(rv[0].curValue.valuestr, "Flat Surface, 3D")
        XCTAssertEqual(rv[1].curValue.valuestr, "0.1")
        XCTAssertEqual(rv[2].curValue.valuestr, "false")
        XCTAssertEqual(rv[3].curValue.valuestr, "2")
        
        let groupedAnalysis = Analysis.initFromYaml(file: "TestReadTradeGroups", self: self)
        let dxvar = groupedAnalysis.runVariants.first(where: {$0.paramID == "default.dx"})!
        let dyvar = groupedAnalysis.runVariants.first(where: {$0.paramID == "default.dy"})!
        XCTAssertTrue(dxvar.isActive)
        XCTAssertTrue(dyvar.isActive)
        XCTAssertEqual(dxvar.tradeValues as! [Double], [0,3,30]) // Fill with default values when not specified
        XCTAssertEqual(dyvar.tradeValues as! [Double], [1,20,4])
        let tParam = groupedAnalysis.inputSettings.first(where: {$0.id == "default.t"})!
        XCTAssertFalse(tParam.isParam)
    }
    
    func testSetParam() {
        let curPhase = analysis.phases[0]
        XCTAssert(analysis.runVariants.count == 0)
        analysis.setParam(param: curPhase.runSettings.defaultTimestep, setOn: true)
        XCTAssert(analysis.runVariants.count == 1)
        XCTAssertTrue(analysis.runVariants[0].isActive)
        XCTAssert(analysis.tradeRunVariants.count == 0)
        analysis.runVariants[0].variantType = .trade
        XCTAssert(analysis.tradeRunVariants.count == 1)
        analysis.setParam(param: curPhase.runSettings.defaultTimestep, setOn: false)
        XCTAssert(analysis.tradeRunVariants.count == 0)
        XCTAssert(analysis.runVariants.count == 1)
        XCTAssertFalse(analysis.runVariants[0].isActive)
        analysis.setParam(param: curPhase.runSettings.defaultTimestep, setOn: true)
        XCTAssertTrue(analysis.runVariants[0].isActive)
    }
}

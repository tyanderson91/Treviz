//
//  TestVariable.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 8/10/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class TestVariable: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: VarValue
    func testVarValueInit() {
        let float2 = Float(2)
        let dub2 = Double(2)
        let int2 = Int(2)
        XCTAssertEqual(dub2, VarValue(numeric: float2))
        XCTAssertEqual(dub2, VarValue(numeric: dub2))
        XCTAssertEqual(dub2, VarValue(numeric: int2))
    }
    
    // MARK: VariableID
    func testPhasename() {
        let varID = ParamID("phase1.varid")
        XCTAssert(varID.phasename() == "phase1")
        let varid2 = ParamID("varid")
        XCTAssertEqual(varid2.phasename(), "")
    }
    func testAtPhase() {
        let varID = ParamID("varid")
        let phase = "phase1"
        XCTAssertEqual(varID.atPhase(phase), "phase1.varid")
    }

    // MARK: Variable
    func testSubscript() {
        let timeVar = Variable("t", named: "time", symbol: "t", units: "s")
        timeVar.value = [0,1,2]
        XCTAssert(timeVar[1] == 1)
        XCTAssertNil(timeVar[4])
        XCTAssertNil(timeVar[-1])
        timeVar[2] = 2.5
        XCTAssert(timeVar[2] == 2.5)
    }
    
    func testPhaseFuncs() {
        let timeVar = Variable("t", named: "time", symbol: "t", units: "s")
        let timeVar2 = timeVar.copyToPhase(phaseid: "phase1")
        XCTAssert(timeVar2.id == "phase1.t")
        let timeVar3 = timeVar2.copyToPhase(phaseid: "phase2")
        XCTAssert(timeVar3.id == "phase2.t")
        let timeVar4 = timeVar3.stripPhase()
        XCTAssert(timeVar4.id == "t")
        let timeVar5 = timeVar4.stripPhase()
        XCTAssertEqual(timeVar4, timeVar5)
        
        let calcVar = StateCalcVariable("calcVar", calculation: {_ in return VarValue()})
        let calcVar2 = calcVar.copyToPhase(phaseid: "phase1")
        XCTAssert(calcVar2.id == "phase1.calcVar")
        let calcVar3 = calcVar2.copyToPhase(phaseid: "phase2")
        XCTAssert(calcVar3.id == "phase2.calcVar")
        let calcVar4 = calcVar3.stripPhase()
        XCTAssert(calcVar4.id == "calcVar")
        let calcVar5 = calcVar4.stripPhase()
        XCTAssertEqual(calcVar4, calcVar5)
    }
    
    // MARK: Calculated Variable
    let singleCalc: (inout StateDictSingle)->VarValue = { (statedict: inout StateDictSingle) in
        return statedict["t"]! + statedict["x"]! + statedict["y"]!
    }
    let multiCalc: (inout StateDictArray)->[VarValue] = { (stateArray: inout StateDictArray) in
        var valOut: [VarValue] = Array(repeating: 0.0, count: stateArray.stateLen)
        for i in 0...stateArray.stateLen - 1 {
            valOut[i] = stateArray["t",i]! * VarValue(i+1)
        }
        return valOut
    }

    func testCalculate() {
        let t = Variable("t"); t.value = [1, 2, 3]
        let x = Variable("x"); x.value = [4, 5, 6]
        let y = Variable("y"); y.value = [7, 8, 9]
        let calcVar1 = StateCalcVariable("var1", calculation: singleCalc)
        let calcVar2 = StateCalcVariable("var2", calculation: multiCalc)
        let state = State(arrayLiteral: t, x, y)
        var stateIn = StateDictArray(from: state)
        
        calcVar1.calculate(from: &stateIn)
        XCTAssert(calcVar1.value == [12, 15, 18])
        
        calcVar2.calculate(from: &stateIn)
        XCTAssert(calcVar2.value == [1, 4, 9])
    }
    
    // MARK: Aggregate Variable
    func testAggregateVarCalc() {
        let phase1 = TZPhase(id: "phase1")
        let phase2 = TZPhase(id: "phase2")
        let t1 = Variable("phase1.t"); t1.value = [1, 2, 3]
        let x1 = Variable("phase1.x"); x1.value = [4, 5, 6]
        let t2 = Variable("phase2.t"); t2.value = [7, 8, 9]
        let x2 = Variable("phase2.x"); x2.value = [10, 11, 12]
        phase1.varList = [t1, x1]
        phase2.varList = [t2, x2]
        let tAggVar = AggregateCalcVariable("t")
        let xAggVar = AggregateCalcVariable("x")
        tAggVar.calculate(from: [phase1, phase2])
        xAggVar.calculate(from: [phase1, phase2])
        XCTAssert(tAggVar.value == [1,2,3,7,8,9])
        XCTAssert(xAggVar.value == [4,5,6,10,11,12])
    }
}

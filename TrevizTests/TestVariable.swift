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
        XCTAssertEqual(float2, VarValue(numeric: float2))
        XCTAssertEqual(float2, VarValue(numeric: dub2))
        XCTAssertEqual(float2, VarValue(numeric: int2))
    }
    
    // MARK: VariableID
    func testPhasename() {
        let varID = VariableID("phase1.varid")
        XCTAssert(varID.phasename() == "phase1")
        let varid2 = VariableID("varid")
        XCTAssertEqual(varid2.phasename(), "")
    }
    func testAtPhase() {
        let varID = VariableID("varid")
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
        let phasedvar = timeVar.copyToPhase(phaseid: "phase1")
        XCTAssertNotEqual(timeVar, phasedvar)
        XCTAssert(phasedvar.id == "phase1.t")
        let timeVar2 = phasedvar.stripPhase()
        XCTAssertEqual(timeVar, timeVar2)
        let timeVar3 = timeVar2.stripPhase()
        XCTAssertEqual(timeVar2, timeVar3)
    }
}

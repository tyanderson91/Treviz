//
//  CalcsTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 7/16/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class CalcsTest: XCTestCase {

    let testPhase = TZPhase(id: "Test")
    override func setUpWithError() throws {
        testPhase.loadVarCalculations()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVelocity() throws {
        let velCalc = testPhase.varCalculationsSingle["v"]!
        var stateIn: StateDictSingle = ["dx": 1.0, "dy": 2.0, "dz": 3.0]
        let velOut = velCalc(&stateIn)
        XCTAssert(velOut == 14**0.5)
    }
    func testAccel() throws {
        let accelCalc = testPhase.varCalculationsMultiple["a"]!
        var stateIn: StateDictArray = ["dx": [1,2,4], "dy": [0,0,0], "dz": [0,0,0], "t": [0,1,2]]
        stateIn.phase = testPhase
        let accelOut = accelCalc(&stateIn)
        XCTAssert(accelOut == [1,1,2])  // First index copies the second
    }

}

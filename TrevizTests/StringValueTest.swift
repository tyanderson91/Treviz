//
//  StringValueTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 12/24/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class StringValueTest: XCTestCase {

    func testInit() throws {
        var testString: String = "test"
        let newStr = String(from: testString)
        XCTAssert(newStr.valuestr == "test")
        
        testString = "1"
        let newInt = Int(stringLiteral: testString)!
        XCTAssertEqual(newInt.valuestr, "1")
        var newVal = VarValue(stringLiteral: testString)!
        XCTAssertEqual(newVal.valuestr, "1")
        
        testString = "1.0"
        newVal = VarValue(stringLiteral: testString)!
        XCTAssertEqual(newVal, 1.0)
        XCTAssertEqual(newVal.valuestr, "1")
        testString = "1.1"
        newVal = VarValue(stringLiteral: testString)!
        XCTAssertEqual(newVal, 1.1)
        XCTAssertEqual(newVal.valuestr, "1.1")
        
        testString = "True"
        var newBool = Bool(stringLiteral: testString)!
        XCTAssertTrue(newBool)
        XCTAssertEqual(newBool.valuestr, "true")
        testString = "False"
        newBool = Bool(stringLiteral: testString)!
        XCTAssertFalse(newBool)
        XCTAssertEqual(newBool.valuestr, "false")
        testString = "On"
        newBool = Bool(stringLiteral: testString)!
        XCTAssertTrue(newBool)
        testString = "Off"
        newBool = Bool(stringLiteral: testString)!
        XCTAssertFalse(newBool)
        
        testString = "Flat Surface, planar"
        var newPhys = PhysicsModel(stringLiteral: testString)
        XCTAssert(newPhys! == .flat2d)
        testString = "fake model"
        newPhys = PhysicsModel(stringLiteral: testString)
        XCTAssertNil(newPhys)
        
    }

}

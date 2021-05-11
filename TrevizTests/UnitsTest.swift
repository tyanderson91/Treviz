//
//  UnitsTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 5/7/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class UnitsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConversions() throws {
        let C = UnitTemperature.celsius
        let F = UnitTemperature.fahrenheit
        let cvals: [VarValue] = [0,20,100]
        let fvals: [VarValue] = [32,68,212]
        
        let freezing = C.convertToBase(val: 0)
        XCTAssertEqual(freezing, 273.15)
        let ffreezing = C.convert(to: F, val: 0)
        XCTAssertEqual(ffreezing, 32.0, accuracy: 0.0001)
        let fval_converted: [VarValue] = C.convert(to: F, vals: cvals)
        let cval_converted: [VarValue] = F.convert(to: C, vals: fvals)
        for i in 0...2 {
            XCTAssertEqual(fvals[i], fval_converted[i], accuracy: 0.0001)
            XCTAssertEqual(cvals[i], cval_converted[i], accuracy: 0.0001)
        }
        
        let m = UnitLength.meters
        let km = UnitLength.kilometers
        let fnum = m.convert(to: UnitLength.feet, val: 1.0)
        XCTAssertEqual(UnitLength.feet.convertToBase(val: fnum), 1.0, accuracy: 0.0001)
        XCTAssertEqual(1000, km.convert(to: m, val: 1))
        XCTAssertEqual(km.convertToBase(val: 1), m.convertToBase(val: 1000))
        //XCTAssertEqual(fval_converted, fvals, accuracy: 0.0001)
        //XCTAssertEqual(cval_converted, cvals, accuracy: 0.0001)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

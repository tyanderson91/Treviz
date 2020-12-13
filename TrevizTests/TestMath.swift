//
//  TestMath.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 12/5/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation
import XCTest
@testable import TrajectoryAnalysis

class MathTestCase: XCTestCase {
    func testAngleFuncs() throws {
        let acc = 0.000001
        XCTAssertEqual(wrapAngle(270), -90, accuracy: acc)
        XCTAssertEqual(wrapAngle(-270), 90, accuracy: acc)
        XCTAssertEqual(wrapAngle(3*PI/2, isRadian: true), -PI/2, accuracy: acc)
        XCTAssertEqual(wrapAngle(-3*PI/2, isRadian: true), PI/2, accuracy: acc)
        
        XCTAssertEqual(deg2rad(180), PI, accuracy: acc)
        XCTAssertEqual(deg2rad(270), -PI/2, accuracy: acc)
        XCTAssertEqual(deg2rad(270, wrap: false), 3*PI/2, accuracy: acc)
        XCTAssertEqual(deg2rad(-90), -PI/2, accuracy: acc)
        XCTAssertEqual(deg2rad(-270), PI/2, accuracy: acc)
        
        XCTAssertEqual(rad2deg(PI), 180, accuracy: acc)
        XCTAssertEqual(rad2deg(3*PI/2), -90, accuracy: acc)
        XCTAssertEqual(rad2deg(3*PI/2, wrap: false), 270, accuracy: acc)
        XCTAssertEqual(rad2deg(-PI/2), -90, accuracy: acc)
        XCTAssertEqual(rad2deg(-3*PI/2), 90, accuracy: acc)
    }
}

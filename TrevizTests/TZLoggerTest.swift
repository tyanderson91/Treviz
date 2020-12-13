//
//  TZLoggerTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 12/6/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class TestLogger : TZLogger {    
    var text: String = ""
    func logMessage(_ message: NSAttributedString) {
        text = message.string
    }
}

class TZLoggerTest: XCTestCase {
    
    let testLogger = TestLogger()

    func testExample() throws {
        let testStr : String = "This is a test"
        let testAttrStr = NSAttributedString(string: "This is an attributed string", attributes: [NSAttributedString.Key.strokeColor: NSColor.black])
        testLogger.logMessage(testStr)
        XCTAssertEqual(testStr, testLogger.text)
        testLogger.logMessage(testAttrStr)
        XCTAssertEqual(testAttrStr.string, testLogger.text)
    }

}

//
//  PlotComponentsTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 5/10/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class ColorMapTest: XCTestCase {

    func testSubscript() throws {
        // Variable
        let cmap = ColorMap(name: "test", colors: [.red,.green,.blue])
        XCTAssertEqual(cmap[0], CGColor.red)
        XCTAssertEqual(cmap[2], CGColor.blue)
        XCTAssertEqual(cmap[3, 2], CGColor.red) // one more than the total number, loops to the beginning
        XCTAssertEqual(cmap[4, 2], CGColor.green)
        
        let continuousColors: [[CGFloat]] = [
            [0,0,0],[0.5,0.5,0.5],[1,1,1]
        ]
        let contCmap = ColorMap(name: "test2", isContinuous: true, rgbComponents: continuousColors)
        XCTAssertEqual(contCmap[0.5], CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
        let contCmap2 = ColorMap(name: "test2", isContinuous: true, rgbComponents: [[1,0,0],[0,1,0],[0,0,1]])
        XCTAssertEqual(contCmap2[0.25], CGColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1.0))
    }
    

}

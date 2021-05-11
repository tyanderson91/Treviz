//
//  PlotTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 8/16/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class PlotTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSymbolSet() throws {
        let ss = SymbolSet([TZPlotSymbol.circle, TZPlotSymbol.diamond, TZPlotSymbol.hexagon])
        let A = ss[0]
        XCTAssertEqual(A, TZPlotSymbol.circle)
        XCTAssertEqual(A.character(), "●")
        XCTAssertEqual(ss[at: 2], TZPlotSymbol.hexagon)
        XCTAssertEqual(ss[at: 3], TZPlotSymbol.circle)
    }

}

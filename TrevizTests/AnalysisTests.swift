//
//  AnalysisTests.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 8/16/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis
/**
 This suite of tests provides an end-to-end verification of accuracy of tests for various types of analyses
 */
class AnalysisTests: XCTestCase {
    
    func loadFromYaml(file: String)->Analysis{
        do {
            let bundle = Bundle(for: type(of: self))
            let filePath = bundle.url(forResource: file, withExtension: "yaml")!
            let data = try Data(contentsOf: filePath)
            return Analysis(fromYaml: data)
        } catch {XCTFail()}
        return Analysis()
    }
    
    var analysis_2d = Analysis()
    override func setUpWithError() throws {
        analysis_2d = loadFromYaml(file: "TestAnalysis1")
        analysis_2d.runMode = .serial
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        try analysis_2d.phases[0].runSettings.setDefaultTimeStep(0.01)
        analysis_2d.runAnalysis()

        let dy_init = analysis_2d.initState["dy"]!
        let maxheight = (dy_init**2) / (2*9.81)
        let apogeeOutput = analysis_2d.plots.first(where: {$0.title == "Apogee height"})!
        let dataSet = try apogeeOutput.getData()
        guard let calcApogee = dataSet?.var1![0] else { XCTFail(); return}
        XCTAssertEqual(calcApogee, maxheight, accuracy: 1.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        let phase = analysis_2d.phases[0]
        try phase.runSettings.setDefaultTimeStep(0.001)
        self.measure {
            analysis_2d.runAnalysis()
            // Put the code you want to measure the time of here.
        }
    }

}

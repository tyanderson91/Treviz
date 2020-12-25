//
//  AnalysisTests.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 8/16/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
import Yams
@testable import TrajectoryAnalysis
/**
 This suite of tests provides an end-to-end verification of accuracy of tests for various types of analyses
 */
class AnalysisTests: XCTestCase {
    /*
    func loadFromYaml(file: String)->Analysis{
        do {
            let bundle = Bundle(for: type(of: self))
            let filePath = bundle.url(forResource: file, withExtension: "yaml")!
            let data = try Data(contentsOf: filePath)
            let decoder = Yams.YAMLDecoder(encoding: .utf8)
            let userOptions : [CodingUserInfoKey : Any] = [.simpleIOKey: true]
            if let stryaml = String(data: data, encoding: String.Encoding.utf8) {
                let analysis = try decoder.decode(Analysis.self, from: stryaml, userInfo: userOptions)
                return analysis
            }
        } catch {XCTFail()}
        return Analysis()
    }*/
    
    var analysis_2d = Analysis()
    override func setUpWithError() throws {
        analysis_2d = Analysis.initFromYaml(file: "TestAnalysis1", self: self)
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
        apogeeOutput.runData = analysis_2d.runs
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

    func testReadJSON() throws {
        do {
            let bundle = Bundle(for: type(of: self))
            let filePath = bundle.url(forResource: "TestAnalysis1", withExtension: "json")!
            let analysisData = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let analysis = try decoder.decode(Analysis.self, from: analysisData)
            XCTAssertNotNil(analysis)
        } catch { XCTFail() }
    }
    
    func testReadWrite() throws {
        let bundle = Bundle(for: type(of: self))
        let filePath = bundle.url(forResource: "TestAnalysis3", withExtension: "yaml")!
        let dataIn = try Data(contentsOf: filePath)
        let decoder = Yams.YAMLDecoder(encoding: .utf8)
        let userOptions : [CodingUserInfoKey : Any] = [.simpleIOKey: true]
        guard let strYamlIn = String(data: dataIn, encoding: String.Encoding.utf8) else { XCTFail(); return }
        let analysis = try decoder.decode(Analysis.self, from: strYamlIn, userInfo: userOptions)
        let encoder = Yams.YAMLEncoder()
        let strYamlOut = try encoder.encode(analysis, userInfo: userOptions)
        XCTAssertEqual(strYamlIn, strYamlOut)
        let dataOut = strYamlOut.data(using: .utf8)
        XCTAssertEqual(dataIn, dataOut)
    }
    
    func testGetParameters() throws {
        let analysis = Analysis.initFromYaml(file: "TestAnalysis2", self: self)
        XCTAssertTrue(analysis.inputSettings.contains(where: {$0.id == "default.x"}))
        XCTAssertTrue(analysis.parameters.contains(where: {$0.id == "default.physicsModel"}))
        XCTAssertFalse(analysis.parameters.contains(where: {$0.id == "default.x"}))
    }
    
    func testIsValid() throws {
        let analysis = Analysis.initFromYaml(file: "TestAnalysis1", self: self)
        XCTAssertNoThrow(try analysis.isValid())
        let phase = analysis.phases[0]
        phase.terminalCondition = nil
        XCTAssertThrowsError(try analysis.isValid())
    }
}

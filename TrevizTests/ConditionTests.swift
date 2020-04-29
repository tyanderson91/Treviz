//
//  ConditionTests.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 11/19/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import XCTest
import TrajectoryAnalysis
import Yams

class ConditionsTest: XCTestCase {
    
    var yamlDict: [String: Any]?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        var yamlObj: Any?
        do {
            //let curURL = URL(fileReferenceLiteralResourceName: "AnalysisSettings.yaml")
            let curURL = URL(fileURLWithPath: "/Users/TylerAnderson/Coding/Swift/Treviz/Examples/AnalysisSettings.yaml")
            //let data = try Data(
            let data = try Data(contentsOf: curURL)
            let stryaml = String(data: data, encoding: String.Encoding.utf8)
            yamlObj = try Yams.load(yaml: stryaml!)
        } catch {
            return yamlDict = nil
        }
        yamlDict = yamlObj as? [String: Any]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testConditionRead() {
        var readConditions = [Condition]()
        if let conditionList = yamlDict!["Conditions"] as? [[String: Any]] {
            // self.conditions = []
            for thisConditionDict in conditionList {
                if let newCond = Condition(fromYaml: thisConditionDict, inputConditions: readConditions) {
                    //initCondition(fromYaml: thisConditionDict) {
                    readConditions.append(newCond)
                } // TODO: else print error
            }
        }
        let groundImpact = readConditions[0]
        let terminalTest = readConditions[3]
        let nestedCondition = readConditions[4]
        XCTAssert(readConditions.count == 6)
        XCTAssert(groundImpact.name == "Ground Impact")
        XCTAssertTrue(nestedCondition.containsCondition(groundImpact))
        XCTAssertTrue(nestedCondition.containsCondition(groundImpact))
        XCTAssertFalse(nestedCondition.containsCondition(nestedCondition))
        XCTAssertTrue(nestedCondition.containsCondition(terminalTest))
    }
    
    /**
     TODO: use other variables like Z which are out-of-place in the lineup
     */
    func testMeetsCondition() { // TODO: replace with real state trajectory read from external file
        let t = Variable("t", named: "time", symbol: "t", units: "s")
        t.value = (0...9).map { VarValue($0) }
        let x = Variable("x", named: "X Position", symbol: "x", units: "m")
        x.value = (0...9).map { 2*VarValue($0) }
        let y = Variable("y", named: "Y Position", symbol:"y", units: "m")
        y.value = [0, 4, 7, 10, 8, 5, -2, -5, -4, -3]
        let state = State(variables: [t, x, y])
        let cond1 = Condition("y", upperBound: 9, lowerBound: 6)
        let cond2 = Condition("y", equality: -1)
        let cond3 = Condition("y", specialCondition: .localMax)
        let cond4 = Condition("y", specialCondition: .globalMin)
        
        XCTAssertEqual(state["t", cond1], [2, 4])
        XCTAssertEqual(state[["x"], cond2]?["x"], [12])
        XCTAssertEqual(state[y, cond3], [10])
        XCTAssertEqual(state["y", cond4], [-5])
        XCTAssertEqual(state["t", cond1], state[["y", "x", "t"], cond1]?["t"])
    }
}

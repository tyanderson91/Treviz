//
//  ConditionTests.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 11/19/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import XCTest

class ConditionsTest: XCTestCase {
    
    let yamlDict: [String: Any] = getYamlObject(from: "AnalysisSettings") as! [String : Any]

    func testCondition() {
        var readConditions = [Condition]()
        if let conditionList = yamlDict["Conditions"] as? [[String: Any]] {
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
        XCTAssert(readConditions.count == 5)
        XCTAssert(groundImpact.name == "Ground Impact")
        XCTAssertTrue(nestedCondition.containsCondition(groundImpact))
        XCTAssertTrue(nestedCondition.containsCondition(groundImpact))
        XCTAssertFalse(nestedCondition.containsCondition(nestedCondition))
        XCTAssertTrue(nestedCondition.containsCondition(terminalTest))
        let coder = NSCoder()
        nestedCondition.encode(with: coder)
        let decoded = Condition.init(coder: coder)
        XCTAssertEqual(nestedCondition, decoded)
    }
}

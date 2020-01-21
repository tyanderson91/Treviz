//
//  ConditionTests.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 11/19/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Foundation
import XCTest

func conditionTest(yamlDict: [String: Any]) { //TODO: Add more test cases here
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
    XCTAssertTrue(nestedCondition.containsCondition(nestedCondition))
    XCTAssertTrue(nestedCondition.containsCondition(terminalTest))
    
}

//
//  ConditionTests.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 11/19/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import XCTest
@testable import TrajectoryAnalysis
import Yams

class ConditionsTest: XCTestCase {
    
    var yamlDict: [String: Any]?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: Condition tests
    
    /**
     This test should ensure that two different encodings of the same data, JSON and YAML, are both able to be read and produce identical results
     */
    func testConditionIO() {
        // Yaml
        var yamlObj: Any?
        do {
            let bundle = Bundle(for: type(of: self))
            let filePath = bundle.url(forResource: "TestAnalysis1", withExtension: "yaml")!
            let data = try Data(contentsOf: filePath)
            let stryaml = String(data: data, encoding: String.Encoding.utf8)
            yamlObj = try Yams.load(yaml: stryaml!)
        } catch { XCTFail() }
        yamlDict = yamlObj as? [String: Any]
        
        var yamlConditions = [Condition]()
        if let conditionList = yamlDict!["Conditions"] as? [[String: Any]] {
            // self.conditions = []
            for thisConditionDict in conditionList {
                if let newCond = Condition(fromYaml: thisConditionDict, inputConditions: yamlConditions) {
                    //initCondition(fromYaml: thisConditionDict) {
                    yamlConditions.append(newCond)
                }
            }
        }
        
        // Codable JSON
        
        //Writing
        var dataOut = Data()
        let encoder = JSONEncoder()
        do {
            let encoder = JSONEncoder()
            dataOut = try encoder.encode(yamlConditions)
        } catch { XCTFail() }
        
        // Reading
        var codableConditions = [Condition]()
        var dataIn = Data()
        do {
            let bundle = Bundle(for: type(of: self))
            let filePath = bundle.url(forResource: "TestAnalysis1", withExtension: "json")!
            let analysisData = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let analysis = try decoder.decode(Analysis.self, from: analysisData)
            codableConditions = analysis.conditions
            dataIn = try encoder.encode(codableConditions)
        } catch { XCTFail() }
        
        XCTAssertEqual(dataOut, dataIn) // Make sure what is written from the YAML data and what is read from the JSON data are equal
        for readConditions in [yamlConditions, codableConditions] {
            let groundImpact = readConditions[0]
            let terminalTest = readConditions[3]
            let nestedCondition = readConditions[4]
            XCTAssert(readConditions.count == 7)
            XCTAssert(groundImpact.name == "Ground Impact")
            XCTAssertTrue(nestedCondition.containsCondition(groundImpact))
            XCTAssertFalse(nestedCondition.containsCondition(nestedCondition))
            XCTAssertTrue(nestedCondition.containsCondition(terminalTest))
        }
    }
    
    func testResetType() {
        let singleCond = SingleCondition("t")
        singleCond.ubound = 1
        singleCond.lbound = 2
        XCTAssert(singleCond.ubound == 1)
        singleCond.equality = 3
        XCTAssertNil(singleCond.ubound)
        XCTAssertNil(singleCond.lbound)
        singleCond.specialCondition = .localMax
        XCTAssertNil(singleCond.equality)
        singleCond.lbound = 4
        XCTAssertNil(singleCond.specialCondition)
    }
    func testSummary() {
        let cond1 = SingleCondition("t")
        cond1.ubound = 1
        XCTAssertEqual(cond1.summary, "t < 1")
        cond1.lbound = 0.1
        XCTAssertEqual(cond1.summary, "0.1 < t < 1")
        cond1.ubound = nil
        XCTAssertEqual(cond1.summary, "t > 0.1")
        cond1.equality = -3
        XCTAssertEqual(cond1.summary, "t = -3")
        cond1.specialCondition = .globalMax
        XCTAssertEqual(cond1.summary, "Global Max t")
        cond1.specialCondition = .localMin
        XCTAssertEqual(cond1.summary, "Local Min t")
        let cond2 = SingleCondition("x", upperBound: 4)
        let cond3 = Condition(conditions: [cond1, cond2], unionType: .or, name: "")
        XCTAssertEqual(cond3.summary, "Local Min t or x < 4")
        let cond4 = SingleCondition("y", equality: 5.43)
        let cond5 = Condition(conditions: [cond3, cond4], unionType: .xnor, name: "")
        XCTAssertEqual(cond5.summary, "(Local Min t or x < 4) xnor y = 5.43")
    }
    
    func testMeetsSingleCondition() {
        let t = Variable("t", named: "time", symbol: "t", units: "s")
        t.value = (0...9).map { VarValue($0) }
        let x = Variable("x", named: "X Position", symbol: "x", units: "m")
        x.value = (0...9).map { 2*VarValue($0) }
        let y = Variable("y", named: "Y Position", symbol:"y", units: "m")
        y.value = [0, 4, 7, 10, 8, 5, -2, -5, -4, 1]
        //Test State functions
        let state = State([t, x, y])
        let cond1 = Condition("y", upperBound: 9, lowerBound: 6)
        cond1.name = "Interval"
        XCTAssert(cond1.isValid())
        let cond2 = Condition("y", equality: -1)
        cond2.name = "Equality"
        XCTAssert(cond2.isValid())
        let cond3 = Condition("y", specialCondition: .localMax)
        cond3.name = "Local"
        XCTAssert(cond3.isValid())
        let cond4 = Condition("y", specialCondition: .globalMin)
        cond4.name = "Global"
        XCTAssert(cond4.isValid())
        
        XCTAssertEqual(state["t", cond1], [2, 4])
        XCTAssertEqual(state[["x"], cond2]?["x"], [12, 18])
        //XCTAssertEqual(state[y, cond3], [10])
        XCTAssertEqual(state["y", cond4], [-5])
        XCTAssertEqual(state["t", cond1], state[["y", "x", "t"], cond1]?["t"])
        
        XCTAssert(cond4.containsGlobalCondition())
        
        let stateArray = StateDictArray(from: state)
        // Test reset
        cond3.reset(initialState: stateArray[0])
        XCTAssertNil(cond3.meetsCondition)
        cond2.reset()
        //Test Evaluate Single
        // When evaluateng states sequentially (such as when simulating a trajectory in real time), you don't know you hit a local max until one step after truly hitting it. Thus, 8 will be marked as a local max rather than 10.
        let maxindex = y.value.firstIndex(of: y.value.max()!)! + 1
        
        for i in 0...stateArray.stateLen-1 {
            let curState = stateArray[i]
            let cury = curState["y"]!
            let isLocalMax = try! cond3.evaluateSingleState(curState)
            let isInterval = try! cond1.evaluateSingleState(curState)
            var isEqual = false
            if i == 0 { // After equality condition is reset and wiped clean, it should throw an error
                XCTAssertThrowsError(try cond2.evaluateSingleState(curState))
                cond2.reset(initialState: curState)
            } else { isEqual = try! cond2.evaluateSingleState(curState) }
            if i == maxindex { XCTAssertTrue(isLocalMax) } else { XCTAssertFalse(isLocalMax) }
            if cury == -2 || cury == 1 { XCTAssertTrue(isEqual) } else { XCTAssertFalse(isEqual) }
            if cury > 6 && cury < 9 { XCTAssertTrue(isInterval) } else { XCTAssertFalse(isInterval) }
            XCTAssertThrowsError(try cond4.evaluateSingleState(curState)) // Can't evaluate global condition just based on a single state
        }
    }
    
    func testMeetsCondition(){
        let t = Variable("t", named: "time", symbol: "t", units: "s")
        t.value = (0...9).map { VarValue($0) }
        let x = Variable("x", named: "X Position", symbol: "x", units: "m")
        x.value = (0...9).map { 2*VarValue($0) }
        let y = Variable("y", named: "Y Position", symbol:"y", units: "m")
        y.value = [0, 4, 7, 10, 8, 5, -2, -5, -4, 1]
        let state = State([t, x, y])

        let cond1 = Condition("y", upperBound: 20, lowerBound: 6)
        let cond2 = Condition("y", equality: -1)
        //let cond3 = Condition("y", specialCondition: .localMax)
        //let cond4 = Condition("y", specialCondition: .globalMin)
        let cond3 = Condition("x", upperBound: 6.5)
        
        let cond4 = Condition(conditions: [cond1, cond2], unionType: .or, name: "or")
        let cond5 = Condition(conditions: [cond1, cond3], unionType: .and, name: "and")
        cond4.evaluateState(state)
        cond5.evaluateState(state)
        
        XCTAssertEqual(cond4.meetsConditionIndex, [2,3,4,6,9])
        XCTAssertEqual(cond5.meetsConditionIndex, [2,3])
        
        let norindex = (cond4.meetsCondition!).map({!$0}) // Flip the index for or to get the index for nor
        let nandindex = (cond5.meetsCondition!).map({!$0}) // Flip the index for and to get the index for nand
        cond4.unionType = .nor; cond4.evaluateState(state)
        cond5.unionType = .nand; cond5.evaluateState(state)
        XCTAssertEqual(norindex, cond4.meetsCondition)
        XCTAssertEqual(nandindex, cond5.meetsCondition)
        
        let cond6 = Condition("y", specialCondition: .globalMin)
        let cond7 = Condition(conditions: [cond5, cond6], unionType: .xor, name: "Contains Global")
        XCTAssert(cond7.containsGlobalCondition())

        // Test single state condition
        let stateArray = StateDictArray(from: state)
        cond4.reset(initialState: stateArray[0])
        cond5.reset(initialState: stateArray[0])
        for i in 0...stateArray.stateLen-1 {
            let curState = stateArray[i]
            let isNor = try! cond4.evaluateSingleState(curState)
            let isNand = try! cond5.evaluateSingleState(curState)
            
            XCTAssertEqual(isNor, norindex[i])
            XCTAssertEqual(isNand, nandindex[i])
        }
        
        // Test Valid
        cond4.conditions = []
        XCTAssertFalse(cond4.isValid()) // Not valid because it doesn't have conditions
        cond5.name = ""
        XCTAssertFalse(cond5.isValid()) // Not valid because it doesn't have a name
        
        // Test subscript by condition
        let newState = state[cond6]
        let matchingState: Dictionary<VariableID, [VarValue]> = ["t": [7.0], "x": [14.0], "y": [-5.0]]
        XCTAssertEqual(newState, matchingState)
    }
    
    // MARK: Enums related to condition
    func testBoolType(){
        XCTAssertEqual(BoolType("or"), BoolType.or)
        XCTAssertEqual(BoolType("and"), BoolType.and)
        XCTAssertEqual(BoolType("nor"), BoolType.nor)
        XCTAssertEqual(BoolType("nand"), BoolType.nand)
        XCTAssertEqual(BoolType("xor"), BoolType.xor)
        XCTAssertEqual(BoolType("xnor"), BoolType.xnor)
        XCTAssertEqual(BoolType("single"), BoolType.single)
        XCTAssertNil(BoolType("xand"))
    }
    
    func testSpecialCondition(){
        var spCond = SpecialConditionType("global min")
        XCTAssertEqual(spCond, SpecialConditionType.globalMin)
        spCond = .localMax
        XCTAssertEqual(spCond?.description, "Local Max")
        let spCond2 = SpecialConditionType("max")
        XCTAssertEqual(spCond2, SpecialConditionType.localMax)
        XCTAssertNil(SpecialConditionType("glocal max"))
    }
    
}

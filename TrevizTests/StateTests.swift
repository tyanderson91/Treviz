//
//  StateTests.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 8/9/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class StateTests: XCTestCase {

    var state1 = State()
    let phase = TZPhase(id: "phase1")
    
    override func setUpWithError() throws {
        let t = Variable("t", named: "time", symbol: "t", units: "s")
        t.value = (0...9).map { VarValue($0) }
        let x = Variable("x", named: "X Position", symbol: "x", units: "m")
        x.value = (0...9).map { 2*VarValue($0) }
        let y = Variable("y", named: "Y Position", symbol:"y", units: "m")
        y.value = [0, 4, 7, 10, 8, 5, -2, -5, -4, 1]
        state1 = State([t, x, y])
    }

    func testSubscript() throws {
        // Variable
        let z = Variable("z", named: "Z position", symbol: "z", units: "m")
        z.value = Array(repeating: 0.0, count: 10)
        state1["z"] = z
        XCTAssert(state1["z"]!.id == "z")
        let y = state1["y"]!
        XCTAssert(y.name == "Y Position")
        let newY = Variable("y", named: "Y Position2", symbol:"y2", units: "m")
        state1["y"] = newY
        XCTAssert(state1["y"]!.name == "Y Position2")
        XCTAssertNil(state1["dx"])
        state1["dx"] = nil
        XCTAssert(state1["dx"] == nil)
        XCTAssertNil(state1["dy"])
        
        //Variable and Index
        let x1 = state1["x", 1]
        XCTAssert(x1 == 2.0)
        state1["x",2] = 3.0
        XCTAssert(state1["x", 2] == 3.0)
        XCTAssertNil(state1["x", 100])
    }
    
    func testUpdateFromDict() {
        var stateArray = StateDictArray(from: state1)
        stateArray["x"] = Array(repeating: -1.0, count: 10)
        state1.updateFromDict(traj: stateArray)
        state1["x"]!.value[0] = -1
    }
    
    //MARK: State Dict tests
    func testDictSubscripts(){
        phase.varList = state1
        var stateArray = StateDictArray(from: state1)
        stateArray.phase = phase
        let x = stateArray["x"]!

        stateArray["dx"] = Array(repeating: 3.0, count: 10)
        stateArray["dy"] = (0...9).map { 2*VarValue($0) }
        stateArray["dz"] = Array(repeating: 4.0, count: 10)
        XCTAssert(x[0] == 0)
        let vel = stateArray["v"]!
        let accel = stateArray["a"]!
        XCTAssert(vel[0] == 5)
        XCTAssert(vel[6] == 13)
        XCTAssertNotNil(accel)
        
        var stateArray1 = StateDictArray(from: state1, at: 1)
        XCTAssert(stateArray1["y"] == [4])
        stateArray["x", 1] = 9.0
        XCTAssert(stateArray["x", 1] == 9.0)
        
        var newState = StateDictSingle()
        newState["y"] = 3; newState["x"] = 8; newState["t"] = 0
        var stateArray2 = StateDictArray(from: state1)
        stateArray2[2] = newState
        XCTAssertEqual(stateArray2["y",2], 3)
        //XCTAssertEqual(stateArray2["y",-1], 1)
        let state3 = StateDictSingle(from: state1, at: 1)
        XCTAssert(state3["y"] == 4)
        let state4 = StateDictSingle(lastestFromState: state1)
        XCTAssert(state4["y"] == 1)
        
        //Not found
        XCTAssertNil(stateArray2["missingvar"])
        XCTAssertNil(stateArray2["missingvar", 1])
        XCTAssertNil(stateArray2["x",100])
    }
    func testInit() {
        let newStateArray = StateDictSingle(from: state1, at: -1)
        XCTAssert(newStateArray["y"]==1)
    }
}

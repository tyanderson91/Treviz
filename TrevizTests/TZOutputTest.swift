//
//  TZOutputTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 8/12/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis
import Yams

class TZOutputTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    let x = Variable("x", named: "x")
    let y = Variable("y", named: "y")
    let z = Variable("z", named: "z")
    let t = Variable("t", named: "t")
    let cond = Condition("t")
    
    func testInit() throws {
        let newOutput = TZOutput(id: 1, plotType: .boxplot)
        XCTAssert(newOutput.id == 1)
        XCTAssert(newOutput.plotType == .boxplot)
        
        // Init with dict
        let output2 = try TZPlot(id: 2, vars: [x,y,z,t], plotType: .multiPointCat3d, conditionIn: cond)
        XCTAssertEqual(output2.var1, x)
        XCTAssertEqual(output2.var2, y)
        XCTAssertEqual(output2.var3, z)
        XCTAssertEqual((cond.conditions[0] as! SingleCondition).varID, "t")
        if let catID = output2.categoryVar?.id {
            XCTAssertEqual(catID, t.id)
        } else { XCTFail() }
        
        let textOutput = TZTextOutput(id: 3, with: newOutput)
        XCTAssert(textOutput.plotType == .boxplot)
        let plotOutput = TZTextOutput(id: 4, with: output2)
        XCTAssertEqual(plotOutput.var1, x)
        let singleCond = plotOutput.condition!.conditions[0] as! SingleCondition
        XCTAssert(singleCond.varID == "t")
    }
    
    func testIsValid() throws {
        //Testing correct configurations
        XCTAssertNoThrow(try TZTextOutput(id: 3, vars: [x], plotType: .singleValue, conditionIn: cond))
        XCTAssertNoThrow(try TZTextOutput(id: 4, vars: [x, nil, nil, t], plotType: .multiValue, conditionIn: cond))
        XCTAssertNoThrow(try TZTextOutput(id: 5, vars: [x], plotType: .boxplot, conditionIn: cond))
        XCTAssertNoThrow(try TZTextOutput(id: 6, vars: [x,nil,nil,t], plotType: .multiBoxplot, conditionIn: cond))
        XCTAssertNoThrow(try TZTextOutput(id: 7, vars: [x], plotType: .histogram, conditionIn: cond))
        XCTAssertNoThrow(try TZTextOutput(id: 8, vars: [x,y], plotType: .oneLine2d))
        XCTAssertNoThrow(try TZTextOutput(id: 9, vars: [x,y,nil,t], plotType: .multiLine2d))
        XCTAssertNoThrow(try TZTextOutput(id: 10, vars: [x,y], plotType: .multiPoint2d, conditionIn: cond))
        XCTAssertNoThrow(try TZTextOutput(id: 11, vars: [x,y,nil,t], plotType: .multiPointCat2d, conditionIn: cond))
        XCTAssertNoThrow(try TZPlot(id: 12, vars: [x,y,z], plotType: .oneLine3d))
        XCTAssertNoThrow(try TZPlot(id: 13, vars: [x,y,z,t], plotType: .multiLine3d))
        XCTAssertNoThrow(try TZPlot(id: 14, vars: [x,y,z], plotType: .multiPoint3d, conditionIn: cond))
        XCTAssertNoThrow(try TZPlot(id: 15, vars: [x,y,z,t], plotType: .multiPointCat3d, conditionIn: cond))
        XCTAssertNoThrow(try TZPlot(id: 16, vars: [x,y,z], plotType: .contour2d, conditionIn: cond))
        XCTAssertNoThrow(try TZPlot(id: 17, vars: [x,y,z], plotType: .surface3d, conditionIn: cond))

        //Testing various mis-matches
        XCTAssertThrowsError(try TZTextOutput(id: 3, vars: [x], plotType: .singleValue))
        XCTAssertThrowsError(try TZTextOutput(id: 4, vars: [x, nil, nil], plotType: .multiValue, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 5, vars: [x, nil, nil, t], plotType: .boxplot, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 6, vars: [x,nil,nil], plotType: .multiBoxplot))
        XCTAssertThrowsError(try TZTextOutput(id: 7, vars: [x, nil, nil, t], plotType: .histogram, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 8, vars: [x], plotType: .oneLine2d))
        XCTAssertThrowsError(try TZTextOutput(id: 9, vars: [x,y,nil,t], plotType: .multiLine2d, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 10, vars: [nil,y], plotType: .multiPoint2d, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 11, vars: [x,y,nil], plotType: .multiPointCat2d, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 12, vars: [x,nil,z], plotType: .oneLine3d))
        XCTAssertThrowsError(try TZTextOutput(id: 13, vars: [nil,y,z,t], plotType: .multiLine3d, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 14, vars: [x,y,nil,t], plotType: .multiPoint3d, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 15, vars: [x,y,z], plotType: .multiPointCat3d))
        XCTAssertThrowsError(try TZTextOutput(id: 16, vars: [x,y,z], plotType: .contour2d))
        XCTAssertThrowsError(try TZTextOutput(id: 16, vars: [x,y,z,t], plotType: .contour2d, conditionIn: cond))
        XCTAssertThrowsError(try TZTextOutput(id: 17, vars: [x,y,z], plotType: .surface3d))
        XCTAssertThrowsError(try TZTextOutput(id: 17, vars: [x,y,z,t], plotType: .surface3d, conditionIn: cond))
    }

    func testGetData() {
        let t = Variable("t", named: "time", symbol: "t", units: "s")
        t.value = (0...9).map { VarValue($0) }
        let x = Variable("x", named: "X Position", symbol: "x", units: "m")
        x.value = (0...9).map { 2*VarValue($0) }
        let y = Variable("y", named: "Y Position", symbol:"y", units: "m")
        y.value = [0, 4, 7, 10, 8, 5, -2, -5, -4, 1]
        let traj = State(arrayLiteral: t,x,y)
        let run = TZRun(trajData: traj)
        let cond = Condition("y", equality: 0.5)
        do {
            let output1 = try TZTextOutput(id: 1, vars: [t], plotType: .singleValue, conditionIn: cond)
            let output2 = try TZPlot(id: 2, vars: [x,y], plotType: .oneLine2d)
            output1.runData = [run]
            output2.runData = [run]
            let lineset1 = try output1.getData()
            let lineset2 = try output2.getData()
            XCTAssertEqual(lineset1?.var1, [1,6,9])
            XCTAssertEqual(lineset2?.var1, x.value)
            XCTAssertEqual(lineset2?.var2, y.value)
        } catch { XCTFail() }
    }
    
    //MARK: IO
    func testOutputIO() {
        // Yaml
        let outputDict1: [String: Any] = [
            "id": 1, "title": "OutputTitle", "variable1": Variable("x"),
            "plot type": "Value at Condition", "condition": Condition("x")
        ]
        let outputDict2: [String: Any] = [
            "id": 2, "title": "OutputTitle2", "variable1": Variable("x"), "variable2": Variable("y"),
            "plot type": "2 Var along Trajectory"
        ]
        let outputDictFail: [String: Any] = [
            "id": 3, "title": "This will fail", "variable1": Variable("becauseit"), "variable3": Variable("hasbadsettings"),
            "plot type": "2 Var along Trajectory"
        ]
        
        var yamlOutputs = [TZOutput]()
        let outputList = [outputDict1, outputDict2]
        for thisOutputDict in outputList {
            do {
                let newOutput = try TZOutput(with: thisOutputDict)
                yamlOutputs.append(newOutput)
            } catch { XCTFail()}
        }
        
        XCTAssert(yamlOutputs.count == 2)
        XCTAssert(yamlOutputs[0].title == "OutputTitle")
        XCTAssert(yamlOutputs[1].id == 2)
        XCTAssertThrowsError(try TZTextOutput(with: outputDictFail))
        // Codable JSON
        
        //Writing
        var dataOut = Data()
        let encoder = JSONEncoder()
        do {
            let encoder = JSONEncoder()
            dataOut = try encoder.encode(yamlOutputs)
            let _: [[String: Any]] = try Yams.load(yaml: String(data: dataOut, encoding: String.Encoding.utf8)!) as! [[String:Any]]
        } catch { XCTFail() }
        
        // Reading
        var codableOutputs = [TZOutput]()
        var dataIn = Data()
        do {
            let bundle = Bundle(for: type(of: self))
            let filePath = bundle.url(forResource: "TestAnalysis1", withExtension: "json")!
            let analysisData = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let analysis = try decoder.decode(Analysis.self, from: analysisData)
            codableOutputs = analysis.plots
            dataIn = try encoder.encode(codableOutputs)
        } catch { XCTFail() }

        do {
            _ = try Yams.load(yaml: String(data: dataIn, encoding: String.Encoding.utf8)!)
        } catch { XCTFail() }
    }
}

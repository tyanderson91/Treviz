//
//  TestHelperFunctions.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 9/7/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation
import Cocoa
import Yams
import XCTest
@testable import TrajectoryAnalysis

extension Analysis {
    static func initFromYaml(file: String, self mySelf: AnyObject)-> Analysis {
        do {
            let bundle = Bundle(for: type(of: mySelf))
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
    }
}

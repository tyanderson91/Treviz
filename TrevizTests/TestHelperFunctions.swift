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

func getYamlDict(filename: String, self typeIn: AnyObject)->[String:Any] {
    var yamlObj: Any
    do {
        let bundle = Bundle(for: type(of: typeIn))
        guard let filePath = bundle.url(forResource: filename, withExtension: "yaml") else { XCTFail(); return [:]}
        let data = try Data(contentsOf: filePath)
        let stryaml = String(data: data, encoding: String.Encoding.utf8)
        yamlObj = try Yams.load(yaml: stryaml!) ?? []
        if let yamlDict = yamlObj as? [String: Any] { return yamlDict }
        else { XCTFail() }
    } catch { XCTFail() }
    return [:]
}

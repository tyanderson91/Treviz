//
//  YAML.swift
//  Treviz
//
//  Created by Tyler Anderson on 11/19/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Foundation
import Yams
/**
 Get the object associated with a given yaml file
 */
func getYamlObject(from file: String)->Any?{
    var outputList: Any?
    if let yamlFilePath = Bundle.main.path(forResource: file, ofType: "yaml"){
        do {
            let stryaml = try String(contentsOfFile: yamlFilePath, encoding: String.Encoding.utf8)
            outputList = try Yams.load(yaml: stryaml)
            // outputList = Array(try Yams.load_all(yaml: stryaml))
        } catch {
            outputList = nil }
    }
    return outputList
}

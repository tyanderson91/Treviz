//
//  AnalysisData.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/30/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//
import Foundation
import Cocoa

class AnalysisData: NSObject {
    @objc dynamic var initVars : [Variable] = []
    
    func read(from data: Data) {
        initVars = []// = String(bytes: data, encoding: .utf8)!
        
    }
    
    func data() -> Data? {
        return nil//contentString.data(using: .utf8)
    }
    
    init(fromPlist plistName: String){//TODO: expand the number of read sourcess
        let varFilePath = Bundle.main.path(forResource: plistName, ofType: "plist")
        if (varFilePath != nil) {
            self.initVars = Variable.initVars(filename: varFilePath!)
            InitState.varInputList = self.initVars
        }
    }
}

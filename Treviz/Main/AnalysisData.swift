//
//  AnalysisData.swift
//  Treviz
//
//  This object does the main job of reading, writing, and storing analysis document data
//
//  Created by Tyler Anderson on 3/30/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//
import Foundation
import Cocoa

class AnalysisData: NSObject {
    
    var initState = State()
    var inputSettings : [Parameter] = []
    var plots : [TZOutput] = []
    var analysis : Analysis!
    
    func read(from data: Data) {
    }
    
    func data() -> Data? {
        return nil//contentString.data(using: .utf8)
    }
    
    init(analysis: Analysis){
        //This function runs the default loading sub-methods
        //TODO: expand the number of read sourcess
        //self.loadVars(from: "InitialVars")
        super.init()
        self.analysis = analysis
        NotificationCenter.default.addObserver(self, selector: #selector(self.initReadData(_:)), name: .didLoadAppDelegate, object: nil)
        
        NotificationCenter.default.post(name: .didLoadAnalysisData, object: nil)
    }
    
    @objc func initReadData(_ notification: Notification){
        guard let varFilePath = Bundle.main.path(forResource: "InitVarSettings", ofType: "plist") else {return}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return}
        
        for thisVarElement in inputList {
            let thisVar = thisVarElement as! NSDictionary
            let initVars = analysis.initVars
            let thisVarID = thisVar["id"] as! VariableID
            let curVar = initVars!.first(where: { $0.id == thisVarID})!
            curVar.value.append(thisVar["value"] as! Double) // TODO: make sure this is the first element
            curVar.isParam = thisVar["isParam"] as! Bool
            inputSettings.append(curVar)
        }
    }
    
    
}

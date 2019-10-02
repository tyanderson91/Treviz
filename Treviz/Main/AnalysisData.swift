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
    var initVars : [Variable]?
    var initPlotTypes : [PlotType]?
    
    func read(from data: Data) {
        initVars = []// = String(bytes: data, encoding: .utf8)!
    }
    
    func data() -> Data? {
        return nil//contentString.data(using: .utf8)
    }
    
    override init(){
        super.init()
        //This function runs the default loading sub-methods
        //TODO: expand the number of read sourcess
        self.loadVars(from: "InitialVars")
        //self.loadPlotTypes(from: "PlotTypes")
    }
    
    func loadVars(from plist: String){
        let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist")
        if (varFilePath != nil) {
            let listOfVars = Variable.initVars(filename: varFilePath!)
            if listOfVars.count > 0 {//If the initialization did not return an empty array
                self.initVars = listOfVars
                InputSetting.varInputList = listOfVars // TODO : handle this in a more robust way
            } else {self.initVars = nil}
        }
        else {
            self.initVars = nil
        }
    }
    
    func loadPlotTypes(from plist: String){
        let plotFilePath = Bundle.main.path(forResource: plist, ofType: "plist")
        if (plotFilePath != nil) {
            let listOfPlots = PlotType.loadPlotTypes(filename: plotFilePath!)
            if listOfPlots.count > 0 {//If the initialization did not return an empty array
                self.initPlotTypes = listOfPlots
            } else {self.initPlotTypes = nil}
        }
        else {
            self.initPlotTypes = nil
        }
    }
}

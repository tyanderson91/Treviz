//
//  AppDelegate.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
// Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var application: NSApplication!
    
    var plotTypes : [PlotType]! = nil
    var initVars : [Variable]! = nil
    // var initStateGroups : InitStateHeader! = nil
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        loadPlotTypes(from: "PlotTypes")
        loadVars(from: "InitVars")
        initVars = State.sortVarIndices(initVars)
        // loadVarGroups(from: "InitStateStructure")
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /*
        loadPlotTypes(from: "PlotTypes")
        loadVars(from: "InitVars")
        initVars = State.sortVarIndices(initVars)
        loadVarGroups(from: "InitStateStructure")*/
        for thisWindow in application.windows {
            let windowController = thisWindow.windowController
            if let doc = windowController?.document as? Analysis {
                doc.appDelegate = self
            }
        }
        
        NotificationCenter.default.post(name: .didLoadAppDelegate, object: nil)
        // Insert code here to initialize your application
        //let newAnalysis = Analysis()
        //print(newAnalysis.initialState)
        //newAnalysis.makeWindowControllers()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func loadVars(from plist: String){
        guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return}//return empty if filename not found
        initVars = []
        for thisVar in inputList {
            guard let dict = thisVar as? NSDictionary else {return}
            let newVar = Variable(dict["id"] as! VariableID, named: dict["name"] as! String, symbol: dict["symbol"] as! String)
            newVar.units = dict["units"] as! String
            newVar.value = [0]
            initVars.append(newVar)
        }
    }
    
    /*
    func loadVarGroups(from plist: String){
        guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return}//return empty if filename not found
        initStateGroups = InitStateHeader(id: "default")
        loadVarGroupsRecurs(input: initStateGroups, withList: inputList as! [NSDictionary])
    }
    
    private func loadVarGroupsRecurs(input: InitStateHeader, withList list: [NSDictionary]){
        for dict in list {
            guard let itemType = dict["itemType"] as? String else { return }
            guard let itemID = dict["id"] as? VariableID else { return }
            let name = dict["name"] as? String
            
            if itemType == "var"{
                if let newVar = initVars.first(where: {$0.id == itemID}){
                    input.variables.append(newVar)}
                continue
            } else {
                var newHeader = InitStateHeader(id: "")
                if itemType == "header" {
                    newHeader = InitStateHeader(id: itemID)}
                else if itemType == "subHeader" {
                    newHeader = InitStateSubHeader(id: itemID)}
                else {return}
                newHeader.name = name!
                input.subheaders.append(newHeader)
                if let children = dict["items"] as? NSArray {
                    loadVarGroupsRecurs(input: newHeader, withList: children as! [NSDictionary])
                }
            }
        }
    }*/
    
    func loadPlotTypes(from plist: String){
        guard let plotFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
        
        guard let inputList = NSArray.init(contentsOfFile: plotFilePath) else {
            self.plotTypes = nil
            return}
        var initPlotTypes : [PlotType] = []
        for thisPlot in inputList {
            guard let dict = thisPlot as? NSDictionary else {return}
            let newPlot = PlotType(dict["id"] as! String, name: dict["name"] as! String, requiresCondition: dict["condition"] as! Bool, nAxis: dict["naxis"] as! Int, nVars: dict["nvar"] as! Int)
            initPlotTypes.append(newPlot)
        }
        self.plotTypes = initPlotTypes
        PlotType.allPlotTypes = initPlotTypes
    }    
}

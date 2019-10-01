//
//  TZPlot.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/24/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
/*
enum PlotType : String {
    case histogram = "Histogram"
    case singleLine2d = "1 Line 2D"
    case multiLine2d = "Multi Line 2D"
    case contour = "Contour"
}*/
//TODO : This should probably be in a struct
class PlotType {
    var id : String = ""
    var name : String = ""
    var requiresCondition : Bool = false
    var nAxis : Int = 0
    var nVars : Int = 0
    
    static var allPlotTypes : [PlotType] = []
    
    init(_ id: String, name : String, requiresCondition: Bool, nAxis: Int, nVars: Int) {
        self.id = id
        self.name = name
        self.requiresCondition = requiresCondition
        self.nAxis = nAxis
        self.nVars = nVars
    }
    
    static func loadPlotTypes(filename: String)->[PlotType]{ // TODO : Probably bad practice to have all these static funcs laying around here. Move over to AnalysisData or something like that
        guard let inputList = NSArray.init(contentsOfFile: filename)
            else {return []}//return empty if filename not found
        var initPlotTypes : [PlotType] = []
        for thisPlot in inputList {
            let dict = thisPlot as! NSDictionary //TODO: error check the type, return [] if not a dictionary
            let newPlot = PlotType(dict["id"] as! String, name: dict["name"] as! String, requiresCondition: dict["condition"] as! Bool, nAxis: dict["naxis"] as! Int, nVars: dict["nvar"] as! Int)
            initPlotTypes.append(newPlot)
        }
        allPlotTypes = initPlotTypes
        return initPlotTypes
    }
    
    static func getIDs()->[String]{
        var ids : [String] = []
        for thisType in allPlotTypes {
            ids.append(thisType.id)
        }
        return ids
    }
    
    static func getNames()->[String]{ // TODO : replace with key value bindings in dropdown
        var names : [String] = []
        for thisType in allPlotTypes {
            names.append(thisType.name)
        }
        return names
    }
    
    
    static func getPlotByName(_ name : String)->PlotType?{
        if let thisPlot = allPlotTypes.firstIndex(where: { (thisPlot) -> Bool in
            return thisPlot.name == name
        })
        { return allPlotTypes[thisPlot]
        } else {return nil}
        /*
        for thisType in allPlotTypes {
            if thisType.name == name { //TODO : binary search?
                return thisType
            }
        }
        return nil*/
    }
 }
 

class TZPlot: NSObject {
    
    var displayName : String
    var id : Int
    var title : String?
    var plotType : PlotType
    var var1 : Variable?
    var var2 : Variable?
    var var3 : Variable?
    var categoryVar : Variable?
    var condition : Condition?
    var includeText : Bool = false
    
    
    init(_ id : Int, named displayName : String = "", type plotType : String) {
        //super.init() //TODO: what does this actually do?
        self.id = id
        self.displayName = displayName
        self.plotType = PlotType.getPlotByName(plotType)!
    }
    
}

class TZPlot1line2d : TZPlot {
    func setName(){
        if var1 != nil && var2 != nil {
            if displayName == "" {
                displayName = "\(var2!.name) vs \(var1!.name) \(plotType.name) "
            }
        }
        else {
            displayName = "ThisPlotType"
        }
    }
    
    init(){
        super.init(0,named : "",type : "1line2d")
    }
}

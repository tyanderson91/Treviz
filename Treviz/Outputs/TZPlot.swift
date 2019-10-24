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
class PlotType { //TODO : This should probably be in a struct
    
    var id : String = ""
    var name : String = ""
    var requiresCondition : Bool = false
    var nAxis : Int = 0
    var nVars : Int = 0
    
    static var allPlotTypes : [PlotType] = []
    
    init(){
    }
    
    init(_ id: String, name : String, requiresCondition: Bool, nAxis: Int, nVars: Int) {
        self.id = id
        self.name = name
        self.requiresCondition = requiresCondition
        self.nAxis = nAxis
        self.nVars = nVars
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
        if let thisPlot = allPlotTypes.firstIndex(where: { $0.name == name } )
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
 

class TZPlot: TZOutput {

}

/*
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
}*/

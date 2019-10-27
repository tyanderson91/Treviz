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
    
    /**
     Create a list of all existing plot type IDs
     - Returns: ids, a list of all plot type IDs that have been initialized in the class-level variable allPlotTypes
     - TODO: store plot type information in app delegate, not a class-level variable
     */
    static func getIDs()->[String]{

        var ids : [String] = []
        for thisType in allPlotTypes {
            ids.append(thisType.id)
        }
        return ids
    }
    
    /**
     Create a list of all existing plot type names
     - Returns: names, a list of all plot type names that have been initialized in the class-level variable allPlotTypes
     - TODO: store plot type information in app delegate, not a class-level variable
     */
    static func getNames()->[String]{ // TODO : replace with key value bindings in dropdown
        var names : [String] = []
        for thisType in allPlotTypes {
            names.append(thisType.name)
        }
        return names
    }
    
    /**
     Get a PlotType object corresponding to a given name
     - Parameter name: String, name of the plot type you want to return
     - Returns:thisPlot, a PlotType object
     - TODO: use bindings to get this info from interface builder instead
     */
    static func getPlotTypeByName(_ name : String)->PlotType?{
        if let thisPlot = allPlotTypes.firstIndex(where: { $0.name == name } )
        { return allPlotTypes[thisPlot]
        } else {return nil}
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

//
//  TZPlotType.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/1/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 This class defines all the unique configurations and requirements for various plot types. All possible types are stored as static class variables
 */
enum TZPlotTypeError : Error {
    case InvalidPlotType
}

class TZPlotType : NSObject {
    //TODO : This should probably be in a struct. Get rid of bindings
    
    var id : String = ""
    @objc var name : String = ""
    var requiresCondition : Bool = false
    var nAxis : Int = 0
    var nVars : Int = 0
    @objc var icon : NSImage?
    
    init(_ id: String, name: String, requiresCondition: Bool, nAxis: Int, nVars: Int) {
        self.id = id
        self.name = name
        self.requiresCondition = requiresCondition
        self.nAxis = nAxis
        self.nVars = nVars
        if let fullImage = NSImage(named: id) {
            self.icon = fullImage
        }
    }
    
    /**
     Get a PlotType object corresponding to a given name
     - Parameter name: String, name of the plot type you want to return
     - Returns:thisPlot, a PlotType object
     */
    static func getPlotTypeByName(_ name : String)->TZPlotType?{
        if let thisPlot = allPlotTypes.firstIndex(where: { $0.name == name } ) {
            return allPlotTypes[thisPlot] }
        else {return nil}
    }
    
    // MARK: Existing types
    static var singleValue = TZPlotType("singlevalue", name: "Value at Condition", requiresCondition: true, nAxis: 1, nVars: 1)
    static var multiValue = TZPlotType("multivalue", name: "Value at Condition, by Category", requiresCondition: true, nAxis: 1, nVars: 2)
    static var boxplot = TZPlotType("boxplot", name: "Box Plot at Condition", requiresCondition: true, nAxis: 1, nVars: 1)
    static var multiBoxplot = TZPlotType("multiboxplot", name: "Box Plots at Condition, by Category", requiresCondition: true, nAxis: 1, nVars: 2)
    static var histogram = TZPlotType("histogram", name: "Histogram at Condition", requiresCondition: true, nAxis: 1, nVars: 1)
    static var oneLine2d = TZPlotType("1line2d", name: "2 Var along Trajectory", requiresCondition: false, nAxis: 2, nVars: 2)
    static var multiLine2d = TZPlotType("nline2d", name: "2 Var along Trajectory, by Category", requiresCondition: false, nAxis: 2, nVars: 3)
    static var multiPoint2d = TZPlotType("npoint2d", name: "2 Var at Condition", requiresCondition: true, nAxis: 2, nVars: 2)
    static var multiPointCat2d = TZPlotType("multinpoint2d", name: "2 Var at Condition, by Category", requiresCondition: true, nAxis: 2, nVars: 3)
    static var contour2d = TZPlotType("contour2d", name: "3 Var Contour", requiresCondition: true, nAxis: 2, nVars: 3)
    static var oneLine3d = TZPlotType("1line3d", name: "3 Var along trajectory", requiresCondition: false, nAxis: 3, nVars: 3)
    static var multiLine3d = TZPlotType("nline3d", name: "3 Var along Trajectory, by Category", requiresCondition: false, nAxis: 3, nVars: 4)
    static var multiPoint3d = TZPlotType("npoint3d", name: "3 Var at Condition", requiresCondition: true, nAxis: 3, nVars: 3)
    static var multiPointCat3d = TZPlotType("multinpoint3d", name: "3 Var at Condition, by Category", requiresCondition: true, nAxis: 3, nVars: 4)
    static var surface3d = TZPlotType("surface3d", name: "3 Var Surface", requiresCondition: true, nAxis: 3, nVars: 3)
    
    static var allPlotTypes : [TZPlotType] = [.singleValue, .multiValue, .boxplot, .multiBoxplot, .histogram, .oneLine2d, .multiLine2d, .multiPoint2d, .multiPointCat2d, .contour2d, .oneLine3d, .multiLine3d, .multiPointCat3d, .surface3d]
    
    // TODO: figure out how to implement Monte-Carlo run statistics
 }

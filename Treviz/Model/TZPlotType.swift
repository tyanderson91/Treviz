//
//  TZPlotType.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/1/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/*
enum PlotType : String {
    case histogram = "Histogram"
    case singleLine2d = "1 Line 2D"
    case multiLine2d = "Multi Line 2D"
    case contour = "Contour"
}*/
class TZPlotType : NSObject {//, NSCoding {
    //TODO : This should probably be in a struct
    
    var id : String = ""
    @objc var name : String = ""
    var requiresCondition : Bool = false
    var nAxis : Int = 0
    var nVars : Int = 0
    
    //static var allPlotTypes : [TZPlotType] = []  // TODO: Replace with class members
    
    init(_ id: String, name: String, requiresCondition: Bool, nAxis: Int, nVars: Int) {
        self.id = id
        self.name = name
        self.requiresCondition = requiresCondition
        self.nAxis = nAxis
        self.nVars = nVars
    }
    
    /*
    convenience init() {
        self.init(id: "", name: "", requiresCondition: false, nAxis: 0, nVars: 0)
    }*/
    
    /**
     Create a list of all existing plot type IDs
     - Returns: ids, a list of all plot type IDs that have been initialized in the class-level variable allPlotTypes
     - TODO: store plot type information in app delegate, not a class-level variable
     */

    /*
    static func getIDs()->[String]{

        var ids : [String] = []
        for thisType in allPlotTypes {
            ids.append(thisType.id)
        }
        return ids
    }*/
    
    /**
     Create a list of all existing plot type names
     - Returns: names, a list of all plot type names that have been initialized in the class-level variable allPlotTypes
     - TODO: store plot type information in app delegate, not a class-level variable
     */
    /*
    static func getNames()->[String]{ // TODO : replace with key value bindings in dropdown
        var names : [String] = []
        for thisType in allPlotTypes {
            names.append(thisType.name)
        }
        return names
    }*/
    
    /**
     Get a PlotType object corresponding to a given name
     - Parameter name: String, name of the plot type you want to return
     - Returns:thisPlot, a PlotType object
     - TODO: use bindings to get this info from interface builder instead
     */
    static func getPlotTypeByName(_ name : String)->TZPlotType?{
        if let thisPlot = allPlotTypes.firstIndex(where: { $0.name == name } )
        { return allPlotTypes[thisPlot]
        } else {return nil}
    }
    
    // MARK: NSCoding Implementation
    /*
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(requiresCondition, forKey: "requiresCondition")
        coder.encode(nAxis, forKey: "naxis")
        coder.encode(nVars, forKey: "nvars")
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "id") as? String ?? ""
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        requiresCondition = coder.decodeBool(forKey: "requiresCondition")
        nAxis = coder.decodeInteger(forKey: "naxis")
        nVars = coder.decodeInteger(forKey: "nvars")
    }*/
    
    
    // MARK: Existing types
    static var singleValue = TZPlotType("singlevalue", name: "Single Value", requiresCondition: true, nAxis: 1, nVars: 1)
    static var boxplot = TZPlotType("boxplot", name: "Box Plot", requiresCondition: true, nAxis: 1, nVars: 1)
    static var histogram = TZPlotType("histogram", name: "Histogram", requiresCondition: true, nAxis: 1, nVars: 1)
    static var oneLine2d = TZPlotType("1line2d", name: "2 Var, along Trajectory", requiresCondition: false, nAxis: 2, nVars: 2)
    static var multiLine2d = TZPlotType("multiline2d", name: "2 Var w/ Category, along Trajectory", requiresCondition: false, nAxis: 2, nVars: 3)
    static var multiPoint2d = TZPlotType("multipoint2d", name: "2 Var, at Condition", requiresCondition: true, nAxis: 2, nVars: 2)
    static var multiPointCat2d = TZPlotType("multimultipoint2d", name: "2 Var w/ Category, at Condition", requiresCondition: true, nAxis: 2, nVars: 3)
    static var contour2d = TZPlotType("contour2d", name: "3 Var Contour", requiresCondition: true, nAxis: 2, nVars: 3)
    static var oneLine3d = TZPlotType("1line3d", name: "3 Var, along trajectory", requiresCondition: false, nAxis: 3, nVars: 3)
    static var multiLine3d = TZPlotType("multiline3d", name: "3 Var w/ Category, along Trajectory", requiresCondition: false, nAxis: 3, nVars: 4)
    static var multiPoint3d = TZPlotType("multipoint3d", name: "3 Var, at Condition", requiresCondition: true, nAxis: 3, nVars: 3)
    static var multiPointCat3d = TZPlotType("multimultipoint3d", name: "3 Var w/ Category, at Condition", requiresCondition: true, nAxis: 3, nVars: 4)
    static var surface3d = TZPlotType("surface3d", name: "3 Var Surface", requiresCondition: true, nAxis: 3, nVars: 3)
    
    static var allPlotTypes : [TZPlotType] = [.singleValue, .boxplot, .histogram, .oneLine2d, .multiLine2d, .multiPoint2d, .multiPointCat2d, .contour2d, .oneLine3d, .multiLine3d, .multiPointCat3d, .surface3d]
    
    // TODO: figure out how to implement Monte-Carlo run statistics
 }

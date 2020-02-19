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
class TZPlotType : NSObject, NSCoding {
    //TODO : This should probably be in a struct
    
    var id : String = ""
    @objc var name : String = ""
    var requiresCondition : Bool = false
    var nAxis : Int = 0
    var nVars : Int = 0
    
    static var allPlotTypes : [TZPlotType] = []  // TODO: Replace with class members
    
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
    static func getPlotTypeByName(_ name : String)->TZPlotType?{
        if let thisPlot = allPlotTypes.firstIndex(where: { $0.name == name } )
        { return allPlotTypes[thisPlot]
        } else {return nil}
    }
    
    // MARK: NSCoding Implementation
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
    }
    
 }

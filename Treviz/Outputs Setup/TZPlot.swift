//
//  TZPlot.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/24/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

enum PlotType : String {
    case histogram = "Histogram"
    case singleLine2d = "1 Line 2D"
    case multiLine2d = "Multi Line 2D"
    case contour = "Contour"
}
/* TODO : This should probably be in a struct
 struct PlotType {
     var id : String
     var name : String
     var requiresCondition : Bool
 }
 */

class TZPlot: NSObject {
    
    var displayName : String
    var id : Int
    var title : String?
    var plotType : PlotType
    var var1 : Variable?
    var var2 : Variable?
    var var3 : Variable?
    var catVar : Variable?
    var condition : Condition?
    var includeText : Bool = false
    
    
    init(_ id : Int, named displayName : String = "", type plotType : String) {
        //super.init() //TODO: what does this actually do?
        self.id = id
        self.displayName = displayName
        self.plotType = PlotType(rawValue: plotType) ?? .singleLine2d
    }
    
}

class TZPlot1line2d : TZPlot {
    func setName(){
        if var1 != nil && var2 != nil {
            if displayName == "" {
                displayName = "\(var2!.name) vs \(var1!.name) \(plotType.rawValue) "
            }
        }
        else {
            displayName = "ThisPlotType"
        }
    }
    
    init(){
        super.init(0,named : "",type : "1 Line 2D")
    }
}

//
//  TZPlot.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/24/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

enum PlotType : String {
    case singleLine2d = "Single Line 2D"
    case multiLine2d = "Multi Line 2D"
    case contour = "Contour"
}

class TZPlot: NSObject {
    
    var displayName : String
    var id : Int
    var title : String?
    var plotType : PlotType
    var var1 : Variable?
    var var2 : Variable?
    var var3 : Variable?
    var catVar : Variable?

    
    init(_ id : Int, named displayName : String = "", type plotType : String) {
        //super.init() //TODO: what does this actually do?
        self.id = id
        self.displayName = displayName
        self.plotType = PlotType(rawValue: plotType) ?? .singleLine2d
    }
    

}

//
//  TZOutput.swift
//  Treviz
//
//  This is the superclass for all plots, text output, and any other output sets for an analysis
//
//  Created by Tyler Anderson on 10/2/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class TZOutput : NSObject {
    var displayName : String
    var id : Int
    var title : String?
    var plotType : PlotType
    var var1 : Variable?
    var var2 : Variable?
    var var3 : Variable?
    var categoryVar : Variable?
    var condition : Condition?
    var curTrajectory : State?
    
    init(id : Int, plotType : PlotType){
        self.displayName = ""
        self.id = id
        self.plotType = plotType
        super.init()
    }
    
    init?(with dict: Dictionary<String,Any>){
        if let id = dict["id"] as? Int {self.id = id} else {return nil}
        if let plotType = dict["plot type"] as? PlotType {self.plotType = plotType}else {return nil}
        if let name = dict["name"] as? String {self.displayName = name} else {self.displayName = ""}
        super.init()
        if let title = dict["title"] as? String {self.title = title}
        if let var1 = dict["variable"] as? Variable {self.var1 = var1}
        if let condition = dict["condition"] as? Condition {self.condition = condition}
    }
    
    convenience init(id : Int, title : String, plotType : PlotType) {
        self.init(id : id, plotType : plotType)
        self.displayName = title
        self.title = title
    }
    
    convenience init(id : Int, vars : [Variable], plotType : PlotType) {
        var title = ""
        for thisVar in vars{
            title += thisVar.name
            if thisVar != vars.last {title += " vs "} // TODO: vary this for the different plot types
        }
        self.init(id : id, title : title, plotType : plotType)
        if vars.count >= 1 { var1 = vars[0] }
        if vars.count >= 2 { var2 = vars[1] }
        if vars.count >= 3 { var3 = vars[2] }
        if vars.count >= 4 { categoryVar = vars[4] }
    }
    
    convenience init(id: Int, with output : TZOutput) {
        self.init(id : id, plotType: output.plotType)
        displayName = output.displayName
        title = output.title
        var1 = output.var1
        var2 = output.var2
        var3 = output.var3
        categoryVar = output.categoryVar
        condition = output.condition
        curTrajectory = output.curTrajectory
    }
    
}

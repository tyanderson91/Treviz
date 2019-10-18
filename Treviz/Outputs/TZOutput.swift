//
//  TZOutput.swift
//  Treviz
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
    
    init(id : Int, plotType : PlotType){
        self.displayName = ""
        self.id = id
        self.plotType = plotType
        super.init()
    }
    
    convenience init(id : Int, name : String, plotType : PlotType) {
        self.init(id : id, plotType : plotType)
        self.displayName = name
        self.title = name
    }
    
    convenience init(id : Int, vars : [Variable], plotType : PlotType) {
        var title = ""
        for thisVar in vars{
            title += thisVar.name
            if thisVar != vars.last {title += " vs "}
        }
        self.init(id : id, name : title, plotType : plotType)
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
    }
    
    
    func processVars(_ traj : State){
        // Evaluates variable and condition information to create vectors for outputting
        if condition != nil {
            condition!.evaluate(traj)
        }
    }
}

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
import Foundation

class TZOutput : NSObject, NSCoding {
    
    //var displayName : String
    @objc var displayName: String {return getDisplayName() }
    @objc var id : Int
    @objc var title : String?
    @objc var plotType : TZPlotType
    @objc var var1 : Variable?
    @objc var var2 : Variable?
    @objc var var3 : Variable?
    var categoryVar : Parameter?
    @objc weak var condition : Condition?
    var curTrajectory : State?
    
    init(id : Int, plotType : TZPlotType){
        //self.displayName = ""
        self.id = id
        self.plotType = plotType
        super.init()
    }
    
    init?(with dict: Dictionary<String,Any>){
        if let id = dict["id"] as? Int {self.id = id} else {return nil}
        if let plotType = dict["plot type"] as? TZPlotType {self.plotType = plotType} else {return nil}
        //if let name = dict["name"] as? String {self.displayName = name} else {self.displayName = ""}
        super.init()
        if let title = dict["title"] as? String {self.title = title}
        if let var1 = dict["variable1"] as? Variable {self.var1 = var1}
        if let var2 = dict["variable2"] as? Variable {self.var2 = var2}
        if let var3 = dict["variable3"] as? Variable {self.var3 = var3}
        if let categoryvar = dict["category"] as? Parameter {self.categoryVar = categoryvar}

        
        if let condition = dict["condition"] as? Condition {self.condition = condition}
    }
    /*
    convenience init(id : Int, title : String, plotType : TZPlotType) {
        self.init(id : id, plotType : plotType)
        //self.displayName = title
        //self.title = title
    }*/
    
    convenience init(id : Int, vars : [Variable], plotType : TZPlotType) {
        var title = ""
        for thisVar in vars{
            title += thisVar.name
            if thisVar != vars.last {title += " vs "} // TODO: vary this for the different plot types
        }
        self.init(id: id, plotType: plotType)
        if vars.count >= 1 { var1 = vars[0] }
        if vars.count >= 2 { var2 = vars[1] }
        if vars.count >= 3 { var3 = vars[2] }
        if vars.count >= 4 { categoryVar = vars[4] }
    }
    
    convenience init(id: Int, with output : TZOutput) {
        self.init(id : id, plotType: output.plotType)
        //displayName = output.displayName
        title = output.title
        var1 = output.var1
        var2 = output.var2
        var3 = output.var3
        categoryVar = output.categoryVar
        condition = output.condition
        curTrajectory = output.curTrajectory
    }
    
    private func getDisplayName()->String {
        var name = ""
        let varnames = [var1, var2, var3].compactMap { $0?.name }
        name += varnames.joined(separator: ", ")
        if categoryVar != nil { name += " by " + categoryVar!.name }
        if condition != nil { name += " at " + condition!.name}
        return name
    }
    
    // MARK: NSCoding implementation
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(title, forKey: "title")
        coder.encode(var1, forKey: "var1")
        coder.encode(var2, forKey: "var2")
        coder.encode(var3, forKey: "var3")
        coder.encode(categoryVar, forKey: "categoryVar")
        coder.encode(condition, forKey: "condition")
        coder.encode(plotType.name, forKey: "plotType")
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeInteger(forKey: "id")
        title = coder.decodeObject(forKey: "title") as? String
        var1 = coder.decodeObject(forKey: "var1") as? Variable ?? nil
        var2 = coder.decodeObject(forKey: "var2") as? Variable ?? nil
        var3 = coder.decodeObject(forKey: "var3") as? Variable ?? nil
        categoryVar = coder.decodeObject(forKey: "categoryVar") as? Parameter ?? nil
        condition = coder.decodeObject(forKey: "condition") as? Condition
        let plotTypeName = coder.decodeObject(forKey: "plotType") as? String
        plotType = TZPlotType.getPlotTypeByName(plotTypeName!)!
        
        super.init()
    }
    
}

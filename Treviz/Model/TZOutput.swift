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


enum TZOutputError: Error, LocalizedError {
    case MissingIDError
    case MissingPlotTypeError
    case MissingVariableError
    case MissingTrajectoryError
    case MissingPointsError
    case UnmatchedConditionError
    case DuplicateIDError
    case IncorrectConditionSettingError
    case IncorrectVarSettingError

    public var errorDescription: String? {
        switch self {
        case .MissingIDError:
            return NSLocalizedString("Output missing ID assignment", comment: "")
        case .MissingPlotTypeError:
            return NSLocalizedString("Output missing plot type assignment", comment: "")
        case .MissingVariableError:
            return NSLocalizedString("Output missing variable assignment", comment: "")
        case .MissingTrajectoryError:
            return NSLocalizedString("Trajectory not assigned", comment: "")
        case .MissingPointsError:
            return NSLocalizedString("No points could be found", comment: "")
        case .UnmatchedConditionError:
            return NSLocalizedString("No matching points found for condition", comment: "")
        case .DuplicateIDError:
            return NSLocalizedString("Tried to create new output with existing output ID. Skipping", comment: "")
        case .IncorrectConditionSettingError:
            return NSLocalizedString("Condition setting is invalid for this plot type", comment: "")
        case .IncorrectVarSettingError:
            return NSLocalizedString("One or more variables are set incorrectly for this plot type", comment: "")
        }
    }
}

/** This is the superclass for all plots, text output, and any other output sets for an analysis.
 An output contains all the configuration data required to present the requested data. Details about the implementation of the data display are handled by subclasses (TZTextOutput, TZPlot)
 */
class TZOutput : NSObject, Codable {
    
    @objc var displayName: String {
        var name = ""
        let varnames = [var1, var2, var3].compactMap { $0?.name }
        name += varnames.joined(separator: ", ")
        if categoryVar != nil { name += " by " + categoryVar!.name }
        if condition != nil { name += " at " + condition!.name}
        return name
    }
    @objc var id : Int
    @objc var title : String = ""
    var plotType : TZPlotType
    var var1 : Variable?
    var var2 : Variable?
    var var3 : Variable?
    var categoryVar : Parameter?
    weak var condition : Condition?
    var curTrajectory : State?
    
    init(id : Int, plotType : TZPlotType){
        self.id = id
        self.plotType = plotType
        super.init()
    }
    
    /**
     This is the initializer for outputs from Yaml. The raw Yaml must first be processed by the parent Analysis, since it must contain actual variables and conditions used in that analysis. See AnalysisYaml.swift to understand that process.
    */
    init(with dict: Dictionary<String,Any>) throws {
        if let id = dict["id"] as? Int {self.id = id} else {throw TZOutputError.MissingIDError}
        //plotType = .singleValue
        if let plotTypeName = dict["plot type"] as? String {
            guard let thisPlotType = TZPlotType.getPlotTypeByName(plotTypeName)
                else { throw TZOutputError.MissingPlotTypeError }
            plotType = thisPlotType
        } else { // TODO: implement default detection of output type based on inputs
            plotType = .singleValue
            throw TZOutputError.MissingPlotTypeError
        }
        super.init()
        //TZPlotType {self.plotType = plotType} else {throw TZOutputError.MissingPlotTypeError}
        if let title = dict["title"] as? String {self.title = title}
        if let var1 = dict["variable1"] as? Variable {self.var1 = var1}
        if let var2 = dict["variable2"] as? Variable {self.var2 = var2}
        if let var3 = dict["variable3"] as? Variable {self.var3 = var3}
        if let categoryvar = dict["category"] as? Parameter {self.categoryVar = categoryvar}
        if let condition = dict["condition"] as? Condition {self.condition = condition}
            
        try self.assertValid()
    }
    
    convenience init(id : Int, vars : [Variable?], plotType : TZPlotType, conditionIn: Condition? = nil) throws {
        var title = ""
        self.init(id: id, plotType: plotType)
        if vars.count >= 1 {
            var1 = vars[0]
            if var1 != nil { title += var1!.name }
        }
        if vars.count >= 2 {
            var2 = vars[1]
            if var2 != nil { title += " vs \(var2!.name)" }
        }
        if vars.count >= 3 {
            var3 = vars[2]
            if var3 != nil { title += " vs \(var3!.name)" }
        }
        if vars.count >= 4 {
            categoryVar = vars[3]
            if categoryVar != nil { title += " by \(categoryVar!.name)" }
        }
        condition = conditionIn
        try self.assertValid()
    }
    
    convenience init(id: Int, with output : TZOutput) {
        self.init(id : id, plotType: output.plotType)
        title = output.title
        var1 = output.var1
        var2 = output.var2
        var3 = output.var3
        categoryVar = output.categoryVar
        condition = output.condition
        curTrajectory = output.curTrajectory
    }
    
    // MARK: Codable implementation
    enum CodingsKeys: String, CodingKey {
        case id
        case title
        case var1 = "variable1"
        case var2 = "variable2"
        case var3 = "variable3"
        case catVar = "category variable"
        case condition
        case plotTypeID = "plot type"
        case outputType = "output type"
    }
    
    enum OutputType: String, Codable {
        case text = "text"
        case plot = "plot"
    }
    enum CustomCoderType: String, CodingKey {
        case type = "output type"
        case condition = "condition"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingsKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        var plotTypeID = ""
        do { // TODO: implement default detection of output type based on inputs
            plotTypeID = try container.decode(String.self, forKey: .plotTypeID)
            plotType = TZPlotType.allPlotTypes.first { $0.id == plotTypeID }!
        } catch { throw TZPlotTypeError.InvalidPlotType }
        // Assigning of variables and conditions is done in the analysis-level factory initializer
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingsKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        if var1 != nil { try container.encode(var1?.id, forKey: .var1) }
        if var2 != nil { try container.encode(var2?.id, forKey: .var2) }
        if var3 != nil { try container.encode(var3?.id, forKey: .var3) }
        if categoryVar != nil { try container.encode(categoryVar?.id, forKey: .catVar) }
        if condition != nil { try container.encode(condition?.name, forKey: .condition) }
        try container.encode(plotType.id, forKey: .plotTypeID)
    }
    
    // MARK: Check validity
    func assertValid() throws {
        let condValid = (condition != nil) == (plotType.requiresCondition)
        let var1Valid = (var1 != nil) // == plotType.nAxis >= 1
        let var2Valid = (var2 != nil) == (plotType.nAxis >= 2)
        var var3Valid: Bool
        var catVarValid : Bool!
        if plotType.id == "contour2d" {
            catVarValid = categoryVar == nil
            var3Valid = var3 != nil
        } else {
            catVarValid = (categoryVar != nil) == (plotType.nVars > plotType.nAxis) // If there are more vars than axes, then one var must be a category (except for with contours)
            var3Valid = (var3 != nil) == (plotType.nAxis >= 3)
        }
        guard condValid else { throw TZOutputError.IncorrectConditionSettingError }
        guard var1Valid else { throw TZOutputError.IncorrectVarSettingError }
        guard var2Valid else { throw TZOutputError.IncorrectVarSettingError }
        guard var3Valid else { throw TZOutputError.IncorrectVarSettingError }
        guard catVarValid else { throw TZOutputError.IncorrectVarSettingError }
    }
    
    func getData() throws -> OutputDataSetLines? {
        guard let curTraj = curTrajectory else { throw TZOutputError.MissingTrajectoryError }
        var lineSet = OutputDataSetLines()
        if plotType.requiresCondition {
            guard let condStates = curTraj[condition!] else {
                throw TZOutputError.UnmatchedConditionError }
            if var1 != nil { lineSet.var1 = condStates[var1!.id]! }
            if var2 != nil { lineSet.var2 = condStates[var2!.id]! }
            if var3 != nil { lineSet.var3 = condStates[var3!.id]! }
            return lineSet
        } else if categoryVar == nil {
            if var1 != nil { lineSet.var1 = curTraj[var1!.id]?.value }
            if var2 != nil { lineSet.var2 = curTraj[var2!.id]?.value }
            if var3 != nil { lineSet.var3 = curTraj[var3!.id]?.value }
            return lineSet
        } else { return nil } // TODO: Implement category variables
    }

}


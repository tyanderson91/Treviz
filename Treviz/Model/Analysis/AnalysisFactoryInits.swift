//
//  AnalysisFactoryInits.swift
//  Treviz
//
//  This file contains initializers for components of analysis that reference other components
//  Used when initializing an analysis from file and all you have is ID references to existing components (such as Conditions)
//
//  Created by Tyler Anderson on 5/17/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension Condition {
    convenience init?(decoder: Decoder, referencing analysis: Analysis) {
        do {
            try self.init(from: decoder)
            let container = try decoder.container(keyedBy: Condition.CodingKeys.self)
            let conditionNames = try container.decode(Array<String>.self, forKey: .conditions)
            for thisConditionName in conditionNames {
                if let thisCondition = analysis.conditions.first(where: {$0.name == thisConditionName} ) {
                    self.conditions.append(thisCondition)
                } else {
                    let logmessage = String(format: "Could not find constituent condition '%s' of condition '%s'", thisConditionName, self.name) // TODO: Make sure that conditions can be read in any order so that an error is not thrown for referencing a condition to be read later
                    analysis.logMessage(logmessage)
                }
            }
        } catch {
            analysis.logMessage("Error when reading condition")
            return nil
        }
    }
}

extension TZOutput {
    convenience init?(decoder: Decoder, referencing analysis: Analysis) {
        do {
            try self.init(from: decoder)
            let existingIDs = analysis.plots.compactMap {$0.id}
            if existingIDs.contains(self.id) { throw TZOutputError.DuplicateIDError }
            let container = try decoder.container(keyedBy: TZOutput.CodingsKeys.self)
            
            if true {
                let var1ID = try container.decode(String.self, forKey: .var1)
                var1 = analysis.varList.first(where: {$0.id == var1ID})
            }
            if plotType.nAxis >= 2 {
                let var2ID = try container.decode(String.self, forKey: .var2)
                var2 = analysis.varList.first(where: {$0.id == var2ID})
            }
            if plotType.nAxis >= 3 {
                let var3ID = try container.decode(String.self, forKey: .var3)
                var3 = analysis.varList.first(where: {$0.id == var3ID})
            }
            if (plotType.nVars > plotType.nAxis) && (plotType.id != "contour2d ") {
                //let categoryVarID = try container.decode(String.self, forKey: .catVar)
                //categoryVar = analysis.varList.first(where: {$0.id == categoryVarID}) // TODO: Make a way of accessing this
            }
            
            if self.plotType.requiresCondition {
                let conditionName = try container.decode(String.self, forKey: .condition)
                if let thisCondition = analysis.conditions.first(where: {$0.name == conditionName}) {
                    self.condition = thisCondition
                } else {
                    let logmessage = String(format: "Could not find condition '%s' referenced in output '%s'", conditionName, self.title)
                    analysis.logMessage(logmessage)
                }
            }
        } catch {
            analysis.logMessage("Error when reading output: \(error.localizedDescription)")
            return nil
        }
    }
}


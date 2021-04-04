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
            let simpleIO : Bool = decoder.userInfo[.simpleIOKey] as? Bool ?? false
            let container = try decoder.container(keyedBy: Condition.CodingKeys.self)
            var conditionNames: [String]
            if simpleIO {
                try self.init(from: decoder)
                conditionNames = conditions.compactMap({
                    guard let thisCond = $0 as? Condition else { return nil }
                    return thisCond.name
                })
                self.conditions.removeAll(where: {$0 is Condition})
            } else {
                try self.init(from: decoder)
                conditionNames = (try? container.decode(Array<String>.self, forKey: .conditions)) ?? []
            }
            for thisConditionName in conditionNames {
                if let thisCondition = analysis.conditions.first(where: {$0.name == thisConditionName} ) {
                    self.conditions.append(thisCondition)
                } else {
                    let logmessage = String(format: "Could not find constituent condition '%s' of condition '%s'", thisConditionName, self.name)
                    analysis.logMessage(logmessage)
                }
            }
        } catch {
            var strName : String
            do {
                let strCont = try decoder.singleValueContainer()
                let strDict = try strCont.decode([String:String].self)
                strName = strDict.keys.first!
            }
            catch {
                strName = "<Unknown>" //TODO: Find a way to extract the condition name for compound conditions to write to the error message
            }
            analysis.logMessage("Error when reading condition '\(strName)': \(error.localizedDescription)")
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
                    //let logmessage = String(format: "Could not find condition '%s' referenced in output '%s'", conditionName, self.title)
                    //analysis.logMessage(logmessage)
                }
            }
        } catch {
            analysis.logMessage("Error when reading output: \(error.localizedDescription)")
            return nil
        }
    }
}

extension TZPhase {
    convenience init?(decoder: Decoder, referencing analysis: Analysis) {
        do {
            try self.init(from: decoder)
            self.analysis = analysis
            let container = try decoder.container(keyedBy: TZPhase.CodingKeys.self)
            if container.contains(.vehicle) {
                let vehicleID = try container.decode(String.self, forKey: .vehicle)
                self.vehicle = self.analysis.vehicles.first(where: {$0.id == vehicleID})
            } else { self.vehicle = Vehicle() }
            let terminalConditionName = try container.decode(String.self, forKey: .terminalCondition)
            terminalCondition = analysis.conditions.first { $0.name == terminalConditionName }
        } catch {
            analysis.logMessage("Error when reading phase: \(error.localizedDescription)")
            return nil
        }
    }
}

extension RunVariant {
    convenience init?(decoder: Decoder, referencing analysis: Analysis) {
        do {
            try self.init(from: decoder)
            let container = try decoder.container(keyedBy: RunVariant.CodingKeys.self)
            let paramID = try container.decode(ParamID.self, forKey: .paramID)
            let curList = analysis.inputSettings
            guard let matchingParam = curList.first(where: {$0.id == paramID})
            else { throw ParamIDError.UnknownParamID(paramID) }
            parameter = matchingParam
            let nominalValue = try container.decode(String.self, forKey: .nominal)
            setValue(from: nominalValue)
            if let tradeValues = try? container.decode(Array<String>.self, forKey: .tradeValues) {
                self.setTradeValues(from: tradeValues)
            }
            isActive = true
            //let vehicleID = try container.decode(String.self, forKey: .vehicleID)
        } catch {
            analysis.logMessage("Error when reading run variants: \(error.localizedDescription)")
            return nil
        }
    }
}

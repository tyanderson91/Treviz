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
    func setupFromCoder(decoder: Decoder, referencing analysis: Analysis) throws {
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
    }
    /*
    convenience init?(decoder: Decoder, referencing analysis: Analysis) {
        do {
            try self.init(from: decoder)
            try setupFromCoder(decoder: decoder, referencing: analysis)
            //let vehicleID = try container.decode(String.self, forKey: .vehicleID)
        } catch {
            analysis.logMessage("Error when reading run variants: \(error.localizedDescription)")
            return nil
        }
    }*/
}

extension Analysis {
    func processVariantType( curRunVariants: inout UnkeyedDecodingContainer, type: RunVariantType?, simpleIO: Bool) throws {
        var runVariantsTemp = curRunVariants
        var tradeGroupnum = 0
        
        while(!curRunVariants.isAtEnd)
        {   var runVariantCopy = curRunVariants
            let output = try curRunVariants.nestedContainer(keyedBy: RunVariant.CodingKeys.self)
            
            if let paramID = try? output.decode(ParamID.self, forKey: .paramID) {// Start reading individual variants
                var newVariant : RunVariant?
                let curDecoder = try runVariantsTemp.superDecoder()
                
                if let matchingParam = self.inputSettings.first(where: {$0.id == paramID}) {
                    newVariant?.parameter = matchingParam
                    if matchingParam is Variable {
                        newVariant = VariableRunVariant.init(decoder: curDecoder, referencing: self)
                    } else if matchingParam is NumberParam {
                        newVariant = SingleNumberRunVariant.init(decoder: curDecoder, referencing: self)
                    } else if matchingParam is EnumGroupParam {
                        newVariant = EnumGroupRunVariant.init(decoder: curDecoder, referencing: self)
                        newVariant?.options = (matchingParam as? EnumGroupParam)?.options ?? []
                    } else if matchingParam is BoolParam {
                        newVariant = BoolRunVariant.init(decoder: curDecoder, referencing: self)
                    } else {
                        continue
                    }
                }
                if type != nil { newVariant?.variantType = type! }
                if newVariant?.variantType == .montecarlo {
                    guard var mcVariant = newVariant as? MCRunVariant else { continue } // TODO: error handling
                    if let distribution = try? output.decode(String.self, forKey: .distribution) { mcVariant.distributionType = DistributionType(rawValue: distribution) ?? .uniform }
                    if let min = try? output.decode(VarValue.self, forKey: .min) { mcVariant.min = min }
                    if let max = try? output.decode(VarValue.self, forKey: .max) { mcVariant.max = max }
                    if let mean = try? output.decode(VarValue.self, forKey: .min) { mcVariant.mean = mean }
                    if let stdev = try? output.decode(VarValue.self, forKey: .sigma) { mcVariant.sigma = stdev }
                }
                if newVariant != nil { runVariants.append(newVariant!) }
            }//End reading individual variants
            else if type == .trade, simpleIO, let tradeGroupDecoder = try? runVariantCopy.superDecoder() {
                let singValCont = try tradeGroupDecoder.singleValueContainer()
                let tradeGroupDict = try singValCont.decode(Dictionary<String,[ParamID:String]>.self)
                let groupName = tradeGroupDict.keys.first!
                let paramValDict = tradeGroupDict.values.first!
                
                for (paramID, val) in paramValDict {
                    var curVariant: RunVariant!
                    if let matchingVariant = runVariants.first(where: {$0.paramID == paramID}) {
                        curVariant = matchingVariant
                    } else if let matchingParam = self.inputSettings.first(where: {$0.id == paramID}) {
                        if matchingParam is Variable {
                            curVariant = VariableRunVariant(param: matchingParam)!
                        } else if matchingParam is NumberParam {
                            curVariant = SingleNumberRunVariant(param: matchingParam)!
                        } else if matchingParam is EnumGroupParam {
                            curVariant = EnumGroupRunVariant(param: matchingParam)!
                            curVariant.options = (matchingParam as? EnumGroupParam)?.options ?? []
                        } else if matchingParam is BoolParam {
                            curVariant = BoolRunVariant(param: matchingParam)!
                        } else {
                            continue
                        }
                        curVariant.variantType = .trade
                        curVariant.isActive = true
                        runVariants.append(curVariant)
                    } else {
                        continue
                    }
                    if curVariant.tradeValues.count == tradeGroupnum {
                        let newVal = curVariant.parameter.valueSetter(string: val)
                        curVariant.tradeValues.append(newVal)
                    } else { // TODO: find more robust way of handling mismatched groups
                        curVariant.isActive = false
                        curVariant.tradeValues = []
                    }
                }
                var newGroup = RunGroup(name: groupName)
                newGroup._didSetDescription = true
                tradeGroups.append(newGroup)
                tradeGroupnum += 1
            }// End custom trade group reading
        }
    }// End of function definition
}

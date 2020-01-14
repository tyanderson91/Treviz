//
//  Condition.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/28/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Foundation
import Cocoa

protocol EvaluateCondition {
    func evaluate(_ state: State)
    func evaluate(_ singleState: StateArray)->Bool
    func reset(initialState: StateArray?)
    var meetsCondition : [Bool]? {get set}
    var summary : String {get}
    // var isSinglePoint : Bool {get set}// Boolean to tell whether the condition should return a single point per trajectory (such as terminal condition, max/min, etc
}

/**
 Booltype represents the different ways that conditions can be combined
 Rawvalue is set to indew to allow for easy integration with dropdown menus
*/
enum BoolType : Int {
    case single = 0
    case and = 1
    case or = 2
    case nor = 3
    case nand = 4
    case xor = 5
    case xnor = 6

    static func fromStr(_ input: String)->BoolType?{ //TODO: turn this into an init
        let returnDict : Dictionary<String, BoolType> = ["single": .single, "and": .and, "or": .or, "nor": .nor, "nand": .nand, "xor": .xor, "xnor": .xnor]
        if let returnBool = returnDict[input] {
            return returnBool
        } else {return nil}
    }
    func stringValue()->String{
        let returnDict : Dictionary<BoolType, String> = [.single: "single", .and: "and", .or: "or", .nor: "nor", .nand: "nand", .xor: "xor", .xnor: "xnor"]
        return returnDict[self]!
    }
}
/**
 Special conditions are conditions unique to a particular variable
 Rawvalue is set to indew to allow for easy integration with dropdown menus
*/
enum SpecialConditionType : Int {
    case localMax = 0
    case localMin = 1
    case globalMax = 2
    case globalMin = 3
    
    static func fromStr(_ input: String)->SpecialConditionType?{ //TODO: turn this into an init
        let returnDict : Dictionary<String, SpecialConditionType> = ["max": .globalMax, "global max": .globalMax, "min": .globalMin, "global min": .globalMin, "local max": .localMax, "local min": .localMin]
        if let returnBool = returnDict[input] {
            return returnBool
        } else {return nil}
    }
    
    func asString()->String{
        let returnDict : Dictionary<SpecialConditionType, String> = [.globalMax: "Max", .globalMin: "Min", .localMax: "Local Max", .localMin: "Local Min"]
        return returnDict[self]!
    }
}

class SingleCondition: NSObject, EvaluateCondition {
    var varID : VariableID!
    var lbound : VarValue?
    var ubound : VarValue?
    var equality : VarValue?
    var specialCondition : SpecialConditionType?
    var meetsCondition : [Bool]?
    // var isSinglePoint: Bool = false
    var varPosition : Int? // Position of the current variable in the index of StateVarPositions (automatically assigned, speeds up performance)
    var summary: String {
        var dstring = ""
        if equality != nil {
            dstring += "\(varID ?? "")=\(equality!)"
        } else if let sc = specialCondition {
            dstring += sc.asString()
        } else {
            let lbstr = lbound == nil ? "" : "\(lbound!) < "
            let ubstr = ubound == nil ? "" : " < \(ubound!)"
            dstring += lbstr + "\(varID ?? "")" + ubstr
        }
        return dstring
    }
    
    private var previousState : VarValue! // For use in equality type or special case lookups
    private var nextState: VarValue! // For use in special case lookups, e.g. local min
    var tests : [(VarValue)->Bool] {
        var _tests : [(VarValue)->Bool] = []
        if let lower = lbound {
            _tests.append {$0 > lower }
        }; if let upper = ubound {
            _tests.append {$0 < upper }
        }
        if let eq = equality {
            _tests = [{ ($0-eq).sign != (self.previousState-eq).sign }]
        }
        if let spc = specialCondition {
            if spc == .localMin {
                _tests.append { $0 < self.nextState && $0 < self.previousState}
            }
            if spc == .localMax {
                _tests.append { $0 > self.nextState && $0 > self.previousState}
            }
        }
        return _tests
    }
    
    override init(){
        self.varID = nil
        super.init()
    }
    
    init(_ vid: VariableID){
        varID = vid
        super.init()
    }
    
    init(_ vid: VariableID, upperBound: VarValue? = nil, lowerBound: VarValue? = nil, equality eq: VarValue? = nil, specialCondition spc: SpecialConditionType? = nil){
        varID = vid
        lbound = lowerBound
        ubound = upperBound
        equality = eq
        specialCondition = spc
        super.init()
    }
    
    func evaluate(_ state: State){
        let thisVariable = state[varID]
        meetsCondition = Array(repeating: false, count: thisVariable.value.count)
        previousState = thisVariable[0]
        nextState = thisVariable[1]
        if specialCondition == .globalMax || specialCondition == .globalMin {
            var val : VarValue = 0
            switch specialCondition {
            case .globalMax:
                val = thisVariable.value.max()!
            case .globalMin:
                val = thisVariable.value.min()!
            default:
                return
            }
            let valIndex = thisVariable.value.firstIndex(where: { $0 == val})
            meetsCondition![valIndex!] = true
        }
        else {
            var i = 0
            for thisVal in thisVariable.value {
                var isCondition : Bool = true
                for thisTest in tests {
                    isCondition = isCondition && thisTest(thisVal)
                }
                if isCondition {
                    meetsCondition![i] = true
                }
                if equality != nil || specialCondition != nil {
                    previousState = thisVal
                    nextState = (i < thisVariable.value.count - 1) ? thisVariable[i+1] : thisVal
                }
                i+=1
            }
        }
    }
    func evaluate(_ singleState: StateArray)->Bool{ // TODO: get rid of this, it cant handle derived states like AoA
        if varPosition == nil {varPosition = State.stateVarPositions.firstIndex(where: {$0 == varID} ) }
        let thisVal = singleState[varPosition!]
        var isCondition = true
        for thisTest in tests {
            isCondition = isCondition && thisTest(thisVal)
        }
        return isCondition
    }

    func reset(initialState: StateArray? = nil){
        if varPosition == nil {varPosition = State.stateVarPositions.firstIndex(where: {$0 == varID} ) }
        if initialState != nil {let thisVal = initialState![varPosition!]
            previousState = thisVal
            nextState = thisVal
        }
        meetsCondition = nil
    }
}


class Condition : NSObject, EvaluateCondition {
    
    @objc var name : String = ""
    var conditions : [EvaluateCondition] = []
    var unionType : BoolType = .single
    var meetsCondition : [Bool]? // TODO: Move this out of the Conditions object
    var meetsConditionIndex : [Int] { // Converts array of bools into indices
        var i = 0
        var indices = [Int]()
        for thisBool in meetsCondition ?? [] {
            if thisBool { indices.append(i)}
            i += 1
        }
        return indices
    }
    private var _summary = ""
    @objc dynamic var summary : String {
        get {
            if _summary != "" {return _summary}
            var dstring = ""
            var dstrings = [String]()
            for thisCond in self.conditions {
                dstring = thisCond.summary
                if let cond = thisCond as? Condition {
                    if cond.conditions.count > 1 { dstring = "(" + dstring + ")" }
                }
                dstrings.append(dstring)
            }
            let combinedString = dstrings.joined(separator: " \(unionType.stringValue()) ")
            return combinedString
        } set { _summary = newValue }
    }
    
    /*
    var isSinglePoint: Bool {
        get {
            return conditions.filter( { $0.isSinglePoint } ).count > 0
        } set (newVal) {
            for thisCondition in self.conditions {
                var thisCondition1 = thisCondition
                thisCondition1.isSinglePoint = newVal
            }
        }
    }*/
    
    override init(){
        super.init()
    }

    init(_ varid: VariableID, upperBound: VarValue? = nil, lowerBound: VarValue? = nil, equality: VarValue? = nil){
        let newCondition = SingleCondition(varid, upperBound: upperBound, lowerBound: lowerBound, equality: equality)
        conditions = [newCondition]
        super.init()
    }
    
    init(conditions condIn: [EvaluateCondition], unionType unTypeIn: BoolType, name nameIn: String) { //}, isSinglePoint singlePointIn: Bool = false) {
        conditions = condIn
        unionType = unTypeIn
        name = nameIn
        super.init()
        // self.isSinglePoint = singlePointIn
    }

    /**
     Creates a single Condition from a Dictionary of the type that a yaml file can read. This dict can take two forms. In both forms, the condition name is the key. The simplest form is for a single condition. In this form the value string describes the condition, e.g."'x=5" or "2\<y\<10"> or "q is maximum"
     The string must meet three criteria: 1) it includes a single valid variable identifier, 2) it includes one of the comparison symbols (=, <, >, or 'is'), and 3) It has one or two numbers (or special conditions, e.g. global max, local min) to compare against
     - Parameter yamlObj: a Dictionary of the type [String: String] read from a yaml file.
     */
    convenience init?(fromYaml yamlObj: [String: Any], inputConditions: [Condition] = []){
        //if yamlObj.count > 1 { return nil }
        if yamlObj.count == 1 {
            let conditionName = yamlObj.keys.first!
            guard let valstr = yamlObj.values.first as? String else {return nil}
           
            let capturestr = #"(?:(?<lowerBound>[0-9\.-]+) ?(?<lowerSign>[\<\>]))?(?<varID>[\w ]+)(?<sign>[\<\>]|=|is) ?(?<upperBound>[0-9\.-]+|[a-zA-Z]+)"#
            guard let regex = try? NSRegularExpression(pattern: capturestr, options: []) else { return nil }
            let match = regex.firstMatch(in: valstr, options: [], range: NSRange(valstr.startIndex..<valstr.endIndex, in: valstr))
            guard match != nil else { return nil } // No match found
           
            var componentDict = Dictionary<String, String>()
            for component in ["lowerBound","lowerSign","sign","varID","upperBound"] {
                if let curRange = Range((match!.range(withName: component)), in: capturestr){
                    let curVal = valstr[curRange]
                    componentDict[component] = String(curVal)
                }
            }
           
            let varID = componentDict["varID"]!
            let newSingleCondition = SingleCondition(varID)
           
            let ub = componentDict["upperBound"]!
           
     
            let lb : VarValue? = {
                if componentDict.keys.contains("lowerBound") { return VarValue(componentDict["lowerBound"]!) }
                else { return nil }
            }()
     
            switch componentDict["sign"]{
            case "<":
                newSingleCondition.ubound = VarValue(ub)
                newSingleCondition.lbound = lb
            case ">":
                newSingleCondition.ubound = lb
                newSingleCondition.lbound = VarValue(ub)
            case "=":
                newSingleCondition.equality = VarValue(ub)
            case "is":
                if let specialCond = SpecialConditionType.fromStr(ub){
                    newSingleCondition.specialCondition = specialCond
                } else {return nil}
            default:
                return nil
            }
           
            self.init(conditions: [newSingleCondition], unionType: .single, name: conditionName)
        } // End of single-line definition
        else {
            var curConditions: [Condition] = []
            var condName = ""
            var utype: BoolType!
            for (thisKey, thisVal) in yamlObj {
                if thisKey == "conditions", let condList = thisVal as? [String]{
                    curConditions = condList.compactMap( { (condName: String)->Condition? in
                        return inputConditions.first { $0.name == condName } } )
                    if curConditions.count != condList.count { return nil }
                } else if thisKey == "union", let ustr = thisVal as? String{
                    guard let utype1 = BoolType.fromStr(ustr) else {return nil}
                    utype = utype1
                } else {
                    condName = thisKey
                }
            }
            self.init(conditions: curConditions, unionType: utype, name: condName)
        }
        
    }
    
    
    func comparator(_ num1: Bool, _ num2: Bool)->Bool {
        switch unionType {
        case .single: return num1
        case .and: return num1 && num2
        case .or: return num1 || num2
        case .nor: return !(num1 || num2)
        case .nand: return !(num1 && num2)
        case .xor: return num1 != num2
        case .xnor: return num1 == num2
        }
    }
    
    func compareLists(_ list1: [Bool]?, _ list2: [Bool])->[Bool]{
        if list1 == nil{
            return list2
        }
        let n = list2.count
        guard list1!.count == n else {
            print("Lists do not have the same length. Cannot perform comparison")
            return [false]
        }
        var returnList : [Bool] = Array<Bool>.init(repeating: false, count: n)
        for i in 0...n-1 {
            returnList[i] = comparator(list1![i], list2[i])
        }
        return returnList
    }
    
    func evaluate(_ state: State) {
        self.meetsCondition = nil
        for thisCondition in conditions{
            thisCondition.evaluate(state)
            self.meetsCondition = compareLists(self.meetsCondition, thisCondition.meetsCondition!)
        }
    }
    
    func evaluateSingle(_ state: State)->Bool{ // TODO: get rid of this if it is not in use
        evaluate(state)
        if self.meetsCondition!.count == 1 {return self.meetsCondition![0]}
        else {return false}
    }

    func evaluate(_ singleState: StateArray)->Bool { //Only use this if ALL states can be put into the State Array
        var curMeetsCondition = conditions[0].evaluate(singleState)
        for thisCondition in conditions.dropFirst(){
            let thisMeetsCondition = thisCondition.evaluate(singleState)
            curMeetsCondition = comparator(curMeetsCondition, thisMeetsCondition)
        }
        return curMeetsCondition
    }
    
    /**
     Reset all temporary values stored in the condition to make it suitable for restarting analysis
     */
    func reset(initialState: StateArray? = nil){
        meetsCondition = nil
        for thisCondition in conditions {
            thisCondition.reset(initialState: initialState)
        }
    }
}

//
//  Condition.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/28/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Foundation
import Cocoa

/**
 EvaluateCondition is a protocol that is adopted by both the Condition and SingleCondition classes. The basic feature is that it can read a state and determine whether it meets a given condition based on some predefined rules
 */
protocol EvaluateCondition : Codable, NSCopying {
    /**
     Evaluate a trajectory (state) by the condition. Stores the result in the condition's "meetsCondition"
     */
    func evaluateState(_ state: State)
    func evaluateSingleState(_ singleState: StateDictSingle) throws->Bool
    /**
     Reset all temporary variables to prepare condition to be used at the start of an analysis
     */
    func reset(initialState: StateDictSingle?)
    var meetsCondition : [Bool]? {get set}
    var summary : String {get}
    var subConditionCount : Int {get}
    func isValid() -> Bool
}

/**
 Booltype represents the different ways that conditions can be combined
 Raw value is set to index to allow for easy integration with dropdown menus
*/
enum BoolType : String, Codable {
    case single
    case and
    case or
    case nand
    case nor
    case xor
    case xnor

    static let stringDict : Dictionary<String, BoolType> = ["single": .single, "and": .and, "or": .or, "nor": .nor, "nand": .nand, "xor": .xor, "xnor": .xnor]
}

/**
 Special conditions are conditions unique to a particular variable
 Rawvalue is set to int to allow for easy integration with dropdown menus
 Note that local max and local min can be evaluated during a trajectory, which makes them suitable for use as terminal conditions in an analysis. Global Max and Global Min require a complete trajectory to be known, so they can only be used in output plots
*/
enum SpecialConditionType : Int, CustomStringConvertible, Codable {
    
    case localMax = 0
    case localMin = 1
    case globalMax = 2
    case globalMin = 3
    
    var description: String {
        let returnDict : Dictionary<SpecialConditionType, String> = [.globalMax: "global max", .globalMin: "global min", .localMax: "local max", .localMin: "local min"]
        return returnDict[self]!
    }

    /**
     Initialization from human-readable strings. Note that inputs "max" and "min" will default to local max and local min, respectively, to maximize flexibility
     */
    init?(_ input: String) {
        let stringDict: Dictionary<String, SpecialConditionType> = ["max": .localMax, "global max": .globalMax, "min": .localMin, "global min": .globalMin, "local max": .localMax, "local min": .localMin]
        if let type = stringDict[input] { self = type }
        else {return nil}
    }
}

extension NSNotification.Name {
    static let didAddCondition = Notification.Name("didAddCondition")
    static let didRemoveCondition = Notification.Name("didRemoveCondition")
}

/**
 A SingleCondition is the basic unit of condition evaluations. It provides a mechanism to determine if an individual variable meets some numerical condition, either at a single point in a trajectory or at all points
 */
class SingleCondition: EvaluateCondition, Codable {
    
    var varID : ParamID!
    // A SingleCondition should take one of three forms: Interval (lower bound and/or upper bound), equality, or special (see above). If type is set, then unset the others
    // TODO: Allow for specification of units
    var lbound : VarValue? { didSet { if lbound != nil {
            equality = nil
            specialCondition = nil
            setTests()
        } } }
    var ubound : VarValue?  { didSet { if ubound != nil {
                equality = nil
                specialCondition = nil
                setTests()
        } } }
    var equality : VarValue?  { didSet { if equality != nil {
                ubound = nil
                lbound = nil
                specialCondition = nil
                setTests()
        } } }
    var specialCondition : SpecialConditionType?  { didSet { if specialCondition != nil {
                equality = nil
                lbound = nil
                ubound = nil
                setTests()
           } } }
    var meetsCondition : [Bool]? // Temporary storage for the result of the condition evaluation
    var summary: String {
        guard self.isValid() else { return "[invalid]"}
        var dstring = ""
        let varstr =  "\(varID!)"
        if equality != nil {
            let eqstring = String(format: "%g", arguments: [equality!])
            dstring = "\(varstr)=\(eqstring)"
        } else if let sc = specialCondition {
            dstring = String(describing: sc) + " \(varstr)"
        } else if lbound != nil || ubound != nil {
            let ubstr = ubound == nil ? "" : "<\(String(format: "%g", arguments: [ubound!]))"
            let lbstr = lbound == nil ? "" : "\(String(format: "%g", arguments: [lbound!]))"
            let lbCompareStr = lbstr == "" ? "" : "<"
            if ubstr == "" {
                dstring = varstr + ">" + lbstr
            } else {
                dstring = lbstr + lbCompareStr + varstr + ubstr
            }
        }
        return dstring
    }
    var subConditionCount: Int { return 1 }
    
    private var previousState : VarValue! // For use in equality type or special case lookups
    private var nextState: VarValue! // For use in special case lookups, e.g. local min
    private var tests: [(VarValue, VarValue?, VarValue?)->Bool] = []// Takes in current value, next value, and previous value in that order and ouputs a bool saying whether that point meets the condition
    func setTests(){
        self.tests = []
        if let spc = specialCondition {
            if spc == .localMin {
                tests = [{ $0 < $1! && $0 < $2! }]
            }
            if spc == .localMax {
                tests = [{ $0 > $1! && $0 > $2! }]
            }
        } else if let eq = equality {
            tests = [{ ($0-eq).sign != ($2!-eq).sign }]
        } else {
            if let lower = lbound {
                tests.append({(curVal: VarValue, prevVal: VarValue?, nextVal: VarValue?)->Bool in
                return curVal > lower
                })
            }
            if let upper = ubound {
                tests.append({(curVal: VarValue, prevVal: VarValue?, nextVal: VarValue?)->Bool in
                return curVal < upper
                })
            }
        }
    }
    
    init(){
    }
    
    init(_ vid: ParamID){
        varID = vid
    }
    
    init(_ vid: ParamID, upperBound: VarValue? = nil, lowerBound: VarValue? = nil, equality eq: VarValue? = nil, specialCondition spc: SpecialConditionType? = nil){
        varID = vid
        lbound = lowerBound
        ubound = upperBound
        equality = eq
        specialCondition = spc
        setTests()
    }
    
    // MARK: Codable implementation
    enum CodingKeys: CodingKey {
        case lbound
        case ubound
        case equality
        case specialCondition
        case varID
    }
    
    /**
     Creates a single condition based on a string used in the YAML format, such as "x < 4" or "Y is Local Maximum"
     */
    init(summaryString valstr: String) throws {
        //let capturestr = #"(?:(?<lowerBound>[0-9\.-]+) ?(?<lowerSign>[\<\>]))?(?<varID>[\w ]+)(?<sign>[\<\>]|=| is ) ?(?<upperBound>[0-9\.-]+|[a-zA-Z ]+)"#
        let capturestr = #"(?:(?<lowerBound>[0-9\.-]+) ?(?<lowerSign>[\<\>]))?(?<special>[GgLl]+o[cb]al [Mm][axin]+)? ?(?<varID>[\w]+) ?(?<sign>[\<\>]|=)? ?(?<upperBound>[0-9\.-]+)?"#
        guard let regex = try? NSRegularExpression(pattern: capturestr, options: []) else { return }
        let match = regex.firstMatch(in: valstr, options: [], range: NSRange(valstr.startIndex..<valstr.endIndex, in: valstr))
        guard match != nil else { throw ConditionError.unparsableText(valstr) } // No match found
       
        var componentDict = Dictionary<String, String>()
        for component in ["lowerBound","lowerSign","special","sign","varID","upperBound"] {
            if let curRange = Range((match!.range(withName: component)), in: capturestr){
                let curVal = valstr[curRange]
                componentDict[component] = String(curVal)
            }
        }
        guard componentDict.count >= 2
        else {
            throw ConditionError.unparsableText(valstr)
        }
        
        varID = componentDict["varID"]!
       
        if let ub = componentDict["upperBound"] {
            let lb : VarValue? = {
                if componentDict.keys.contains("lowerBound") { return VarValue(componentDict["lowerBound"]!) }
                else { return nil }
            }()
     
            switch componentDict["sign"]{
            case "<":
                ubound = VarValue(ub)
                lbound = lb
            case ">":
                lbound = VarValue(ub)
                ubound = lb
            case "=":
                equality = VarValue(ub)
            default:
                return
            }
        } else if let special = componentDict["special"] {
            specialCondition = SpecialConditionType(special.lowercased())
        } else { return }
    }
    
    required convenience init(from decoder: Decoder) throws {
        let simpleIO : Bool = decoder.userInfo[.simpleIOKey] as? Bool ?? false
        if simpleIO {
            guard let singleCondContainer = try? decoder.singleValueContainer() else { throw ConditionError.unknownIO }
            let valstr = try singleCondContainer.decode(String.self)
            try self.init(summaryString: valstr)
        } else {
            self.init()
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do {lbound = try container.decode(VarValue.self, forKey: .lbound)} catch {lbound = nil}
            do {ubound = try container.decode(VarValue.self, forKey: .ubound)} catch {ubound = nil}
            do {equality = try container.decode(VarValue.self, forKey: .equality)} catch {equality = nil}
            do {specialCondition = try container.decode(SpecialConditionType.self, forKey: .specialCondition)} catch {specialCondition = nil}
            varID = try container.decode(ParamID.self, forKey: .varID)
        }
        setTests()
    }
    
    func encode(to encoder: Encoder) throws {
        let simpleIO : Bool = encoder.userInfo[.simpleIOKey] as? Bool ?? false
        if simpleIO {
            var container = encoder.unkeyedContainer()
            try container.encode(summary)
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(varID, forKey: .varID)
            if specialCondition != nil {
                try container.encode(specialCondition, forKey: .specialCondition)
            } else if equality != nil {
                try container.encode(equality, forKey: .equality)
            } else {
                if ubound != nil { try container.encode(ubound, forKey: .ubound) }
                if lbound != nil { try container.encode(lbound, forKey: .lbound) }
            }
        }
    }
    
    //MARK: Evaluation functions
    func evaluateState(_ state: State){
        //let thisVariable = state[varID]
        guard let thisVariable = state[varID] else { return }
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
                if equality != nil || specialCondition != nil {
                    previousState = (i > 0) ? thisVariable[i-1] : thisVal
                    nextState = (i < thisVariable.value.count - 1) ? thisVariable[i+1] : thisVal
                }
                var isCondition : Bool = true
                for thisTest in tests {
                    let curTest = thisTest
                    let tv = thisVal
                    let ns = self.nextState
                    let ps = self.previousState
                    isCondition = isCondition && curTest(tv, ns ?? nil, ps)
                }
                if isCondition {
                    meetsCondition![i] = true
                }
                i+=1
            }
        }
    }
    
    func evaluateSingleState(_ singleState: StateDictSingle) throws->Bool{
        let thisVal = singleState[varID]!
        var isCondition = true
        if specialCondition == .localMin || specialCondition == .localMax {
            guard previousState != nil else { throw ConditionError.unsetPreviousValue }
            guard nextState != nil else { throw ConditionError.unsetNextValue }
            let oldState = nextState!
            nextState = thisVal
            isCondition = tests[0](oldState, self.nextState, self.previousState)
            previousState = oldState
        } else if equality != nil {
            guard previousState != nil else { throw ConditionError.unsetPreviousValue }
            //guard nextState != nil else { throw ConditionError.unsetNextValue }
            isCondition = isCondition && tests[0](thisVal, self.nextState, self.previousState)
            previousState = thisVal
        } else if ubound != nil || lbound != nil {
            for thisTest in tests {
                isCondition = isCondition && thisTest(thisVal, self.nextState, self.previousState)
            }
        } else if specialCondition == .globalMin || specialCondition == .globalMax {
            throw ConditionError.singleGlobalEvaluation
        }
        return isCondition
    }

    func reset(initialState: StateDictSingle? = nil){
        if initialState == nil {
            previousState = nil
            nextState = nil
        } else {
            let thisVal = initialState![varID]
            previousState = thisVal
            nextState = thisVal
        }
        meetsCondition = nil
    }
    
    func isValid() -> Bool {
        guard varID != nil else { return false }
        if equality != nil {
            return ubound == nil && lbound == nil && specialCondition == nil
        } else if specialCondition != nil {
            return ubound == nil && lbound == nil && equality == nil
        } else if ubound != nil || lbound != nil {
            return equality == nil && specialCondition == nil
        } else { return false }
    }
    // MARK: NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SingleCondition(self.varID, upperBound: self.ubound, lowerBound: self.lbound, equality: self.equality, specialCondition: self.specialCondition)
        return copy
    }
}

/**
The Condition class provides the mechanism to combine multiple SingleConditions or Conditions into one composite condition according to various boolean comparisons.
*/
class Condition : EvaluateCondition, Codable {
    
    @objc var name : String = ""
    var conditions : [EvaluateCondition] = []
    var unionType : BoolType = .single
    var meetsCondition : [Bool]? // TODO: Move this out of the Conditions object?
    var meetsConditionIndex : [Int] { // Converts array of bools into indices
        var i = 0
        var indices = [Int]()
        for thisBool in meetsCondition ?? [] {
            if thisBool { indices.append(i)}
            i += 1
        }
        return indices
    }
    var subConditionCount: Int {
        let subConditionCounts = conditions.map({$0.subConditionCount})
        let subConditionSum = subConditionCounts.reduce(0, +)
        return subConditionSum + 1
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
            let combinedString = dstrings.joined(separator: " \(String(describing: unionType)) ")
            return combinedString
        } set { _summary = newValue }
    }
    

    init(){
    }
    
    // MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case name
        case conditions
        case singleConditions
        case unionType = "union"
        case _summary
    }
    
    required init(from decoder: Decoder) throws {
        let simpleIO : Bool = decoder.userInfo[.simpleIOKey] as? Bool ?? false
        let deepCopy : Bool = decoder.userInfo[.deepCopyKey] as? Bool ?? false // whether to encode the whole condition, or just a referenc
        if simpleIO {
            let container = try decoder.singleValueContainer()
            do { // Try to read as a single condition, e.g. x < 2
                let singleCondDict: [String: SingleCondition] = try container.decode([String:SingleCondition].self)
                self.name = singleCondDict.keys.first!
                self.conditions = [singleCondDict.values.first!]
            } catch { // Try to read as a compound condition
                let condDict = try container.decode([String:ConditionDecodableData].self)
                self.name = condDict.keys.first!
                let condStruct = condDict.values.first!
                self.unionType = condStruct.union
                self.conditions = condStruct.conditions.map({
                    do {
                        let singleCond = try SingleCondition(summaryString: $0)
                        return singleCond
                    } catch {
                        let newCond = Condition()
                        newCond.name = $0
                        return newCond
                    }
                })
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            conditions = Array<EvaluateCondition>()
            do {
                let singleConditions = try container.decode(Array<SingleCondition>.self, forKey: .singleConditions)
                conditions.append(contentsOf: singleConditions)
            } catch { conditions = [] }
            unionType = try container.decode(BoolType.self, forKey: .unionType)
            do { _summary = try container.decode(String.self, forKey: ._summary)
            } catch { _summary = "" }
            if deepCopy {
                let fullConditions = try container.decode(Array<Condition>.self, forKey: .conditions)
                conditions.append(contentsOf: fullConditions)
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        let simpleIO : Bool = encoder.userInfo[.simpleIOKey] as? Bool ?? false
        let deepCopy : Bool = encoder.userInfo[.deepCopyKey] as? Bool ?? false // whether to encode the whole condition, or just a referenc
        
        let singleConditions = conditions.filter { $0 is SingleCondition } as? [SingleCondition] ?? []
        let conds = conditions.filter { $0 is Condition } as? [Condition] ?? []
         
        if simpleIO && conditions.count == 1 && singleConditions.count == 1 {
            let thisCond = singleConditions[0]
            var thisCont = encoder.singleValueContainer()
            try thisCont.encode(thisCond.summary)
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(unionType, forKey: .unionType)
            if _summary != "" {
                try container.encode(_summary, forKey: ._summary)
            }
            let conditionNames = conds.compactMap({$0.name})
            if simpleIO {
                var condStrs : [String] = conditionNames
                condStrs.append(contentsOf: singleConditions.map({$0.summary}))
                try container.encode(condStrs, forKey: .conditions)
            } else {
                try container.encode(name, forKey: .name)
                try container.encode(singleConditions, forKey: .singleConditions)
                if deepCopy {
                    try container.encode(conds, forKey: .conditions)
                } else {
                    try container.encode(conditionNames, forKey: .conditions)
                }
            }
        }
    }
    
    // MARK: Inits
    init(_ varid: ParamID, upperBound: VarValue? = nil, lowerBound: VarValue? = nil){
        let newCondition = SingleCondition(varid, upperBound: upperBound, lowerBound: lowerBound)
        conditions = [newCondition]
    }
    init(_ varid: ParamID, equality: VarValue){
        let newCondition = SingleCondition(varid, equality: equality)
        conditions = [newCondition]
    }
    init(_ varid: ParamID, specialCondition: SpecialConditionType){
        let newCondition = SingleCondition(varid, specialCondition: specialCondition)
        conditions = [newCondition]
    }
    
    init(conditions condIn: [EvaluateCondition], unionType unTypeIn: BoolType, name nameIn: String) {
        conditions = condIn
        unionType = unTypeIn
        name = nameIn
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
    
    /**
     Compares two different boolean lists againts each other. These lists are representative of particular conditions being met across a trajectory. If only a single list is passed (list2), it simly returns that list
     */
    private func compareLists(_ list1: [Bool]?, _ list2: [Bool])->[Bool]{
        if list1 == nil{  // If only one list is input (e.g.
            return list2
        }
        let n = list2.count
        
        assert(list1!.count == n, "Lists do not have the same length. Cannot perform comparison")
        var returnList : [Bool] = Array<Bool>.init(repeating: false, count: n)
        for i in 0...n-1 {
            returnList[i] = comparator(list1![i], list2[i])
        }
        return returnList
    }
    
    func evaluateState(_ state: State) {
        self.meetsCondition = nil
        for thisCondition in conditions{
            thisCondition.evaluateState(state)
            self.meetsCondition = compareLists(self.meetsCondition, thisCondition.meetsCondition!)
        }
    }

    func evaluateSingleState(_ singleState: StateDictSingle) throws->Bool {
        do {
            var curMeetsCondition = try conditions[0].evaluateSingleState(singleState)
            for thisCondition in conditions.dropFirst(){
                let thisMeetsCondition = try thisCondition.evaluateSingleState(singleState)
                curMeetsCondition = comparator(curMeetsCondition, thisMeetsCondition)
            }
            return curMeetsCondition
            } catch { throw error }
    }

    func reset(initialState: StateDictSingle? = nil){
        meetsCondition = nil
        for thisCondition in conditions {
            thisCondition.reset(initialState: initialState)
        }
    }
    
    /**Whether the Condition has a valid set of rules*/
    func isValid() -> Bool {
        guard name != "" else { return false }
        guard conditions.count > 0 else { return false }
        var valid = true
        for thisCond in conditions {
            valid = valid && thisCond.isValid()
        }
        return valid
    }
    
    /**
     Used to determine whether a given Condition or SingleCondition is a child of the current condition. Recursively searches sub-conditions
     */
    func containsCondition(_ inputCondition: EvaluateCondition)->Bool{
        // if self === inputCondition { return true }
        for curEvaluateCondition in self.conditions {
            if let curCondition = curEvaluateCondition as? Condition {
                if curCondition === (inputCondition as? Condition) { return true }
                else if curCondition.containsCondition(inputCondition) { return true }
            }
            else if let curSingleCondition = curEvaluateCondition as? SingleCondition {
                if curSingleCondition === (inputCondition as? SingleCondition) { return true }
            }
        }
        return false
    }
    
    /**Determines whether any children use Global Max or Global Min, making them unsuitable for use in terminal conditions*/
    func containsGlobalCondition()->Bool{
        for curCondition in self.conditions {
            if let specialCondition = (curCondition as? SingleCondition)?.specialCondition {
                if specialCondition == .globalMax || specialCondition == .globalMin { return true }
            }
            else if curCondition is Condition {
                if (curCondition as! Condition).containsGlobalCondition() { return true }
            }
        }
        return false
    }
    
    // MARK: NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Condition(conditions: [], unionType: self.unionType, name: self.name)
        for thisCond in self.conditions {
            copy.conditions.append(thisCond.copy(with: zone) as! EvaluateCondition)
        }
        return copy
    }
}

/**Required at the Analysis level to decode data in the simplified format used by the YAML decoder*/
struct ConditionDecodableData: Decodable {
    let conditions: [String]
    let union: BoolType
    let summary: String?
}

enum ConditionError: Error {
    case InvalidComparison(_ message: String)
    case unsetPreviousValue
    case unsetNextValue
    case singleGlobalEvaluation
    case variableNotFound
    case unparsableText(_ messange: String)
    case unknownIO
}

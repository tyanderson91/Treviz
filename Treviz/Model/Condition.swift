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
 EvaluateCondition is a protocol that is adopted by bothe the Condition and SingleCondition classes. The basic feature is that it can read a state and determine whether it meets a given condition based on some predefined rules
 */
@objc protocol EvaluateCondition : NSCoding {
    /**
     Evaluate a trajectory (state) by the condition. Stores the result in the condition's "meetsCondition"
     */
    func evaluateState(_ state: State)
    func evaluateStateArray(_ singleState: StateArray)->Bool
    /**
     Reset all temporary variables to prepare condition to be used at the start of an analysis
     */
    func reset(initialState: StateArray?)
    var meetsCondition : [Bool]? {get set}
    @objc var summary : String {get}
    // var isSinglePoint : Bool {get set}// Boolean to tell whether the condition should return a single point per trajectory (such as terminal condition, max/min, etc
}

/**
 Booltype represents the different ways that conditions can be combined
 Raw value is set to index to allow for easy integration with dropdown menus
*/
enum BoolType : Int {
    case single = 0
    case and = 1
    case or = 2
    case nand = 3
    case nor = 4
    case xor = 5
    case xnor = 6

    /**
     Initialization from human-readable strings
     */
    init?(_ input: String) {
        let stringDict : Dictionary<String, BoolType> = ["single": .single, "and": .and, "or": .or, "nor": .nor, "nand": .nand, "xor": .xor, "xnor": .xnor]
        if let type = stringDict[input] { self = type }
        else { return nil}
    }
}

/**
 Special conditions are conditions unique to a particular variable
 Rawvalue is set to int to allow for easy integration with dropdown menus
 Note that local max and local min can be evaluated during a trajectory, which makes them suitable for use as terminal conditions in an analysis. Global Max and Global Min require a complete trajectory to be known, so they can only be used in output plots
*/
enum SpecialConditionType : Int, CustomStringConvertible {
    
    case localMax = 0
    case localMin = 1
    case globalMax = 2
    case globalMin = 3
    
    var description: String {
        let returnDict : Dictionary<SpecialConditionType, String> = [.globalMax: "Global Max", .globalMin: "Global Min", .localMax: "Local Max", .localMin: "Local Min"]
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

/**
 A SingleCondition is the basic unit of condition evaluations. It provides a mechanism to determine if an individual variable meets some numerical condition, either at a single point in a trajectory or at all points
 */
class SingleCondition: NSObject, EvaluateCondition {
    var varID : VariableID!
    // A SingleCondition should take one of three forms: Interval (lower bound and/or upper bound), equality, or special (see above). If type is set, then unset the others
    var lbound : VarValue? { didSet { if lbound != nil {
            equality = nil
            specialCondition = nil
        } } }
    var ubound : VarValue?  { didSet { if ubound != nil {
                equality = nil
                specialCondition = nil
        } } }
    var equality : VarValue?  { didSet { if equality != nil {
                ubound = nil
                lbound = nil
                specialCondition = nil
        } } }
    var specialCondition : SpecialConditionType?  { didSet { if specialCondition != nil {
                equality = nil
                lbound = nil
                ubound = nil
           } } }
    var meetsCondition : [Bool]?
    var varPosition : Int? // Position of the current variable in the index of StateVarPositions (automatically assigned, speeds up performance)
    var summary: String {
        var dstring = ""
        if equality != nil {
            dstring = "\(varID ?? "")=\(equality!)"
        } else if let sc = specialCondition {
            dstring = String(describing: sc) + " \(varID ?? "")"
        } else if lbound != nil || ubound != nil {
            let varstr = "\(varID ?? "")"
            let ubstr = ubound == nil ? "" : " < \(ubound!)"
            let lbstr = lbound == nil ? "" : "\(lbound!)"
            let lbCompareStr = lbstr == "" ? "" : " < "
            if ubstr == "" {
                dstring = varstr + " > " + lbstr
            } else {
                dstring = lbstr + lbCompareStr + varstr + ubstr
            }
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
                _tests = [{ $0 < self.nextState && $0 < self.previousState }]
                //_tests = [{ self.nextState < $0 && self.nextState < self.previousState}]
            }
            if spc == .localMax {
                _tests = [{ $0 > self.nextState && $0 > self.previousState }]
                //_tests = [{ self.nextState > $0 && self.nextState > self.previousState}]
            }
        }
        return _tests
    }
    
    override init(){
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
    
    // MARK: NSCoding implementation
    func encode(with coder: NSCoder) {
        coder.encode(varID, forKey: "varid")
        coder.encode(lbound, forKey: "lbound")
        coder.encode(ubound, forKey: "ubound")
        coder.encode(equality, forKey: "equality")
        coder.encode(specialCondition?.rawValue, forKey: "specialCondition")
    }
    
    required init?(coder: NSCoder) {
        varID = coder.decodeObject(forKey: "varid") as? VariableID ?? ""
        lbound = coder.decodeObject(forKey: "lbound") as? VarValue ?? nil
        ubound = coder.decodeObject(forKey: "ubound") as? VarValue ?? nil
        equality = coder.decodeObject(forKey: "equality") as? VarValue ?? nil
        if let scint = coder.decodeObject(forKey: "specialCondition") as? Int {
            specialCondition = SpecialConditionType(rawValue: scint) ?? nil }
        super.init()
    }
    
    // Evaluation functions
    func evaluateState(_ state: State){
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
    @objc func evaluateStateArray(_ singleState: StateArray)->Bool{ // TODO: get rid of this, it cant handle derived states like AoA
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
        if initialState != nil {
            let thisVal = initialState![varPosition!]
            previousState = thisVal
            nextState = thisVal
        }
        meetsCondition = nil
    }
}

/**
The Condition class provides teh mechanism to combine multiple SingleConditions or Conditions into one composite condition according to various boolean comparisons.
*/
public class Condition : NSObject, EvaluateCondition {
    
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
            let combinedString = dstrings.joined(separator: " \(String(describing: unionType)) ")
            return combinedString
        } set { _summary = newValue }
    }
    

    override init(){
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(conditions, forKey: "conditions")
        coder.encode(unionType.rawValue, forKey: "unionType")
        if _summary != "" { coder.encode(_summary, forKey: "summary") }
    }
    
    required public init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        conditions = coder.decodeObject(forKey: "conditions") as? [EvaluateCondition] ?? [SingleCondition]()
        unionType = BoolType(rawValue: coder.decodeInteger(forKey: "unionType")) ?? .single
        _summary = coder.decodeObject(forKey: "summary") as? String ?? ""
        super.init()
    }
    
    init(_ varid: VariableID, upperBound: VarValue? = nil, lowerBound: VarValue? = nil, equality: VarValue? = nil){
        let newCondition = SingleCondition(varid, upperBound: upperBound, lowerBound: lowerBound, equality: equality)
        conditions = [newCondition]
        super.init()
    }
    
    init(conditions condIn: [EvaluateCondition], unionType unTypeIn: BoolType, name nameIn: String) {
        conditions = condIn
        unionType = unTypeIn
        name = nameIn
        super.init()
    }

    /**
     Creates a single Condition from a Dictionary of the type that a yaml file can read. This dict can take two forms. In both forms, the condition name is the key. The simplest form is for a single condition. In this form the value string describes the condition, e.g."'x=5" or "2\<y\<10"> or "q is maximum"
     The string must meet three criteria: 1) it includes a single valid variable identifier, 2) it includes one of the comparison symbols (=, <, >, or 'is'), and 3) It has one or two numbers (or special conditions, e.g. global max, local min) to compare against
     - Parameter yamlObj: a Dictionary of the type [String: String] read from a yaml file.
     */
    convenience init?(fromYaml yamlObj: [String: Any], inputConditions: [Condition] = []){
        if yamlObj.count == 1 {
            let conditionName = yamlObj.keys.first!
            guard let valstr = yamlObj.values.first as? String else {return nil}
           
            //RegEx to parse the text
            let capturestr = #"(?:(?<lowerBound>[0-9\.-]+) ?(?<lowerSign>[\<\>]))?(?<varID>[\w ]+)(?<sign>[\<\>]|=| is ) ?(?<upperBound>[0-9\.-]+|[a-zA-Z ]+)"#
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
                newSingleCondition.lbound = VarValue(ub)
                newSingleCondition.ubound = lb
            case "=":
                newSingleCondition.equality = VarValue(ub)
            case " is ":
                if let specialCond = SpecialConditionType(ub){
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
            for (thisKey, thisVal) in yamlObj { //Compound conditions
                if thisKey == "conditions", let condList = thisVal as? [String]{
                    curConditions = condList.compactMap( { (condName: String)->Condition? in
                        return inputConditions.first { $0.name == condName } } )
                    if curConditions.count != condList.count { return nil }
                } else if thisKey == "union", let ustr = thisVal as? String{
                    guard let utype1 = BoolType(ustr) else {return nil}
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
    
    /**
     Compares two different boolean lists againts each other. These lists are representative of particular conditions being met across a trajectory. If only a single list is passed (list2), it simly returns that list
     */
    func compareLists(_ list1: [Bool]?, _ list2: [Bool])->[Bool]{
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

    @objc func evaluateStateArray(_ singleState: StateArray)->Bool { //Only use this if ALL states can be put into the State Array
        var curMeetsCondition = conditions[0].evaluateStateArray(singleState)
        for thisCondition in conditions.dropFirst(){
            let thisMeetsCondition = thisCondition.evaluateStateArray(singleState)
            curMeetsCondition = comparator(curMeetsCondition, thisMeetsCondition)
        }
        return curMeetsCondition
    }

    func reset(initialState: StateArray? = nil){
        meetsCondition = nil
        for thisCondition in conditions {
            thisCondition.reset(initialState: initialState)
        }
    }
    
    /**
     Used to determine whether a given Condition or SingleCondition is a child of the current condition. Recursively searches sub-conditions
     */
    func containsCondition(_ inputCondition: EvaluateCondition)->Bool{
        // if self === inputCondition { return true }
        for curCondition in self.conditions {
            if curCondition === inputCondition { return true }
            else if curCondition is Condition {
                if (curCondition as! Condition).containsCondition(inputCondition) { return true }
            }
        }
        return false
    }
    
    /**
     Determines whether any children use Global Max or Global Min, making them unsuitable for use in terminal conditions
     */
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
}

enum ConditionError: Error {
    case InvalidComparison(_ message: String)
}

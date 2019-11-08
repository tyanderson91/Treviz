//
//  Condition.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/28/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

protocol EvaluateCondition {
    func evaluate(_ state: State)
    func evaluate(_ singleState: StateArray)->Bool
    var meetsCondition : [Bool]? {get set}
    var isSinglePoint : Bool {get set}// Boolean to tell whether the condition should return a single point per trajectory (such as terminal condition, max/min, etc
}

/**
 Booltype represents the different ways that conditions can be combined
 Rawvalue is set to indew to allow for easy integration with dropdown menus
*/
enum BoolType : Int {
    case and = 0
    case or = 1
    case nor = 2
    case nand = 3
    case xor = 4
    case xnor = 5
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
}

class SingleCondition: NSObject, EvaluateCondition {
    let varID : VariableID
    var lbound : Double? = nil
    var ubound : Double? = nil
    var equality : Double? = nil
    var specialCondition : SpecialConditionType? = nil
    var meetsCondition : [Bool]?
    var isSinglePoint: Bool = false
    var varPosition : Int? // Position of the current variable in the index of StateVarPositions (automatically assigned, speeds up performance)
    private var previousState : Double! // For use in equality type or special case lookups
    private var nextState: Double! // For use in special case lookups, e.g. local min
    var tests : [(Double)->Bool] {
        var _tests : [(Double)->Bool] = []
        if let lower = lbound {
            _tests.append {$0 > lower }
        }; if let upper = ubound {
            _tests.append {$0 < upper }
        }
        if let eq = equality {
            _tests = [{ ($0-eq).sign != (self.previousState-eq).sign }]
        }
        return _tests
    }
    
    init(_ vid: VariableID){
        varID = vid
        super.init()
    }
    
    init(_ vid: VariableID, upperBound: Double? = nil, lowerBound: Double? = nil, equality eq: Double? = nil, specialCondition spc: SpecialConditionType? = nil){
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
        var i = 0
        for thisVal in thisVariable.value {
            var isCondition = true
            for thisTest in tests {
                isCondition = isCondition && thisTest(thisVal)
            }
            if isCondition {
                meetsCondition![i] = true
            }
            i+=1
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
}


class Condition : NSObject, EvaluateCondition {
    
    var name : String = ""
    var conditions : [EvaluateCondition] = []
    var unionType : BoolType = .and
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
    
    var isSinglePoint: Bool {
        get {
            return conditions.filter( { $0.isSinglePoint } ).count > 0
        } set (newVal) {
            for thisCondition in self.conditions {
                var thisCondition1 = thisCondition
                thisCondition1.isSinglePoint = newVal
            }
        }
    }
    
    override init(){
        super.init()
    }

    init(_ varid: VariableID, upperBound: Double? = nil, lowerBound: Double? = nil, equality: Double? = nil){
        let newCondition = SingleCondition(varid, upperBound: upperBound, lowerBound: lowerBound, equality: equality)
        conditions = [newCondition]
        super.init()
    }
    
    init(conditions condIn: [EvaluateCondition], unionType unTypeIn: BoolType, name nameIn: String, isSinglePoint singlePointIn: Bool = false) {
        conditions = condIn
        unionType = unTypeIn
        name = nameIn
        super.init()
        self.isSinglePoint = singlePointIn
    }
    /**
     Creates a single Condition from a Dictionary of the type that a yaml file can read. This dict can take two forms. In both forms, the condition name is the key. The simplest form is for a single condition. In this form the value string describes the condition, e.g."'x=5" or "2\<y\<10"> or "q is maximum"
     The string must meet three criteria: 1) it includes a single valid variable identifier, 2) it includes one of the comparison symbols (=, <, >, or 'is'), and 3) It has one or two numbers (or special conditions, e.g. global max, local min) to compare against
     - Parameter yamlObj: a Dictionary of the type [String: String] read from a yaml file.
     */
    init?(fromYaml yamlObj: [String: Any]){
        for (thisKey, thisVal) in yamlObj {
            let name = thisKey
            if let valstr = thisVal as? String { // for single line condition declarations (e.g. 'x>5')
                
            }
        }
        return nil
    }
    
    func comparator(_ num1: Bool, _ num2: Bool)->Bool {
        switch unionType {
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

    func evaluate(_ singleState: StateArray)->Bool { //Only use this if ALL states acn be put into the State Array
        var curMeetsCondition = conditions[0].evaluate(singleState)
        for thisCondition in conditions.dropFirst(){
            let thisMeetsCondition = thisCondition.evaluate(singleState)
            curMeetsCondition = comparator(curMeetsCondition, thisMeetsCondition)
        }
        return curMeetsCondition
    }
}

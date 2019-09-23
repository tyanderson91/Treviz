//
//  Condition.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/28/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

enum ConditionType {
    case terminal
    case variable
}

/// Booltype represents the different ways that conditions can be combicned
enum BoolType : Int {
    case and = 0
    case or = 1
    case nor = 2
    case nand = 3
    case xor = 4
    case xnor = 5
}

class SingleCondition: NSObject {
    var varID : VariableID = "" // TODO: turn into let constant
    var type : ConditionType = .variable
    var state = State()
    var index : [Int] = []
    var lbound : Double? = nil
    var ubound : Double? = nil
    var equality : Double? = nil
    //var isConditionIndex : [Int]? = nil
    var isConditionBool : [Bool]? = nil
    
    func evaluate(){
        switch self.type {
        case .variable:
            self.evaluateVar()
        case .terminal:
            self.evaluateTerminal()
        }
    }
    
    private func evaluateTerminal(){
        self.index = [state.toArray().count] // TODO: make more robust way to find terminal condition
    }
    
    private func evaluateVar(){
        var tests : [(Double)->(Bool)] = []
        if let lower = self.lbound {
            tests.append({(val1)->(Bool) in
                return val1>lower
            })
        }
        if let upper = self.ubound {
            tests.append({(val1)->(Bool) in
                return val1<upper
            })
        }
        if let eq = self.equality {
            tests.append({(val1)->(Bool) in
                return val1==eq
            })
        }
        let stateArray = state.toArray()
        //isConditionIndex = []
        isConditionBool = Array(repeating: false, count: stateArray.count)
        
        var i=0
        for thisVal in stateArray{
            var isCondition = false
            for thisTest in tests {
                isCondition = isCondition && thisTest(thisVal)
            }
            if isCondition {
                //isConditionIndex!.append(i)
                isConditionBool![i] = true
            }
            i+=1
        }
    }
}

class Condition : SingleCondition { //TODO : Should really just make this a separate NSObject that conforms to the 'evaluate' protocol
    var name : String = ""
    var conditions : [Condition] = []
    var unionType : BoolType = .and
    
    func comparator(num1: Bool, num2: Bool)->Bool {
        switch unionType {
        case .and: return num1 && num2
        case .or: return num1 || num2
        case .nor: return !(num1 || num2)
        case .nand: return !(num1 && num2)
        case .xor: return num1 != num2
        case .xnor: return num1 == num2
        }
    }
    
    func compareLists(list1 : [Bool]?, list2: [Bool])->[Bool]{ // TODO : take this outside of the class, make it a generic function
        if list1 == nil{
            return list2
        }
        guard list1!.count == list2.count else {
            print("Lists do not have the same length. Cannot perform comparison")
            return [false]
        }
        var returnList : [Bool] = []
        for i in 0...list2.count-1 {
            returnList.append(comparator(num1: list1![i], num2: list2[i]))
        }
        return returnList
    }
    
    override func evaluate(){
        for thisCondition in conditions{
            thisCondition.evaluate()
            if let conditionBool = thisCondition.isConditionBool{
            //conditionBools.append(conditionBool)
                isConditionBool = compareLists(list1: isConditionBool, list2: conditionBool)
            }
        }
    }
}

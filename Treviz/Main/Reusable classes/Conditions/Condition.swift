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

enum BoolType {
    case and
    case or
    case nor
    case xor
    case xand
}

class Condition: NSObject {
    var varID : VariableID = "" // TODO: turn into let constant
    var type : ConditionType = .variable
    var state = State()
    var name : String = ""
    var index : [Int] = []
    var lbound : Double? = nil
    var ubound : Double? = nil
    var equality : Double? = nil
    
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
        index = []
        var i=0
        for thisVal in stateArray{
            var isCondition = false
            for thisTest in tests {
                isCondition = isCondition && thisTest(thisVal)
            }
            if isCondition {index.append(i)}
            i+=1
        }
    }
}

class CompoundCondition : Condition {
    var conditions : [Condition] = []
    var unionType : BoolType = .and
}

//
//  InitStateHeader.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 InitStateCheck consists of any class that can serve as an initial state setting. This includes variables like initial state, run settings, environment, vehicle, etc.
 An InitStateCheck may have children (if it is a headen or subheader), can be checked for validity before running, and can be a parameter or contain parameters
 */
protocol InitStateCheck {
    var name: String {get}
    var isValid: Bool {get}
    var hasParams: Bool {get}
    var children: [InitStateCheck] {get}
    func getChild(named inputName: String)->InitStateCheck?
}

extension Variable: InitStateCheck {
    var children: [InitStateCheck] { return [] }
    func getChild(named inputName: String)->InitStateCheck? {
        return self.name == inputName ? self : nil
    }
}

class InitStateHeader: InitStateCheck{
    var id: ParamID = ""
    var subheaders: [InitStateHeader]
    var variables: [Variable]
    var children: [InitStateCheck] {
        var _children: [InitStateCheck] = []
        _children.append(contentsOf: variables)
        _children.append(contentsOf: subheaders)
        return _children}
    var name: String = ""
    var isValid: Bool { var curValid = true
        for curChild in self.children{
            curValid = curValid && curChild.isValid}
        return curValid}
    var hasParams: Bool { var curParam = false
        for curChild in self.children{
            curParam = curParam || curChild.hasParams}
        return curParam}
    
    init(id : ParamID, subheaders: [InitStateHeader]=[], variables: [Variable]=[]){
        self.id = id
        self.name = " "
        self.subheaders = subheaders
        self.variables = variables
    }
    
    func getChild(named inputName: String)->InitStateCheck?{
        if self.name == inputName { return self }
        for thisChild in children {
            if let match = thisChild.getChild(named: inputName) { return match }
        }
        return nil
    }
}

class InitStateSubHeader: InitStateHeader{
}

//
//  InitStateHeader.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

protocol InitStateCheck{
    var name: String {get}
    var isValid: Bool {get}
    var hasParams: Bool {get}
    var children: [InitStateCheck] {get}
}


class InitStateHeader: InitStateCheck{
    var id: VariableID = ""
    var subheaders: [InitStateHeader]
    var variables: [Variable]
    var children: [InitStateCheck] {
        var _children: [InitStateCheck] = []
        _children.append(contentsOf: variables)
        _children.append(contentsOf: subheaders)
        return _children}
    var name: String = ""
    var isValid: Bool {
        var curValid = true
        for curChild in self.children{
            curValid = curValid && curChild.isValid}
        return curValid}
    var hasParams: Bool {var curParam = false
        for curChild in self.children{
            curParam = curParam || curChild.hasParams}
        return curParam}
    
    init(id : VariableID, subheaders: [InitStateHeader]=[], variables: [Variable]=[]){
        self.id = id
        self.name = " "
        self.subheaders = subheaders
        self.variables = variables
    }
}

class InitStateSubHeader: InitStateHeader{

}

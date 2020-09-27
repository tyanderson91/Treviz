//
//  Parameter.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 This protocol is adopted by every class used as a input parameter or plotting variable. The standard Variable class adopts this protocol for all numerical variable, but it can also be adopted by categorical parameters, such as integrator type, or physics model
 */
protocol Parameter {
    var id: VariableID {get}
    var name: String {get}
    var isParam : Bool {get set} // Defines whether the parameter is used as a 'parameter' in the current analysis; that is, whether it is varied as an input across multiple analysis runs
    static var paramConstructor: (_ param: Parameter)->RunVariant? {get}
}

class NumberParam : Parameter {
    var id: VariableID
    var name: String
    var isParam: Bool = false
    var value: VarValue = 0
    static var paramConstructor: (Parameter) -> RunVariant? = { (param: Parameter) in
        return SingleNumberRunVariant(param: param) ?? nil
    }
    
    init(id numID: VariableID, name nameIn: String){
        id = numID
        name = nameIn
    }
    
    convenience init(id numID: VariableID, name nameIn: String, value valIn: VarValue){
        self.init(id: numID, name: nameIn)
        value = valIn
    }
}

class EnumGroupParam: Parameter {
    var id: VariableID
    var name: String
    var isParam: Bool = false
    var value: StringValue
    var enumType: StringValue.Type
    static var paramConstructor: (Parameter) -> RunVariant? = { (param: Parameter) in
        return EnumGroupRunVariant(param: param) ?? nil
    }
    
    init(id numID: VariableID, name nameIn: String, enumType enumTypeIn: StringValue.Type){
        id = numID
        name = nameIn
        enumType = enumTypeIn
        value = ""
    }
    
    convenience init(id numID: VariableID, name nameIn: String, enumType enumTypeIn: StringValue.Type, value valIn: StringValue){
        self.init(id: numID, name: nameIn, enumType: enumTypeIn)
        value = valIn
    }
}

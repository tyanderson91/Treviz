//
//  RunVariant.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/13/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

enum DistributionType: String {
    case normal
    case uniform
}

extension Bool: StringValue {
    var valuestr: String {
        if self == true {
            return "True"
        } else { return "False" }
    }
    init?(rawValue: String) {
        switch rawValue {
        case "True", "On":
            self.init(true)
        case "False", "Off":
            self.init(false)
        default:
            return nil
        }
    }
}

class RunVariant {
    var paramID: VariableID { return parameter.id }
    var isActive: Bool {
        get { return parameter.isParam }
        set { parameter.isParam = newValue }
    }
    var curValue: StringValue { return "" }
    var options: [StringValue] = []
    var isTradeStudy: Bool = false
    var parameter: Parameter
    func setValue(from string: String) {return}
    var paramVariantSummary: String { get { return "" } }
    
    init?(param: Parameter) {
        parameter = param
    }
}

class VariableRunVariant: RunVariant {
    var distributionType: DistributionType = .normal
    // Monte-carlo dispersion parameters
    var min: VarValue?
    var max: VarValue?
    var mean: VarValue?
    var sigma: VarValue?
    var variable: Variable { return parameter as! Variable }
    override var curValue: StringValue { return variable.value[0]}
    /*required init(param: Parameter) {
        super.init(param: param)
    }*/
    override func setValue(from string: String) {
        if let tempVal = VarValue(string) { variable.value[0] = tempVal }
    }
}

class SingleNumberRunVariant: RunVariant {
    var distributionType: DistributionType = .normal
    // Monte-carlo dispersion parameters
    var min: VarValue?
    var max: VarValue?
    var mean: VarValue?
    var sigma: VarValue?
    var number: NumberParam { return parameter as! NumberParam }
    override var curValue: StringValue { return number.value }
    /*
    required init(param: Parameter) {
        super.init(param: param)
    }*/
    override func setValue(from string: String) {
        if let tempVal = VarValue(string) { number.value = tempVal }
    }
}

class EnumGroupRunVariant: RunVariant {
    var enumParam: EnumGroupParam { return parameter as! EnumGroupParam }
    var enumType: StringValue.Type { return enumParam.enumType }
    override var curValue: StringValue { return enumParam.value }
    
    override func setValue(from string: String) {
        guard let newVal = enumType.init(rawValue: string) else { return }
        enumParam.value = newVal
    }
    override init?(param: Parameter) {
        guard let curEnumParam = param as? EnumGroupParam else { return nil }
        super.init(param: curEnumParam)
        options = curEnumParam.options
    }
}

class BoolRunVariant: RunVariant {
    var paramEnabled: Bool = false
    override var curValue: StringValue { return paramEnabled }
    override init?(param: Parameter) {
        guard let curBoolParam = param as? BoolParam else { return nil }
        super.init(param: curBoolParam)
    }
}

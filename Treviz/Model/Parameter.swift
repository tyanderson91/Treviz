//
//  Parameter.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

protocol StringValue {
    var valuestr: String {get}
    //init(from string: String)
}

extension String: StringValue {
    var valuestr: String { return self }
    init(from strval: StringValue) { self = strval.valuestr }
    
    //init(from string: String) { self = string }
}

extension VarValue: StringValue {
    var valuestr: String { return String(format: "%g", self)}
}

/**
 This protocol is adopted by every class used as a input parameter or plotting variable. The standard Variable class adopts this protocol for all numerical variable, but it can also be adopted by categorical parameters, such as integrator type, or physics model
 */
protocol Parameter {
    var id: VariableID {get}
    var name: String {get}
    var isParam : Bool {get set} // Defines whether the parameter is used as a 'parameter' in the current analysis; that is, whether it is varied as an input across multiple analysis runs
    //var value: Any {get set}
    //var options: Array<StringRepresentable>? {get}
}

enum DistributionType: String {
    case normal
    case uniform
}

class ParameterAnalysisSetting {
    var paramID: VariableID
    var curValue: StringValue = ""
    var options: [StringValue] = []
    var isTradeStudy: Bool = false
    func setValue(from string: String) {return}
    var paramVariantSummary: String { get { return "" } }
    
    init(param: VariableID) {
        paramID = param
    }
}

class NumericParamAnalysisSetting: ParameterAnalysisSetting {
    var distributionType: DistributionType = .normal
    
    // Monte-carlo dispersion parameters
    var min: VarValue?
    var max: VarValue?
    var mean: VarValue?
    var sigma: VarValue?
}

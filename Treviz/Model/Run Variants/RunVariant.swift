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

enum RunVariantType: String, CaseIterable {
    case single = "Single"
    case montecarlo = "MC"
    case trade = "Trade"
}

/**Required to set initial param value during initialization from Codable*/
struct DummyParam : Parameter {
    var id: ParamID = ""
    var name: String = ""
    var isParam: Bool = false
    var stringValue: String = ""
    static var paramConstructor = {(_ param: Parameter)->RunVariant? in return nil}
    func setValue(to: String){}
}
/** Placeholder class used in creating Runs when other run variants are not used*/
class DummyRunVariant: RunVariant, MCRunVariant {
    init(){
        super.init(param: DummyParam())!
    }
    required init(from decoder: Decoder) throws {
        fatalError("Dummy Run Variant should never need to be created from Coder")
    }
    func randomValue(seed: Double?)->VarValue { return 0.0 }
}

/** Type of run variant that can return a random value to be used in monte-carlo analysis*/
protocol MCRunVariant {
    var paramID: ParamID {get}
    func randomValue(seed: Double?)->VarValue
}

/**
 A set of configuration parameters that describes how to vary a single parameter within an analysis, whether through monte-carlo dispersions or distinct variations within a trade study
 */
class RunVariant: Codable {
    var paramID: ParamID { return parameter.id }
    var isActive: Bool {
        get { return parameter.isParam }
        set { parameter.isParam = newValue }
    }
    var curValue: StringValue { return "" }
    var options: [StringValue] = [] // The list of valid alternatives
    var variantType: RunVariantType = .single
    var tradeValues: [StringValue] = [] // List of variants to be used in trade study
    var parameter: Parameter
    func setValue(from string: String) {return}
    var paramVariantSummary: String { get { return "" } }
    
    init?(param: Parameter) {
        parameter = param
    }
    
    //MARK: Codable
    enum CodingKeys: String, CodingKey {
        case paramID
        case nominal
        case options
        case variantType
        case category
    }
    
    enum CategoryKey: String, Codable {
        case variable
        case enumeration
        case number
        case boolean
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let variantTypeString = try container.decode(String.self, forKey: .variantType)
        if ["trade", "trade study"].contains(variantTypeString.lowercased()) {
            variantType = .trade
        } else if ["mc", "monte carlo", "monte-carlo"].contains(variantTypeString.lowercased()) {
            variantType = .montecarlo
        } else {
            variantType = .single
        }
        parameter = DummyParam()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paramID, forKey: .paramID)
        try container.encode(curValue.valuestr, forKey: .nominal)
        try container.encode(variantType.rawValue.lowercased(), forKey: .variantType)
    }
}


/**A type of run variant used to define the variations on a Variable*/
class VariableRunVariant: RunVariant, MCRunVariant {
    var distributionType: DistributionType = .normal
    // Monte-carlo dispersion parameters
    var min: VarValue?
    var max: VarValue?
    var mean: VarValue?
    var sigma: VarValue?
    var variable: Variable { return parameter as! Variable }
    override var curValue: StringValue { return variable.value[0]}
    override init?(param: Parameter) {
        super.init(param: param)
    }
    override func setValue(from string: String) {
        if let tempVal = VarValue(string) { variable.value[0] = tempVal }
    }
    //MARK: Codable
    enum VariableCodingKeys: String, CodingKey {
        case min
        case max
        case mean
        case sigma
    }
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: VariableCodingKeys.self)
        if container.contains(.min) { min = try container.decode(VarValue.self, forKey: .min)}
        if container.contains(.max) { max = try container.decode(VarValue.self, forKey: .max)}
        if container.contains(.mean) { mean = try container.decode(VarValue.self, forKey: .mean)}
        if container.contains(.sigma) { sigma = try container.decode(VarValue.self, forKey: .sigma)}
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VariableCodingKeys.self)
        try container.encode(min, forKey: .min)
        try container.encode(max, forKey: .max)
        try container.encode(mean, forKey: .mean)
        try container.encode(sigma, forKey: .sigma)
        
        var categoryContainer = encoder.container(keyedBy: CodingKeys.self)
        try categoryContainer.encode(CategoryKey.variable, forKey: .category)
    }
    
    func randomValue(seed: Double?)->VarValue{
        return variable.value[0] // TODO: Make actually return random value
    }
}

/**A type of Run Variant used to vary a single number parameter that is not a variable, such as a timestep*/
class SingleNumberRunVariant: RunVariant, MCRunVariant {
    var distributionType: DistributionType = .normal
    // Monte-carlo dispersion parameters
    var min: VarValue?
    var max: VarValue?
    var mean: VarValue?
    var sigma: VarValue?
    var number: NumberParam { return parameter as! NumberParam }
    override var curValue: StringValue { return number.value }
    override func setValue(from string: String) {
        if let tempVal = VarValue(string) { number.value = tempVal }
    }
    override init?(param: Parameter) {
        super.init(param: param)
    }
    //MARK: Codable
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: VariableRunVariant.VariableCodingKeys.self)
        if container.contains(.min) { min = try container.decode(VarValue.self, forKey: .min)}
        if container.contains(.max) { max = try container.decode(VarValue.self, forKey: .max)}
        if container.contains(.mean) { mean = try container.decode(VarValue.self, forKey: .mean)}
        if container.contains(.sigma) { sigma = try container.decode(VarValue.self, forKey: .sigma)}
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VariableRunVariant.VariableCodingKeys.self)
        if min != nil { try container.encode(min, forKey: .min) }
        if max != nil { try container.encode(max, forKey: .max) }
        if mean != nil { try container.encode(mean, forKey: .mean) }
        if sigma != nil { try container.encode(sigma, forKey: .sigma) }
        
        var categoryContainer = encoder.container(keyedBy: CodingKeys.self)
        try categoryContainer.encode(CategoryKey.number, forKey: .category)
    }
    
    func randomValue(seed: Double?)->VarValue{
        return number.value // TODO: make actually return random value
    }
}

/**A type of run variant used to vary a parameter with a fixed number of options like an Enum*/
class EnumGroupRunVariant: RunVariant {
    var enumParam: EnumGroupParam { return parameter as! EnumGroupParam }
    var enumType: StringValue.Type { return enumParam.enumType }
    override var curValue: StringValue { return enumParam.value }
    
    override func setValue(from string: String) {
        guard let newVal = enumType.init(stringLiteral: string) else { return }
        enumParam.value = newVal
    }
    override init?(param: Parameter) {
        guard let curEnumParam = param as? EnumGroupParam else { return nil }
        super.init(param: curEnumParam)
        options = curEnumParam.options
    }
    //MARK: Codable
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var categoryContainer = encoder.container(keyedBy: CodingKeys.self)
        try categoryContainer.encode(CategoryKey.enumeration, forKey: .category)
    }
}

/**A type of run variant used to define variations for a boolean parameter*/
class BoolRunVariant: RunVariant {
    var paramEnabled: Bool = false
    override var curValue: StringValue { return paramEnabled }
    override init?(param: Parameter) {
        guard let curBoolParam = param as? BoolParam else { return nil }
        super.init(param: curBoolParam)
    }
    //MARK: Codable
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var categoryContainer = encoder.container(keyedBy: CodingKeys.self)
        try categoryContainer.encode(CategoryKey.boolean, forKey: .category)
    }
}

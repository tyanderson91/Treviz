//
//  Units.swift
//  Treviz
//
//  Created by Tyler Anderson on 5/2/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

// MARK: Unit Types
enum UnitType {
    case unitless, length, speed, temperature, mass, angle, force, duration
}
/**
 This protocol is used to assign particular types to each subclass of dimensions and units, which allows them to be compared for validity checking
 */
protocol TZDim {
    func unitType()->UnitType
    func baseUnit()->Dimension
    var converter: UnitConverter { get }
    func convertToBase(val: VarValue)->VarValue
    func convert(to dim: TZDim, val: VarValue)->VarValue
}
extension TZDim {
    func convert(to dim: TZDim, val: VarValue)->VarValue {
        guard let linConvert1 = self.converter as? UnitConverterLinear else { return 0.0 }
        guard let linConvert2 = dim.converter as? UnitConverterLinear else { return 0.0 }
        let a1 = linConvert1.coefficient
        let b1 = linConvert1.constant
        let a2 = linConvert2.coefficient
        let b2 = linConvert2.constant
        return (a1*(val+b1)-b2)/a2
    }
    func convert(to dim: TZDim, vals: [VarValue])->[VarValue] {
        guard let linConvert1 = self.converter as? UnitConverterLinear else { return [0.0] }
        guard let linConvert2 = dim.converter as? UnitConverterLinear else { return [0.0] }
        let a1 = linConvert1.coefficient
        let b1 = linConvert1.constant
        let a2 = linConvert2.coefficient
        let b2 = linConvert2.constant
        return vals.map { (a1*$0+b1-b2)/a2 }
    }
    func convertToBase(val: VarValue)->VarValue {
        guard let linConvert = self.converter as? UnitConverterLinear else { return 0.0 }
        return (val+linConvert.constant)*linConvert.coefficient
    }
    func convertToBase(vals: [VarValue])->[VarValue] {
        guard let linConvert = self.converter as? UnitConverterLinear else { return [0.0] }
        let a = linConvert.coefficient
        let b = linConvert.constant
        return vals.map { (b+$0)*a }
    }
}

// MARK: Unit extensions
extension UnitLength: CaseIterable, TZDim {
    func baseUnit()->Dimension { return UnitLength.baseUnit() }
    static var astronomicalUnits = UnitLength(symbol: "AU", converter: UnitConverterLinear(coefficient: 149597870700))
    public static var allCases: [UnitLength] {
        return [.meters, .astronomicalUnits, .fathoms, .feet, .kilometers, .lightyears, .miles, .nauticalMiles, .parsecs, .yards]
    }
    func unitType() -> UnitType { return .length }
}
extension UnitSpeed: CaseIterable, TZDim {
    func baseUnit()->Dimension { return UnitSpeed.baseUnit() }
    static let feetPerSecord = UnitSpeed(symbol: "ft/s", converter: UnitConverterLinear(coefficient: 0.3048))
    static let kilometersPerSecond = UnitSpeed(symbol: "km/s", converter: UnitConverterLinear(coefficient: 1000))
    public static var allCases: [UnitSpeed] {
        return [.metersPerSecond, .kilometersPerHour, .milesPerHour, .knots, .feetPerSecord, .kilometersPerSecond]
    }
    func unitType() -> UnitType { return .speed }
}
extension UnitTemperature: CaseIterable, TZDim {
    func baseUnit()->Dimension { return UnitTemperature.baseUnit() }
    public static var allCases: [UnitTemperature] {
        return [.celsius, .fahrenheit, .kelvin]
    }
    func unitType() -> UnitType { return .temperature }
}
extension UnitMass: CaseIterable, TZDim {
    func baseUnit()->Dimension { return UnitMass.baseUnit() }
    public static var allCases: [UnitMass] {
        return [.kilograms, .metricTons, .shortTons, .pounds, .slugs]
    }
    func unitType() -> UnitType { return .mass }
}
extension UnitAngle: CaseIterable {
    func baseUnit()->Dimension { return UnitAngle.baseUnit() }
    public static var allCases: [UnitAngle] {
        return [.degrees, .radians]
    }
    func unitType() -> UnitType { return .angle }
}
class UnitForce: Dimension, CaseIterable, TZDim {
    func baseUnit()->Dimension { return UnitForce.baseUnit() }
    static let newtons = UnitForce(symbol: "N", converter: UnitConverterLinear(coefficient: 1))
    static let pounds = UnitForce(symbol: "lbf", converter: UnitConverterLinear(coefficient: 4.4482216))
    static let ton = UnitForce(symbol: "T", converter: UnitConverterLinear(coefficient: 9806.65))
    static let baseUnit: UnitForce = .newtons
    
    func unitType() -> UnitType { return .force }
    // CaseIterable
    static let allCases: [UnitForce] = [.newtons, .pounds, .ton]
}
extension UnitDuration: CaseIterable, TZDim {
    func baseUnit()->Dimension { return UnitDuration.baseUnit() }
    static let days = UnitDuration(symbol: "d", converter: UnitConverterLinear(coefficient: 3600))
    static let hours = UnitDuration(symbol: "h", converter: UnitConverterLinear(coefficient: 3600))
    static let years = UnitDuration(symbol: "y", converter: UnitConverterLinear(coefficient: 525600))
    public static var allCases: [UnitDuration] {
        return [.seconds, .minutes, .hours, .milliseconds, .days]
    }
    func unitType() -> UnitType { return .duration }
}
class UnitUnit: Dimension, TZDim {
    func baseUnit()->Dimension { return UnitUnit() }
    init(){
        super.init(symbol: "", converter: UnitConverter())
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func unitType() -> UnitType { return .unitless }
}

extension Unit {
    public static var allUnits: [Unit] {
        var cases: [Unit] = []
        cases.append(contentsOf: UnitSpeed.allCases)
        cases.append(contentsOf: UnitLength.allCases)
        cases.append(contentsOf: UnitTemperature.allCases)
        cases.append(contentsOf: UnitMass.allCases)
        cases.append(contentsOf: UnitForce.allCases)
        cases.append(contentsOf: UnitAngle.allCases)
        cases.append(contentsOf: UnitDuration.allCases)
        return cases
    }
    static func fromString(stringSymbol: String)->Unit?{
        if let matchingUnit = allUnits.first(where: {$0.symbol == stringSymbol}) {
            return matchingUnit
        } else {
            return nil
        }
    }
}

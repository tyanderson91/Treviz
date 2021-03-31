//
//  UserPreferences.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/16/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    // MARK: Helper functions
    fileprivate func set(_ newValue: Any, key: Key){ self.set(newValue, forKey: key.rawValue) }
    fileprivate func register(defaults: [Key:Any]){
        for (key, value) in defaults {
            self.register(defaults: [key.rawValue: value])
        }
    }

    fileprivate func string(key: Key)->String? { return self.string(forKey: key.rawValue)}
    fileprivate func integer(key: Key)->Int? { return self.integer(forKey: key.rawValue)}
    fileprivate func float(key: Key)->Float? { return self.float(forKey: key.rawValue)}
    fileprivate func double(key: Key)->Double? { return self.double(forKey: key.rawValue)}
    fileprivate func array(key: Key)->[Any]? { return self.array(forKey: key.rawValue)}
    fileprivate func dict(key: Key)->[String:Any]? { return self.dictionary(forKey: key.rawValue)}
    fileprivate func bool(key: Key)->Bool? { return self.bool(forKey: key.rawValue)}
    fileprivate func cgfloat(key: Key)->CGFloat { return CGFloat(self.float(forKey: key.rawValue))}
    
    private static func color(key: Key)->CGColor { // TODO: Allow for more types of color spaces
        guard let colorComponents = standard.array(key: key) as? [CGFloat] else { return .black }
        guard colorComponents.count == 3 else { return .black }
        let newColor = CGColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: CGFloat(1.0))
        return newColor
    }
    private static func setColor(_ color: CGColor, key: Key){
        guard let rgb = color.components else { return }
        let newArray = Array(rgb[0...2])
        standard.set(newArray, key: key)
    }
    
    // MARK: List of keys
    fileprivate enum Key: String {
        case colorMap
        case lineColor
        case lineWidth
        case linePattern
        
        case majorGridlineColor
        case majorGridlineWidth
        case minorGridlineColor
        case minorGridlineWidth
        
        case mcOpacity
        case plotSymbol
        case symbolSet
        case symbolSize
        case backgroundColor
        case plotIsInteractive
    }
    
    // Var definitions
    class var colorMap: ColorMap {
        get {
            guard let cmapName = standard.string(key: .colorMap) else { return ColorMap.defaultMap }
            return ColorMap.allMaps.first(where: {$0.name == cmapName}) ?? ColorMap.defaultMap
        }
        set { standard.set(newValue.name, key: .colorMap) }
    }
    class var lineColor: CGColor {
        get { return color(key: .lineColor) }
        set { setColor(newValue, key: .lineColor) }
    }
    class var lineWidth: CGFloat {
        get { return standard.cgfloat(key: .lineWidth) }
        set { standard.set(newValue, key: .lineWidth) }
    }
    class var linePattern: TZLinePattern {
        get { guard let name = standard.string(key: .linePattern) else { return .solid }
            return TZLinePattern.allPatterns.first(where: {$0.name == name}) ?? .solid
        }
        set { standard.set(newValue.name, key: .linePattern) }
    }
    class var mcOpacity: CGFloat {
        get { return standard.cgfloat(key: .mcOpacity) }
        set { standard.set(Float(newValue), key: .mcOpacity) }
    }
    class var symbolSize: CGFloat {
        get { return standard.cgfloat(key: .symbolSize) }
        set { standard.set(Float(newValue), key: .symbolSize) }
    }
    class var backgroundColor: CGColor {
        get { return color(key: .backgroundColor) }
        set { setColor(newValue, key: .backgroundColor) }
    }
    class var plotSymbol: TZPlotSymbol {
        get { guard let symbolName = standard.string(key: .plotSymbol) else { return .none }
            guard var symbol = TZPlotSymbol(symbolName: symbolName) else { return .none }
            symbol.size = self.symbolSize
            symbol.color = self.lineColor
            return symbol
        }
        set { standard.set(newValue.shape.rawValue, key: .plotSymbol) }
    }
    class var symbolSet: SymbolSet {
        get {
            guard let symbolNames: [String] = standard.array(key: .symbolSet) as? [String] else { return [plotSymbol.shape] }
            return symbolNames.compactMap { TZPlotSymbolShape(rawValue: $0) }
        }
        set { standard.set(newValue.compactMap({$0.rawValue}), key: .symbolSet) }
    }
    class var majorGridlineColor: CGColor {
        get { return color(key: .majorGridlineColor) }
        set { setColor(newValue, key: .majorGridlineColor) }
    }
    class var majorGridlineWidth: Double {
        get { return standard.double(key: .majorGridlineWidth) ?? 1.0 }
        set { standard.set(newValue, key: .majorGridlineWidth) }
    }
    class var minorGridlineColor: CGColor {
        get { return color(key: .minorGridlineColor) }
        set { setColor(newValue, key: .minorGridlineColor) }
    }
    class var minorGridlineWidth: Double {
        get { return standard.double(key: .minorGridlineWidth) ?? 1.0 }
        set { standard.set(newValue, key: .minorGridlineWidth) }
    }
    class var majorGridlineStyle: TZLineStyle {
        get { return TZLineStyle(color: UserDefaults.majorGridlineColor, lineWidth: UserDefaults.majorGridlineWidth)}
    }
    class var minorGridlineStyle: TZLineStyle {
        get { return TZLineStyle(color: UserDefaults.minorGridlineColor, lineWidth: UserDefaults.minorGridlineWidth)}
    }
    class var plotIsInteractive: Bool {
        get { return (standard.bool(key: .plotIsInteractive) ?? false) }
        set { standard.set(newValue, key: .plotIsInteractive) }
    }
}

extension AppDelegate: PlotPreferencesGetter {
   
    /**
     Set user defaults, if unset
     */
    func setDefaults(){
        TZPlot.preferencesGetter = self
        
        let defaults = UserDefaults.standard
        // System defaults
        defaults.register(defaults: [.colorMap: "okabe",
                                     .lineColor: [0.0, 0.0, 0.1],
                                     .lineWidth: 3.0,
                                     .linePattern: "solid",
                                     .mcOpacity: 0.7,
                                     .plotSymbol: "circle",
                                     .symbolSet: ["circle", "square","triangle","cross","plus","diamond"],
                                     .symbolSize: 3.0,
                                     .backgroundColor: [0.95, 0.95, 0.95],
                                     .majorGridlineColor: [0.5, 0.5, 0.5],
                                     .majorGridlineWidth: 0.8,
                                     .minorGridlineColor: [0.75, 0.75, 0.75],
                                     .minorGridlineWidth: 0.5,
                                     .plotIsInteractive: true
        ])
        
        // User defaults
        // TODO: Remove the below once it can be set in the GUI
        defaults.set("gnuplot", forKey: UserDefaults.Key.colorMap.rawValue)
        
        UserDefaults.lineWidth = 6.0
        UserDefaults.plotIsInteractive = true
        UserDefaults.linePattern = .solid
        UserDefaults.mcOpacity = 0.8
        UserDefaults.symbolSize = 6.0
        UserDefaults.backgroundColor = CGColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        UserDefaults.plotSymbol = .none
        UserDefaults.symbolSize = 6.0
    }
    
    func getPreferences(_ plot: TZPlot) {
        var prefs = plot.plotPreferences
        if plot.plotType.requiresCondition && prefs.plotSymbol.shape == .none { prefs.plotSymbol = UserDefaults.plotSymbol }
        if prefs.isInteractive == nil { prefs.isInteractive = UserDefaults.plotIsInteractive }
        if prefs.majorGridLineStyle == nil { prefs.majorGridLineStyle = UserDefaults.majorGridlineStyle }
        if prefs.minorGridLineStyle == nil { prefs.minorGridLineStyle = UserDefaults.minorGridlineStyle }
        if prefs.backgroundColor == nil { prefs.backgroundColor = UserDefaults.backgroundColor }
        if prefs.lineColor == nil { prefs.lineColor = UserDefaults.lineColor }
        if prefs.lineWidth == nil { prefs.lineWidth = UserDefaults.lineWidth }
        if prefs.linePattern == nil { prefs.linePattern = UserDefaults.linePattern }
        if prefs.colorMap == nil { prefs.colorMap = UserDefaults.colorMap }
        if prefs.symbolSet == nil { prefs.symbolSet = UserDefaults.symbolSet }
        
        plot.plotPreferences = prefs
    }
    
}

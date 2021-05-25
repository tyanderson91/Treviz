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
    fileprivate func data(key: Key)->Data? { return self.data(forKey: key.rawValue)}
    
    private func color(key: Key)->CGColor? {
        var newColor: CGColor?
        if let colorData = self.data(key: key) {
            let nscolor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) ?? nil
            newColor = nscolor?.cgColor
        } else { newColor = nil }
        
        return newColor
    }
    private func setColor(_ color: CGColor, key: Key){
        guard let nscolor = NSColor(cgColor: color) else { return }
        guard let colorData = try? NSKeyedArchiver.archivedData(withRootObject: nscolor, requiringSecureCoding: false) else { return }
        self.set(colorData, key: key)
    }
    
    // MARK: List of keys
    fileprivate enum Key: String {
        case colorMap
        case mainLineColor
        case mainLineWidth
        case mainLinePattern
        
        case majorGridlineColor
        case majorGridlineWidth
        case majorGridlinePattern
        case minorGridlineColor
        case minorGridlineWidth
        case minorGridlinePattern
        case axesWidth
        case axesColor
        
        case mcOpacity
        case markerSymbol
        case symbolSet
        case markerSize
        case markerColor
        case backgroundColor
        case plotIsInteractive
        
        case showVisualization
    }
    
    // Var definitions
    class var colorMap: ColorMap {
        get {
            guard let cmapName = standard.string(key: .colorMap) else { return ColorMap.defaultMap }
            return ColorMap.allMaps.first(where: {$0.name == cmapName}) ?? ColorMap.defaultMap
        }
        set { standard.set(newValue.name, key: .colorMap) }
    }
    class var mainLineColor: CGColor {
        get { return standard.color(key: .mainLineColor)! }
        set { standard.setColor(newValue, key: .mainLineColor) }
    }
    class var mainLineWidth: Double {
        get { return standard.double(key: .mainLineWidth) ?? 1.0 }
        set { standard.set(newValue, key: .mainLineWidth) }
    }
    class var mainLinePattern: TZLinePattern {
        get { guard let name = standard.string(key: .mainLinePattern) else { return .solid }
            return TZLinePattern.allPatterns.first(where: {$0.name == name}) ?? .solid
        }
        set { standard.set(newValue.name, key: .mainLinePattern) }
    }
    class var mainLineStyle: TZLineStyle {
        get { return TZLineStyle(color: UserDefaults.mainLineColor, lineWidth: UserDefaults.mainLineWidth, pattern: UserDefaults.mainLinePattern) }
        set {
            UserDefaults.mainLineColor = newValue.color
            UserDefaults.mainLineWidth = newValue.lineWidth
            UserDefaults.mainLinePattern = newValue.pattern
        }
    }
    class var mcOpacity: CGFloat {
        get { return standard.cgfloat(key: .mcOpacity) }
        set { standard.set(Float(newValue), key: .mcOpacity) }
    }
    class var backgroundColor: CGColor {
        get { return standard.color(key: .backgroundColor)! }
        set { standard.setColor(newValue, key: .backgroundColor) }
    }
    class var markerSymbol: TZPlotSymbol {
        get {
            let symbolName = standard.string(key: .markerSymbol) ?? ""
            return TZPlotSymbol(rawValue: symbolName) ?? .none }
        set { standard.set(newValue.rawValue, key: .markerSymbol) }
    }
    class var markerSize: CGFloat {
        get { return standard.cgfloat(key: .markerSize) }
        set { standard.set(Float(newValue), key: .markerSize) }
    }
    class var markerColor: CGColor {
        get { return standard.color(key: .markerColor)! }
        set { standard.setColor(newValue, key: .markerColor) }
    }
    class var markerStyle: TZMarkerStyle {
        get {
            return TZMarkerStyle(shape: UserDefaults.markerSymbol, size: UserDefaults.markerSize, color: UserDefaults.markerColor)
        }
        set {
            standard.set(newValue.shape.rawValue, key: .markerSymbol)
            standard.setColor(newValue.color, key: .markerColor)
            standard.set(newValue.size, key: .markerSize)
        }
    }
    class var symbolSet: SymbolSet {
        get {
            guard let symbolNames: [String] = standard.array(key: .symbolSet) as? [String] else { return [markerStyle.shape] }
            return symbolNames.compactMap { TZPlotSymbol(rawValue: $0) }
        }
        set { standard.set(newValue.compactMap({$0.rawValue}), key: .symbolSet) }
    }

    class var majorGridlineStyle: TZLineStyle {
        get {
            let width = standard.double(key: .majorGridlineWidth) ?? 1.0
            let color = standard.color(key: .majorGridlineColor)!
            let pattern: TZLinePattern = TZLinePattern.allPatterns.first(where: {$0.name == standard.string(key: .majorGridlinePattern) }) ?? .solid
            return TZLineStyle(color: color, lineWidth: width, pattern: pattern)
        }
        set {
            standard.setColor(newValue.color, key: .majorGridlineColor)
            standard.set(newValue.lineWidth, key: .majorGridlineWidth)
            standard.set(newValue.pattern.name, key: .majorGridlinePattern)
        }
    }
    class var minorGridlineStyle: TZLineStyle {
        get {
            let width = standard.double(key: .minorGridlineWidth) ?? 1.0
            let color = standard.color(key: .minorGridlineColor)!
            let pattern: TZLinePattern = TZLinePattern.allPatterns.first(where: {$0.name == standard.string(key: .minorGridlinePattern) }) ?? .solid
            return TZLineStyle(color: color, lineWidth: width, pattern: pattern)
        }
        set {
            standard.setColor(newValue.color, key: .minorGridlineColor)
            standard.set(newValue.lineWidth, key: .minorGridlineWidth)
            standard.set(newValue.pattern.name, key: .minorGridlinePattern)
        }
    }
    class var axesLineStyle: TZLineStyle {
        get {
            let width = standard.double(key: .axesWidth) ?? 3.0
            let color = standard.color(key: .axesColor)!
            return TZLineStyle(color: color, lineWidth: width)
        }
        set {
            standard.setColor(newValue.color, key: .axesColor)
            standard.set(newValue.lineWidth, key: .axesWidth)
        }
    }
    class var plotIsInteractive: Bool {
        get { return (standard.bool(key: .plotIsInteractive) ?? false) }
        set { standard.set(newValue, key: .plotIsInteractive) }
    }
    class var plotPreferences: PlotPreferences {
        get {
            var prefs = PlotPreferences()
            prefs.markerStyle = UserDefaults.markerStyle
            prefs.isInteractive = UserDefaults.plotIsInteractive
            prefs.axesLineStyle = UserDefaults.axesLineStyle
            prefs.majorGridLineStyle = UserDefaults.majorGridlineStyle
            prefs.minorGridLineStyle = UserDefaults.minorGridlineStyle
            prefs.backgroundColor = UserDefaults.backgroundColor
            prefs.mainLineStyle = UserDefaults.mainLineStyle
            prefs.mcOpacity = UserDefaults.mcOpacity
            prefs.colorMap = UserDefaults.colorMap
            prefs.symbolSet = UserDefaults.symbolSet
            return prefs
        } set {
            let prefs = newValue
            UserDefaults.markerStyle = prefs.markerStyle
            UserDefaults.plotIsInteractive = prefs.isInteractive
            UserDefaults.axesLineStyle = prefs.axesLineStyle
            UserDefaults.majorGridlineStyle = prefs.majorGridLineStyle
            UserDefaults.minorGridlineStyle = prefs.minorGridLineStyle
            UserDefaults.backgroundColor = prefs.backgroundColor
            UserDefaults.mainLineStyle = prefs.mainLineStyle
            UserDefaults.mcOpacity = prefs.mcOpacity
            UserDefaults.colorMap = prefs.colorMap
            UserDefaults.symbolSet = prefs.symbolSet
        }
    }
    
    class var showVisualization: Bool {
        get { return standard.bool(key: .showVisualization) ?? true}
        set { standard.set(newValue, key: .showVisualization) }
    }
}

extension AppDelegate: PlotPreferencesGetter {
    /**
     Set user defaults, if unset
     */
    func setDefaults(){
        TZPlot.preferencesGetter = self
        
        let defaults = UserDefaults.standard
        // MARK: System defaults
        
        // Set colors
        let bgColor = try! NSKeyedArchiver.archivedData(withRootObject: NSColor(deviceWhite: 0.95, alpha: 1.0), requiringSecureCoding: false)
        let lineColor = try! NSKeyedArchiver.archivedData(withRootObject: NSColor(deviceWhite: 0.0, alpha: 1.0), requiringSecureCoding: false)
        let markerColor = lineColor
        let axesColor = lineColor
        let majorGridlineColor = try! NSKeyedArchiver.archivedData(withRootObject: NSColor(deviceWhite: 0.5, alpha: 1.0), requiringSecureCoding: false)
        let minorGridlineColor = try! NSKeyedArchiver.archivedData(withRootObject: NSColor(deviceWhite: 0.75, alpha: 1.0), requiringSecureCoding: false)
        
        // Register defaults
        defaults.register(defaults: [.colorMap: "okabe",
                                     .mainLineColor: lineColor,
                                     .mainLineWidth: 3.0,
                                     .mainLinePattern: "solid",
                                     .mcOpacity: 0.7,
                                     .markerSymbol: "circle",
                                     .symbolSet: ["circle", "square","triangle","cross","plus","diamond"],
                                     .markerSize: 3.0,
                                     .markerColor: markerColor,
                                        .backgroundColor: bgColor,
                                     .majorGridlineColor: majorGridlineColor,
                                     .majorGridlineWidth: 0.8,
                                     .minorGridlineColor: minorGridlineColor,
                                     .minorGridlineWidth: 0.5,
                                     .axesWidth: 3.0,
                                     .axesColor: axesColor,
                                     .plotIsInteractive: true,
                                     .showVisualization: true
        ])
        
        let defaultSymbol = UserDefaults.markerStyle.shape
        let defaultSet = SymbolSet([.circle,.square,.triangle,.diamond,.pentagon, .star, .hexagon])
        let altSet = SymbolSet([.circle,.cross,.square,.plus,.triangle,.snow,.diamond,.dash])
        SymbolSet.allSets = [[], defaultSet, altSet, [defaultSymbol]]
    }
    
    func getPreferences(_ plot: TZPlot)->PlotPreferences {
        var prefs = plot.plotPreferences
        
        if plot.plotType.requiresCondition && prefs.markerStyle.shape == .none { prefs.markerStyle = UserDefaults.markerStyle }
        if prefs.isInteractive == nil { prefs.isInteractive = UserDefaults.plotIsInteractive }
        if prefs.axesLineStyle == nil { prefs.axesLineStyle = UserDefaults.axesLineStyle }
        if prefs.majorGridLineStyle == nil { prefs.majorGridLineStyle = UserDefaults.majorGridlineStyle }
        if prefs.minorGridLineStyle == nil { prefs.minorGridLineStyle = UserDefaults.minorGridlineStyle }
        if prefs.backgroundColor == nil { prefs.backgroundColor = UserDefaults.backgroundColor }
        if prefs.mainLineStyle == nil { prefs.mainLineStyle = UserDefaults.mainLineStyle }
        if prefs.colorMap == nil { prefs.colorMap = UserDefaults.colorMap }
        if prefs.markerStyle == nil { prefs.markerStyle = UserDefaults.markerStyle }
        if prefs.symbolSet == nil { prefs.symbolSet = UserDefaults.symbolSet }
        if prefs.mcOpacity == nil { prefs.mcOpacity = UserDefaults.mcOpacity }
        
        return prefs
    }
    
}

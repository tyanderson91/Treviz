//
//  TZPlot.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/24/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 Plot line style configuration
 */
struct TZLineStyle {
    var color: CGColor
    var lineWidth: Double
    var pattern: TZLinePattern = .solid
}

/**Options for plot symbol shapes*/
enum TZPlotSymbolShape: String {
    case none
    case cross
    case circle
    case square
    case plus
    case star
    case diamond
    case triangle
    case pentagon
    case hexagon
    case dash
    case snow
}

struct TZLinePattern: Equatable {
    let name: String
    let nums: [CGFloat]
    
    static let solid = TZLinePattern(name: "solid", nums: [])
    static let dash = TZLinePattern(name: "dash", nums: [3, 1])
    static let shortDash = TZLinePattern(name: "shortDash", nums: [2,1])
    static let longDash = TZLinePattern(name: "longDash", nums: [4,2])
    static let dot = TZLinePattern(name: "dot", nums: [0.01,1.5])
    static let dashDot = TZLinePattern(name: "dashDot", nums: [4,2,0.01,2])
    static let altDash = TZLinePattern(name: "altDash", nums: [4,1,2,1])
    
    // TODO: Turn this all into multipliers on the line width, rather than fixed values
    static let allPatterns: [TZLinePattern] = [.solid, .dash, .shortDash, .longDash, .dot, .dashDot, .altDash]
}
/**Plot symbol configuration options*/
struct TZPlotSymbol {
    
    var shape: TZPlotSymbolShape
    var size: CGFloat = 5
    var color: CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    init(_ shapeIn: TZPlotSymbolShape){
        shape = shapeIn
    }
    init?(symbolName: String) {
        guard let shape = TZPlotSymbolShape(rawValue: symbolName) else { return nil }
        self.init(shape)
    }
    
    // Default symbols by shape
    static let none = TZPlotSymbol(.none)
    static let cross = TZPlotSymbol(.cross)
    static let circle = TZPlotSymbol(.circle)
    static let square = TZPlotSymbol(.square)
    static let plus = TZPlotSymbol(.plus)
    static let star = TZPlotSymbol(.star)
    static let diamond = TZPlotSymbol(.diamond)
    static let triangle = TZPlotSymbol(.triangle)
    static let pentagon = TZPlotSymbol(.pentagon)
    static let hexagon = TZPlotSymbol(.hexagon)
    static let dash = TZPlotSymbol(.dash)
    static let snow = TZPlotSymbol(.snow)
}
typealias SymbolSet = [TZPlotSymbolShape]

/**
 Used to allow the App Delegate to assign preferences for the plots based on stored User defaults
 */
protocol PlotPreferencesGetter {
    func getPreferences(_  plot: TZPlot)
}

struct PlotPreferences {
    var majorGridLineStyle: TZLineStyle!
    var minorGridLineStyle: TZLineStyle!
    var isInteractive: Bool!
    var plotSymbol: TZPlotSymbol = .none
    var symbolSize: CGFloat!
    var symbolSet: SymbolSet!
    var lineWidth: CGFloat!
    var lineColor: CGColor!
    var linePattern: TZLinePattern!
    var backgroundColor: CGColor!
    var colorMap: ColorMap!
}
/**
 A TZPlot contains all the information required to render a plot in a TZPlotView. TZPlot is a subclass of TZOutput. The subclassing allows TZPlot to include configuration options specifically related to the plot, such as colors, axes options, and other options related to the appearance of the plot view
 */
final class TZPlot: TZOutput {
    
    // MARK: Preferences
    var plotPreferences = PlotPreferences()
    static var preferencesGetter: PlotPreferencesGetter?
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingsKeys.self)
        try container.encode("plot", forKey: .outputType)
        try super.encode(to: encoder)
    }
    
    override func initPreferences() {
        TZPlot.preferencesGetter?.getPreferences(self)
    }
}

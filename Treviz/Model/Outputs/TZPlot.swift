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
    
    static var solid = TZLineStyle(color: CGColor.black, lineWidth: 2.0)
}

/**Options for plot symbol shapes*/
enum TZPlotSymbol: String, CaseIterable {
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
    
    func character()->String {
        switch self {
        case .none: return ""
        case .cross: return "×"
        case .circle: return "●"
        case .square: return "■"
        case .plus: return "＋"
        case .star: return "★"
        case .diamond: return "♦︎"
        case .triangle: return "▲"
        case .pentagon: return "⬟"
        case .hexagon: return "⬢"
        case .dash: return "-"
        case .snow: return "*"
        }
    }
}

struct TZLinePattern: Equatable {
    let name: String
    let nums: [CGFloat]
    
    static let solid = TZLinePattern(name: "solid", nums: [])
    static let dash = TZLinePattern(name: "dash", nums: [3, 1.5])
    static let shortDash = TZLinePattern(name: "shortDash", nums: [2,1])
    static let longDash = TZLinePattern(name: "longDash", nums: [4,2])
    static let dot = TZLinePattern(name: "dot", nums: [0.01,1.5])
    static let dashDot = TZLinePattern(name: "dashDot", nums: [4,2,0.01,2])
    static let altDash = TZLinePattern(name: "altDash", nums: [4,1,2,1])
    
    // TODO: Turn this all into multipliers on the line width, rather than fixed values
    static let allPatterns: [TZLinePattern] = [.solid, .dash, .shortDash, .longDash, .dot, .dashDot, .altDash]
}

/**Plot symbol configuration options*/
struct TZMarkerStyle {
    
    var shape: TZPlotSymbol
    var size: CGFloat
    var color: CGColor
        
    static let none = TZMarkerStyle(shape: .none, size: 1.0, color: CGColor.black)
}
/**Collection of symbols to be used for differentiating plot groups*/
typealias SymbolSet = [TZPlotSymbol]
extension SymbolSet {
    var description: String {
        if self.count == 0 { return "None" }
        let strnames: [String] = self.map({$0.character()})
        return strnames.joined(separator: ", ")
    }
    static var allSets: [SymbolSet] = []
    subscript(at index: Int)->TZPlotSymbol {
        if self.count == 0 { return .none }
        else {
            return self[index % self.count]
        }
    }
}

/**
 Used to allow the App Delegate to assign preferences for the plots based on stored User defaults
 */
protocol PlotPreferencesGetter {
    func getPreferences(_  plot: TZPlot)->PlotPreferences
}

struct PlotPreferences {
    var axesLineStyle: TZLineStyle!
    var majorGridLineStyle: TZLineStyle!
    var minorGridLineStyle: TZLineStyle!
    var isInteractive: Bool!
    var markerStyle: TZMarkerStyle!
    var symbolSet: SymbolSet!
    var mainLineStyle: TZLineStyle!
    var backgroundColor: CGColor!
    var colorMap: ColorMap!
    var mcOpacity: CGFloat!
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
}

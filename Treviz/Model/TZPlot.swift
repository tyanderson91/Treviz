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
}

/**
 Options for plot symbol shapes
 */
enum TZPlotSymbolShape {
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

/**
 Plot symbol configuration options
 */
struct TZPlotSymbol {
    
    var shape: TZPlotSymbolShape
    var size: CGFloat = 10
    var color: CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    init(_ shapeIn: TZPlotSymbolShape){
        shape = shapeIn
    }
    
    // Default symbols by shape
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

/**
 A TZPlot contains all the information required to render a plot in a TZPlotView. TZPlot is a subclass of TZOutput. The subclassing allows TZPlot to include configuration options specifically related to the plot, such as colors, axes options, and other options related to the appearance of the plot view
 */
final class TZPlot: TZOutput {
    var majorGridLineStyle = TZLineStyle(color: CGColor(gray: 0.9, alpha: 1), lineWidth: 1)
    var minorGridLineStyle = TZLineStyle(color: CGColor(gray: 0.5, alpha: 1), lineWidth: 0.5)
    var isInteractive = true
    var plotSymbol : TZPlotSymbol = .circle
    
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingsKeys.self)
        try container.encode("plot", forKey: .outputType)
        try super.encode(to: encoder)
    }
}

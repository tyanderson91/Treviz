//
//  CorePlotExtensions.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/12/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension CPTMutableLineStyle {
    convenience init(_ lineStyle: TZLineStyle){
        self.init()
        lineWidth = CGFloat(lineStyle.lineWidth)
        lineColor = CPTColor(cgColor: lineStyle.color)
    }
}

extension CPTPlotSymbol {
    static func fromTZPlotSymbol(_ plotSymbolIn: TZPlotSymbol)->CPTPlotSymbol{
        //self.init()
        var plotSymbol: CPTPlotSymbol
        switch plotSymbolIn.shape {
        case .circle:
            plotSymbol = CPTPlotSymbol.ellipse()
        case .cross:
            plotSymbol = CPTPlotSymbol.cross()
        case .square:
            plotSymbol = CPTPlotSymbol.rectangle()
        case .plus:
            plotSymbol = CPTPlotSymbol.plus()
        case .star:
            plotSymbol = CPTPlotSymbol.star()
        case .diamond:
            plotSymbol = CPTPlotSymbol.diamond()
        case .triangle:
            plotSymbol = CPTPlotSymbol.triangle()
        case .pentagon:
            plotSymbol = CPTPlotSymbol.pentagon()
        case .hexagon:
            plotSymbol = CPTPlotSymbol.hexagon()
        case .dash:
            plotSymbol = CPTPlotSymbol.dash()
        case .snow:
            plotSymbol = CPTPlotSymbol.snow()
        case .none:
            plotSymbol = CPTPlotSymbol.init()
        }
        
        plotSymbol.size = CGSize(width: plotSymbolIn.size, height: plotSymbolIn.size)
        plotSymbol.fill = CPTFill(color: CPTColor(cgColor: plotSymbolIn.color))
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineFill = CPTFill(color: CPTColor(cgColor: plotSymbolIn.color))
        plotSymbol.lineStyle = lineStyle
        return plotSymbol
    }
}

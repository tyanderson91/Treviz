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
    func setLinePattern(_ pattern: TZLinePattern){
        let lineWidth = self.lineWidth
        self.dashPattern = pattern.nums.map({NSNumber(cgFloat: $0*lineWidth)})
        self.lineCap = CGLineCap.capForPattern(pattern)
    }
}

extension CGLineCap {
    static func capForPattern(_ pattern: TZLinePattern)->CGLineCap {
        switch pattern {
        case .dashDot, .dot, .dash:
            return .round
        case .altDash, .longDash, .shortDash:
            return .butt
        default:
            return .round
        }
        return .round
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
    
    convenience init(_ plotSymbolIn: TZPlotSymbol) {
        self.init()
        switch plotSymbolIn.shape {
        case .circle:
            symbolType = .ellipse
        case .cross:
            symbolType = .cross
        case .square:
            symbolType = .rectangle
        case .plus:
            symbolType = .plus
        case .star:
            symbolType = .star
        case .diamond:
            symbolType = .diamond
        case .triangle:
            symbolType = .triangle
        case .pentagon:
            symbolType = .pentagon
        case .hexagon:
            symbolType = .hexagon
        case .dash:
            symbolType = .dash
        case .snow:
            symbolType = .snow
        case .none:
            symbolType = .none
        }
        
        size = CGSize(width: plotSymbolIn.size, height: plotSymbolIn.size)
        fill = CPTFill(color: CPTColor(cgColor: plotSymbolIn.color))
        let mlineStyle = CPTMutableLineStyle()
        mlineStyle.lineFill = CPTFill(color: CPTColor(cgColor: plotSymbolIn.color))
        lineStyle = mlineStyle
    }
}

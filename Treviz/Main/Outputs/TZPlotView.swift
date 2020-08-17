//
//  TZPlotView.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/29/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa


class TZPlotThumbnailImageCell: NSImageCell {
}

/**
 Takes a TZPlot instance and renders it as a plot using CorePlot
 */
class TZPlotView: NSObject, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var graph: CPTGraph
    var representedPlot: TZPlot
    var _plotData: OutputDataSetLines
    
    @objc var thumbnail: NSImage {
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.scale(toFitEntirePlots: graph.allPlots())
        let img = graph.imageOfLayer()
        return img
    }
    
    init(with inputPlot: TZPlot) throws {
        let defaultTheme = CPTTheme(named: .plainWhiteTheme)
        graph = (defaultTheme?.newGraph() as! CPTGraph)
        representedPlot = inputPlot
        do {
            _plotData = try representedPlot.getData()!
        } catch { throw error }
        super.init()
        create(with: representedPlot)
    }
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        let numRecords = _plotData.var1?.count
        return UInt(numRecords!)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        switch fieldEnum {
        case 0:
            return NSNumber(value: (_plotData.var1![Int(idx)]))
        case 1:
            return NSNumber(value: (_plotData.var2![Int(idx)]))
        default:
            return nil
        }
    }
    
    func create(with plot: TZPlot){
        let scatterPlot = CPTScatterPlot(frame: graph.bounds)
        scatterPlot.delegate = self
        scatterPlot.dataSource = self
        scatterPlot.plotSymbol = CPTPlotSymbol.fromTZPlotSymbol(plot.plotSymbol)
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = plot.isInteractive
        plotSpace.delegate = self
        // plotSpace.scale(toFitEntirePlots: [scatterPlot])
        plotSpace.allowsMomentum = true
        
        graph.add(scatterPlot)
        graph.paddingRight = 0
        graph.paddingTop = 0
        graph.paddingLeft = 60
        graph.paddingBottom = 60
        graph.plotAreaFrame?.masksToBorder = false
        //graph.plotAreaFrame?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        
        let majorGridLineStyle = CPTMutableLineStyle(plot.majorGridLineStyle)
        let minorGridLineStyle = CPTMutableLineStyle(plot.minorGridLineStyle)

        let axisSet: CPTXYAxisSet = graph.axisSet! as! CPTXYAxisSet
        let xaxis = axisSet.axes![0] as! CPTXYAxis
        xaxis.labelingPolicy = .automatic
        xaxis.axisConstraints = CPTConstraints(relativeOffset: 0.00)
        
        xaxis.majorGridLineStyle = minorGridLineStyle
        xaxis.minorGridLineStyle = majorGridLineStyle
        xaxis.title = "\(String(describing: plot.var1!.name)) (\(String(describing: plot.var1!.units)))"
        xaxis.titleOffset = graph.titleTextStyle!.fontSize * CGFloat(3)

        
        let yaxis = axisSet.axes![1] as! CPTXYAxis
        yaxis.labelingPolicy = .automatic
        yaxis.axisConstraints = CPTConstraints(relativeOffset: 0.00)
        yaxis.majorGridLineStyle = minorGridLineStyle
        yaxis.minorGridLineStyle = majorGridLineStyle
        yaxis.title = "\(String(describing: plot.var2!.name)) (\(String(describing: plot.var2!.units)))"
        yaxis.titleOffset = graph.titleTextStyle!.fontSize * CGFloat(3)
        
        if plot.var1?.units == plot.var2?.units { //TODO: fix this so that axes of the same length show up square
            let axesSorted = [xaxis, yaxis].sorted(by: { (axis1: CPTAxis, axis2: CPTAxis) in
                return axis1.majorTickLength > axis2.majorTickLength
            })
            let longAxis = axesSorted[0]
            let majorTickLength = longAxis.majorTickLength
            let minorTickLength = longAxis.minorTickLength
            axesSorted[1].majorTickLength = majorTickLength
            axesSorted[1].minorTickLength = minorTickLength
        }
    }
}

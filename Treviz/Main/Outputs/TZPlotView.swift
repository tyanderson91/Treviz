//
//  TZPlotView.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/29/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa


class TZPlotThumbnailImageCell: NSImageCell {
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.imageAlignment = .alignCenter
    }
}

/**
 Takes a TZPlot instance and renders it as a plot using CorePlot
 */
class TZPlotView: NSObject, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var graph: CPTGraph
    var representedPlot: TZPlot
    var _plotData: OutputDataSet
    //var plotAreaSize: CGSize!
    var plotAreaSize: (Decimal, Decimal) = (-1.0, -1.0)
    var newPlotAreaSize: (Decimal, Decimal) {
        let pa = graph.plotAreaFrame!.plotArea!
        return (pa.widthDecimal, pa.heightDecimal)
    }
    
    @objc var thumbnail: NSImage!// {
        //let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        //plotSpace.scale(toFitEntirePlots: graph.allPlots())
        //let img = graph.imageOfLayer()
        //return img
    //}
    
    init(with inputPlot: TZPlot) throws {
        let defaultTheme = CPTTheme(named: .plainWhiteTheme)
        graph = (defaultTheme?.newGraph() as! CPTGraph)
        representedPlot = inputPlot
        do {
            _plotData = try representedPlot.getData()!
        } catch { throw error }

        super.init()

        //create(with: representedPlot)
        var i = 0
        let lineStyles: [CPTMutableLineStyle] = [.init(TZLineStyle(color: .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), lineWidth: 1.0)),
            .init(TZLineStyle(color: .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0), lineWidth: 1.0)),
            .init(TZLineStyle(color: .init(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0), lineWidth: 1.0)),
        ]
        
        for (thisGroupName, thisGroupData) in _plotData.allGroups {
            let groupLinestyle = lineStyles[i]
            let lineFill = CPTFill(color: groupLinestyle.lineColor!.withAlphaComponent(0.5))
            groupLinestyle.lineFill = lineFill
            
            for thisPlotData in thisGroupData {
                let plot = addSinglePlot(from: inputPlot, plotData: thisPlotData) as! CPTScatterPlot
                
                plot.dataLineStyle = groupLinestyle
                let newSymbol = plot.plotSymbol!
                newSymbol.fill = lineFill
                newSymbol.lineStyle = .none
                newSymbol.size = CGSize(width: 10.0, height: 10.0)
                plot.plotSymbol = newSymbol
                //plot.plotSymbol = allSymbols[i]
                //plot.dataLineStyle?.lineColor = CPTColor(componentRed: 0.6, green: 0.7, blue: 0.8, alpha: 1,0)
            }
            i += 1
            // TODO: Add configurations for group here
        }
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = inputPlot.isInteractive
        plotSpace.delegate = self
        plotSpace.allowsMomentum = true
        
        graph.paddingRight = 0
        graph.paddingTop = 0
        graph.paddingLeft = 65
        graph.paddingBottom = 60
        graph.plotAreaFrame?.masksToBorder = false
        
        let majorGridLineStyle = CPTMutableLineStyle(inputPlot.majorGridLineStyle)
        let minorGridLineStyle = CPTMutableLineStyle(inputPlot.minorGridLineStyle)

        let axisSet: CPTXYAxisSet = graph.axisSet! as! CPTXYAxisSet
        
        //axisSet.xAxis.
        let xaxis = axisSet.axes![0] as! CPTXYAxis
        xaxis.labelingPolicy = .automatic
        xaxis.axisConstraints = CPTConstraints(relativeOffset: 0.00)
        
        xaxis.majorGridLineStyle = minorGridLineStyle
        xaxis.minorGridLineStyle = majorGridLineStyle
        xaxis.title = "\(String(describing: inputPlot.var1!.name)) (\(String(describing: inputPlot.var1!.units)))"
        xaxis.titleOffset = graph.titleTextStyle!.fontSize * CGFloat(3)

        let yaxis = axisSet.axes![1] as! CPTXYAxis
        yaxis.labelingPolicy = .automatic
        yaxis.axisConstraints = CPTConstraints(relativeOffset: 0.00)
        yaxis.majorGridLineStyle = minorGridLineStyle
        yaxis.minorGridLineStyle = majorGridLineStyle
        yaxis.title = "\(String(describing: inputPlot.var2!.name)) (\(String(describing: inputPlot.var2!.units)))"
        yaxis.titleOffset = graph.titleTextStyle!.fontSize * CGFloat(3.5)
        
        plotSpace.scale(toFitEntirePlots: graph.allPlots())
        graph.layoutSublayers()
        if inputPlot.var1?.units == inputPlot.var2?.units {
            enforceEqualAxes(xScale: 1.0, yScale: 1.0)
            thumbnail = graph.imageOfLayer()
            guard let plotArea = graph.plotAreaFrame?.plotArea else { return }
            NotificationCenter.default.addObserver(self, selector: #selector(self.didResizePlotArea), name: NSNotification.Name( CPTLayerNotification.boundsDidChange.rawValue), object: plotArea)
        } else { thumbnail = graph.imageOfLayer() }
        /*
        guard let plotArea = graph.plotAreaFrame?.plotArea else { return }
        if inputPlot.var1?.units == inputPlot.var2?.units {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didResizePlotArea), name: NSNotification.Name( CPTLayerNotification.boundsDidChange.rawValue), object: plotArea)
        }*/
    }
    
    @objc func didResizePlotArea(notification: NSNotification) {
        if plotAreaSize.0 > 0  && plotAreaSize.1 > 0 { // Default before setup
            enforceEqualAxes(xScale: newPlotAreaSize.0/plotAreaSize.0, yScale: newPlotAreaSize.1/plotAreaSize.1)
        }
        plotAreaSize = newPlotAreaSize
    }
    
    // MARK: Scatter Plot Delegate functions
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        //let newName : String = (plot.name?.replacingOccurrences(of: "_", with: ", "))!
        guard let thisDataSet = _plotData.allDataSets?.first(where: {$0.identifier == plot.name}) else { return 0 }
        let numRecords = thisDataSet.var1?.count
        return UInt(numRecords!)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        guard let thisDataSet = _plotData.allDataSets?.first(where: {$0.identifier == plot.name}) else { return nil }
        switch fieldEnum {
        case 0:
            return NSNumber(value: (thisDataSet.var1![Int(idx)]))
        case 1:
            return NSNumber(value: (thisDataSet.var2![Int(idx)]))
        default:
            return nil
        }
    }

    
    private func enforceEqualAxes(xScale: Decimal, yScale: Decimal) {
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        let maxX = plotSpace.xRange.lengthDecimal*xScale
        let maxY = plotSpace.yRange.lengthDecimal*yScale
        let xLoc = plotSpace.xRange.locationDecimal
        let yLoc = plotSpace.yRange.locationDecimal
        let maxSize = [maxX, maxY].max()!
        
        if xScale == 1.0 && yScale == 1.0 {
            plotSpace.xRange = CPTPlotRange(locationDecimal: xLoc, lengthDecimal: maxSize)
            plotSpace.yRange = CPTPlotRange(locationDecimal: yLoc, lengthDecimal: maxSize)
        }
        if xScale != 1.0 {
            plotSpace.xRange = CPTPlotRange(locationDecimal: xLoc, lengthDecimal: maxX)
        }
        if yScale != 1.0 {
            plotSpace.yRange = CPTPlotRange(locationDecimal: yLoc, lengthDecimal: maxY)
        }
    }
    
    func addSinglePlot(from plot: TZPlot, plotData: OutputDataSetSingle)->CPTPlot {
        let scatterPlot = CPTScatterPlot(frame: graph.bounds)
        scatterPlot.delegate = self
        scatterPlot.dataSource = self
        scatterPlot.plotSymbol = CPTPlotSymbol.fromTZPlotSymbol(plot.plotSymbol)
        scatterPlot.name = plotData.identifier
        graph.add(scatterPlot)
        
        return scatterPlot
    }
}

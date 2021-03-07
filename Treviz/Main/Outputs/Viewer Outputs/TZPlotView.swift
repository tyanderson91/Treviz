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
        self.imageScaling = .scaleProportionallyUpOrDown
    }
}

/**
 Takes a TZPlot instance and renders it as a plot using CorePlot
 */
class TZPlotView: NSObject, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var graph: CPTGraph
    var representedPlot: TZPlot
    var _plotData: OutputDataSet
    private var plotAreaSize: (Decimal, Decimal) = (-1.0, -1.0)
    private var plotArea: CPTPlotArea { return graph.plotAreaFrame!.plotArea! }
    private var newPlotAreaSize: (Decimal, Decimal) {
        return (plotArea.widthDecimal, plotArea.heightDecimal)
    }
    @objc var thumbnail: NSImage!
    
    /*
    func getThumbnail() {
        thumbnail = graph.imageOfLayer()
        var dims = thumbnail.size
        if dims.width > dims.height {
            dims.width = dims.height
        } else {
            dims.height = dims.width
        }
    }*/
    
    init(with inputPlot: TZPlot) throws {
        let defaultTheme = CPTTheme(named: .plainWhiteTheme)
        graph = (defaultTheme?.newGraph() as! CPTGraph)
        representedPlot = inputPlot
        do {
            _plotData = try representedPlot.getData()!
        } catch { throw error }

        super.init()
        let colorMapName = UserDefaults.standard.string(forKey: "color_map") ?? "default"
        let colorMap = ColorMap.allMaps.first(where: {$0.name == colorMapName}) ?? ColorMap.defaultMap
        var i = 0
        
        let multiGroup = _plotData.allGroups.count > 1

        for (thisGroupName, thisGroupData) in _plotData.allGroups {
            var thisColor: CGColor
            var groupLinestyle: CPTMutableLineStyle
            
            if multiGroup {
                thisColor = colorMap.colors[i]
            } else {
                thisColor = CGColor.black
            }
            groupLinestyle = CPTMutableLineStyle.init(TZLineStyle(color: thisColor, lineWidth: 3.0))
            let lineFill = CPTFill(color: groupLinestyle.lineColor!.withAlphaComponent(0.5))
            groupLinestyle.lineFill = lineFill
            
            let multiSets = thisGroupData.count > 1
            if multiSets { // If many data sets of the same group, apply some transparency
                let lineFill = CPTFill(color: groupLinestyle.lineColor!.withAlphaComponent(0.5))
                groupLinestyle.lineFill = lineFill
            } else {
                let lineFill = CPTFill(color: groupLinestyle.lineColor!.withAlphaComponent(1.0))
                groupLinestyle.lineFill = lineFill
            }
            
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
        
        graph.plotAreaFrame?.plotArea?.backgroundColor = CGColor(gray: 0.95, alpha: 1.0)
        graph.paddingRight = 0
        graph.paddingTop = 0
        graph.paddingLeft = 65 // TODO: Offset by axis label width
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
        graph.layoutIfNeeded()
        if inputPlot.var1?.units == inputPlot.var2?.units {
            enforceEqualAxes(xScale: 1.0, yScale: 1.0)
            thumbnail = graph.imageOfLayer()
            NotificationCenter.default.addObserver(self, selector: #selector(self.didResizePlotArea), name: NSNotification.Name( CPTLayerNotification.boundsDidChange.rawValue), object: plotArea)
        } else {
            thumbnail = graph.imageOfLayer()
        }
    }
    
    @objc func didResizePlotArea(notification: NSNotification) {
        if plotAreaSize.0 < 0 && plotAreaSize.1 < 0 { // First time initialization
            plotAreaSize = newPlotAreaSize
        }
        enforceEqualAxes(xScale: newPlotAreaSize.0/plotAreaSize.0, yScale: newPlotAreaSize.1/plotAreaSize.1)
        plotAreaSize = newPlotAreaSize
    }
    
    // MARK: Scatter Plot Delegate functions
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
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
        
        let areaWidth = newPlotAreaSize.0
        let areaHeight = newPlotAreaSize.1
        let yRes = maxY/areaHeight
        let xRes = maxX/areaWidth
        let maxRes = [yRes, xRes].max()!
        
        if xScale == 1.0 && yScale == 1.0 {
            plotSpace.xRange = CPTPlotRange(locationDecimal: xLoc, lengthDecimal: maxRes*areaWidth)
            plotSpace.yRange = CPTPlotRange(locationDecimal: yLoc, lengthDecimal: maxRes*areaHeight)
        }
        if xScale != 1.0 {
            plotSpace.xRange = CPTPlotRange(locationDecimal: xLoc, lengthDecimal: maxRes*areaWidth)
        }
        if yScale != 1.0 {
            plotSpace.yRange = CPTPlotRange(locationDecimal: yLoc, lengthDecimal: maxRes*areaHeight)
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

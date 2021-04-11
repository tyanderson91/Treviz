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
class TZPlotView: NSObject, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate, CPTLegendDelegate {
    
    var graph: CPTGraph
    var representedPlot: TZPlot
    var _plotData: OutputDataSet
    var legendBorderStyle : CPTLineStyle {
        let style = CPTMutableLineStyle()
        style.lineWidth = 1.0
        style.lineColor = CPTColor.black()
        return CPTLineStyle(style: style)
    }
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
        let prefs = TZPlot.preferencesGetter!.getPreferences(inputPlot)
        
        let defaultTheme = CPTTheme(named: .plainWhiteTheme)
        graph = (defaultTheme?.newGraph() as! CPTGraph)
        representedPlot = inputPlot
        do {
            _plotData = try representedPlot.getData()!
        } catch { throw error }

        super.init()
        
        // Get default properties from user inputs
        let colorMap = prefs.colorMap!
        let mcOpacity = UserDefaults.mcOpacity
        let lineStyle = prefs.lineStyle!
        
        var i = 0
        let multiGroup = _plotData.allGroups.count > 1
        var legendPlots: [CPTPlot] = []
        let ngroups = _plotData.allGroups.count
        let ncolors = colorMap.colors.count
        
        for (thisGroupName, thisGroupData) in _plotData.allGroups {
            var thisColor: CGColor
            var groupLinestyle: CPTMutableLineStyle
            
            if multiGroup {
                if colorMap.isContinuous {
                    let colorPct: Float = Float(i)/Float(ngroups-1)
                    thisColor = colorMap[colorPct] ?? CGColor.black
                } else {
                    let color_index = i % (ncolors)
                    thisColor = colorMap[color_index]!
                }
            } else {
                thisColor = lineStyle.color
            }
            let curLineStyle = TZLineStyle(color: thisColor, lineWidth: lineStyle.lineWidth, pattern: lineStyle.pattern)
            groupLinestyle = CPTMutableLineStyle.init(curLineStyle)
            var lineFill: CPTFill
            
            let multiSets = thisGroupData.count > 1
            if multiSets { // If many data sets of the same group, apply some transparency
                lineFill = CPTFill(color: groupLinestyle.lineColor!.withAlphaComponent(mcOpacity))
                groupLinestyle.lineFill = lineFill
            } else {
                lineFill = CPTFill(color: groupLinestyle.lineColor!.withAlphaComponent(1.0))
                groupLinestyle.lineFill = lineFill
            }
            
            var j = 0
            for thisPlotData in thisGroupData {
                let plot = addSinglePlot(from: inputPlot, plotData: thisPlotData) as! CPTScatterPlot
                plot.dataLineStyle = groupLinestyle
                plot.title = thisGroupName
                if j==0 { // Add the first of the group into the legend
                    legendPlots.append(plot)
                }
                j += 1
            }
            i += 1
            // TODO: Add configurations for group here
        }
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = prefs.isInteractive
        plotSpace.delegate = self
        plotSpace.allowsMomentum = true
        
        graph.plotAreaFrame?.plotArea?.backgroundColor = UserDefaults.backgroundColor
        graph.paddingRight = 0
        graph.paddingTop = 0
        graph.paddingLeft = 65 // TODO: Offset by axis label width
        graph.paddingBottom = 60
        graph.plotAreaFrame?.masksToBorder = false
        
        let majorGridLineStyle = CPTMutableLineStyle(prefs.majorGridLineStyle)
        let minorGridLineStyle = CPTMutableLineStyle(prefs.minorGridLineStyle)
        let axesLineStyle = CPTMutableLineStyle(prefs.axesLineStyle)

        let axisSet: CPTXYAxisSet = graph.axisSet! as! CPTXYAxisSet
        
        let xaxis = axisSet.axes![0] as! CPTXYAxis
        xaxis.labelingPolicy = .automatic
        xaxis.axisConstraints = CPTConstraints(relativeOffset: 0.00)
        
        xaxis.axisLineStyle = axesLineStyle
        xaxis.majorGridLineStyle = majorGridLineStyle
        xaxis.minorGridLineStyle = minorGridLineStyle
        xaxis.title = "\(String(describing: inputPlot.var1!.name)) (\(String(describing: inputPlot.var1!.units)))"
        xaxis.titleOffset = graph.titleTextStyle!.fontSize * CGFloat(3)

        let yaxis = axisSet.axes![1] as! CPTXYAxis
        yaxis.labelingPolicy = .automatic
        yaxis.axisConstraints = CPTConstraints(relativeOffset: 0.00)
        
        yaxis.axisLineStyle = axesLineStyle
        yaxis.majorGridLineStyle = majorGridLineStyle
        yaxis.minorGridLineStyle = minorGridLineStyle
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
        
        if multiGroup {
            let legend = CPTLegend(plots: legendPlots)
            legend.fill = CPTFill(color: CPTColor.white())
            legend.borderLineStyle = legendBorderStyle
            legend.cornerRadius = 5.0
            legend.numberOfRows = UInt(legendPlots.count)
            //legend.numberOfColumns = 1
            let legLineWidth = UserDefaults.mainLineWidth
            legend.swatchSize = CGSize(width: 8*legLineWidth, height: legLineWidth*1.5)
            
            graph.legend = legend
            graph.legendAnchor = CPTRectAnchor.topRight
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

    // MARK: Helper functions
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
        scatterPlot.plotSymbol = CPTPlotSymbol(plot.plotPreferences.plotSymbol)
        scatterPlot.name = plotData.identifier
        graph.add(scatterPlot)
        
        return scatterPlot
    }
}

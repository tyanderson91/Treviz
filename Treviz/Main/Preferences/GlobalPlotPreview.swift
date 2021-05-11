//
//  GlobalPlotPreview.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/17/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Cocoa
import CorePlot

protocol PlotPreviewDisplay {
    var graph: CPTGraph! { get set }
    func applyPrefs()
}

class GlobalPlotPreview: NSObject, PlotPreviewDisplay, CPTPlotSpaceDelegate {
    var graph: CPTGraph!
    private var plotArea: CPTPlotArea { return graph.plotAreaFrame!.plotArea! }
    var plotSpace: CPTXYPlotSpace
    var xaxis: CPTXYAxis
    var yaxis: CPTXYAxis
    var legend: CPTLegend?
    let plotRange = 5.0
    
    var singleScatterDelegate: LinesPreviewDelegate
    var singleMCScatterDelegate: LinesPreviewDelegate
    var tradeScatterDelegate: LinesPreviewDelegate
    var tradeMCScatterDelegate: LinesPreviewDelegate
    
    func applyPrefs(){
        let prefs = UserDefaults.plotPreferences
        if plotSpace.allowsUserInteraction && !prefs.isInteractive { // Snap back to standard view if interacton is turned off
            plotSpace.xRange = CPTPlotRange(location: NSNumber(value: -plotRange), length: NSNumber(value: 2*plotRange))
            plotSpace.yRange = CPTPlotRange(location: NSNumber(value: -plotRange), length: NSNumber(value: 2*plotRange))
        }
        plotSpace.allowsUserInteraction = prefs.isInteractive
        
        xaxis.axisLineStyle = CPTMutableLineStyle(prefs.axesLineStyle)
        xaxis.majorGridLineStyle = CPTMutableLineStyle(prefs.majorGridLineStyle)
        xaxis.minorGridLineStyle = CPTMutableLineStyle(prefs.minorGridLineStyle)
        
        yaxis.axisLineStyle = CPTMutableLineStyle(prefs.axesLineStyle)
        yaxis.majorGridLineStyle = CPTMutableLineStyle(prefs.majorGridLineStyle)
        yaxis.minorGridLineStyle = CPTMutableLineStyle(prefs.minorGridLineStyle)
        
        plotArea.backgroundColor = prefs.backgroundColor
        
        singleScatterDelegate.updateFromPrefs(prefs: prefs)
        singleMCScatterDelegate.updateFromPrefs(prefs: prefs)
        tradeScatterDelegate.updateFromPrefs(prefs: prefs)
        tradeMCScatterDelegate.updateFromPrefs(prefs: prefs)
        
        legend?.fill = CPTFill(color: CPTColor(cgColor: prefs.backgroundColor))
    }
    
    override init(){
        // Graph settings
        let defaultTheme = CPTTheme(named: .plainWhiteTheme)
        graph = (defaultTheme?.newGraph() as! CPTGraph)
        graph.paddingRight = 5
        graph.paddingTop = 5
        graph.paddingLeft = 50 // TODO: Offset by axis label width
        graph.paddingBottom = 50
        
        // Plot Space Settings
        graph.plotAreaFrame?.masksToBorder = false
        plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.allowsMomentum = true
        plotSpace.xRange = CPTPlotRange(location: NSNumber(value: -plotRange), length: NSNumber(value: 2*plotRange))
        plotSpace.yRange = CPTPlotRange(location: NSNumber(value: -plotRange), length: NSNumber(value: 2*plotRange))
        plotSpace.globalXRange = plotSpace.xRange
        plotSpace.globalYRange = plotSpace.yRange
        
        // Axis Settings
        let axisSet: CPTXYAxisSet = graph.axisSet as! CPTXYAxisSet
        xaxis = axisSet.axes![0] as! CPTXYAxis
        xaxis.labelingPolicy = .automatic
        xaxis.axisConstraints = CPTConstraints(relativeOffset: 0.00)
        xaxis.title = "X Variable (units)"
        xaxis.titleOffset = graph.titleTextStyle!.fontSize * CGFloat(2.5)

        yaxis = axisSet.axes![1] as! CPTXYAxis
        yaxis.labelingPolicy = .automatic
        yaxis.axisConstraints = CPTConstraints(relativeOffset: 0.00)
        yaxis.minorTickLabelRotation = CGFloat(PI/2)
        yaxis.labelRotation = CGFloat(PI/2)
        yaxis.title = "Y Variable (units)"
        yaxis.titleOffset = graph.titleTextStyle!.fontSize * CGFloat(2.5)
        
        // Scatter Plots
        singleScatterDelegate = LinesPreviewDelegate(graph: graph, mc: false, trade: false)
        singleMCScatterDelegate = LinesPreviewDelegate(graph: graph, mc: true, trade: false)
        tradeScatterDelegate = LinesPreviewDelegate(graph: graph, mc: false, trade: true)
        tradeMCScatterDelegate = LinesPreviewDelegate(graph: graph, mc: true, trade: true)
        
        // Legend
        let legendPlots = [singleScatterDelegate.scatterPlots.first!, singleMCScatterDelegate.scatterPlots.first!, tradeScatterDelegate.scatterPlots.first!, tradeMCScatterDelegate.scatterPlots.first!]
        
        legend = CPTLegend(plots: legendPlots)
        legend?.numberOfRows = 4
        legend?.cornerRadius = 5.0
        legend?.borderColor = .black
        legend?.borderWidth = 1.0
        graph.legend = legend
        graph.legendAnchor = .topRight
        graph.legendDisplacement = CGPoint(x: 0, y: 0)
        
        // Final setup
        super.init()
        plotSpace.delegate = self
        //plotSpace.scale(toFitEntirePlots: graph.allPlots())
        applyPrefs()
        graph.layoutIfNeeded()
    }
}

class LinesPreviewDelegate: NSObject, CPTScatterPlotDelegate, CPTScatterPlotDataSource {
    var graph: CPTGraph
    let baseX: [Float] =  [0.01, 0.1, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 2, 2.2, 2.4, 2.6, 3, 4, 5, 6, 7, 8, 9]
    let rOffsets: [Float] = [6.845, 5.78, 4.805, 3.92, 3.125, 2.42, 1.805, 1.28]
    let symbolX: [Float] = [1.45, 1.499, 1.604, 1.817, 2.235, 2.893, 3.687, 4.528]
    var nMCs: Int
    var scatterPlots = [CPTScatterPlot]()
    let isMC: Bool
    let isTrade: Bool
    var scaleCenterIndex: Int = 12
    
    @objc(_TtCC6Treviz20LinesPreviewDelegate14PreviewPlotID)class PreviewPlotID: NSObject, NSCoding, NSCopying {
        func encode(with coder: NSCoder) { }
        required init?(coder: NSCoder) { return nil }
        func copy(with zone: NSZone? = nil) -> Any {
            return PreviewPlotID(group: self.groupID, mc: self.mcID)
        }
        let mcOffset: Float = 0.2
        let mcScale: Float = 0.15
        
        let mcID: Int
        let groupID: Int
        var randXOffset: Float = 0
        var randXScale: Float = 1
        var randYOffset: Float = 0
        var randYScale: Float = 1
        
        init(group: Int, mc: Int){
            mcID = mc
            groupID = group
            super.init()
        }
        func getRand(){
            if mcID>=0 {
                randXOffset = Float.random(in: -mcOffset...mcOffset)
                randYOffset = Float.random(in: -mcOffset...mcOffset)
                randXScale = Float.random(in: (1-mcScale)...(1+mcScale))
                randYScale = Float.random(in: (1-mcScale)...(1+mcScale))
            }
        }
    }
    
    init(graph graphIn: CPTGraph, mc: Bool, trade: Bool){
        graph = graphIn
        isMC = mc
        isTrade = trade
        nMCs = isTrade ? 4 : 10
        
        let swatchPlot = CPTScatterPlot(frame: graph.bounds)
        swatchPlot.title = isTrade ? "Trade Group" : "Single"
        if isMC {
            swatchPlot.title = "\(swatchPlot.title!)\nMonte-Carlo"
        }
        scatterPlots.append(swatchPlot)
        
        let nGroups = isTrade ? rOffsets.count : 1
        for k in 0...nGroups-1 {
            let groupID: Int = isTrade ? k : -1
            if isMC
            {
                for i in 0...nMCs-1 {
                    let scatterPlot = CPTScatterPlot(frame: graph.bounds)
                    scatterPlot.identifier = PreviewPlotID(group: groupID, mc: i)
                    scatterPlots.append(scatterPlot)
                }
            } else {
                let scatterPlot = CPTScatterPlot(frame: graph.bounds)
                scatterPlot.identifier = PreviewPlotID(group: groupID, mc: -1)
                scatterPlots.append(scatterPlot)
                
                // Marker
                let symbolPlot = CPTScatterPlot(frame: graph.bounds)
                symbolPlot.identifier = PreviewPlotID(group: groupID, mc: -2)
                symbolPlot.dataLineStyle = nil
                scatterPlots.append(symbolPlot)
            }
        }
        
        super.init()
        scatterPlots.forEach({
            $0.delegate = self
            $0.dataSource = self
            graph.add($0)
        })
    }
    
    func updateFromPrefs(prefs: PlotPreferences){
        let cmap = prefs.colorMap
        let baseLine = CPTMutableLineStyle(prefs.mainLineStyle)
        let baseMarker = prefs.markerStyle
        let swatchPlot = scatterPlots.first
        var swatchGradient = CPTGradient()
        if isTrade {
            let nGroups = rOffsets.count
            for c in 0...nGroups - 1 {
                let curPlots = scatterPlots.filter(
                    { if let curID = $0.identifier as? PreviewPlotID { return curID.groupID == c && curID.mcID >= -1 } else { return false }
                })
                let newLine = baseLine
                let newCGColor: CGColor = cmap?[c, nGroups] ?? .black
                var newColor = CPTColor(cgColor: newCGColor)
                if isMC {
                    newColor = newColor.withAlphaComponent(prefs.mcOpacity)
                }
                swatchGradient = swatchGradient.addColorStop(newColor, atPosition: CGFloat(c)/(CGFloat(nGroups)-1))
                newLine.lineColor = newColor
                curPlots.forEach({$0.dataLineStyle = newLine})
                
                // Marker
                var newMarker = baseMarker
                newMarker?.shape = prefs.symbolSet[at: c]
                newMarker?.color = newCGColor
                let symbolPlots = scatterPlots.filter(
                    { if let curID = $0.identifier as? PreviewPlotID { return curID.groupID == c && curID.mcID == -2 } else { return false }
                })
                symbolPlots.forEach({
                    $0.plotSymbol = CPTPlotSymbol(newMarker!)
                    $0.setNeedsDisplay()
                })
            }
            let swatchLine = baseLine
            swatchGradient.angle = CGFloat(0)
            swatchGradient.gradientType = .axial
            swatchLine.lineColor = .none
            swatchLine.lineFill = CPTFill(gradient: swatchGradient)
            swatchPlot?.dataLineStyle = swatchLine
        } else {
            let newLineStyle = CPTMutableLineStyle(prefs.mainLineStyle)
            let curPlots = scatterPlots.filter(
                { if let curID = $0.identifier as? PreviewPlotID { return curID.groupID == -1 && curID.mcID >= -1 } else { return false }
            })
            if isMC {
                newLineStyle.lineColor = newLineStyle.lineColor?.withAlphaComponent(prefs.mcOpacity)
            }
            scatterPlots.first?.dataLineStyle = newLineStyle // Swatch
            curPlots.forEach({$0.dataLineStyle = newLineStyle})
            let symbolPlots = scatterPlots.filter({($0.identifier as? PreviewPlotID)?.mcID == -2})
            symbolPlots.forEach({
                $0.plotSymbol = CPTPlotSymbol(baseMarker!)
            })
        }
        if isMC {
            scatterPlots.forEach({
                guard let plotID = $0.identifier as? PreviewPlotID else { return }
                plotID.getRand()
                $0.reloadData()
            })
        }
        
    }
    
    // MARK: CPTScatterPlotDelegate
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        if (plot.identifier as? PreviewPlotID)?.mcID == -2 {
            return UInt(1)
        } else {
            return UInt(baseX.count)
        }
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        guard let id = plot.identifier as? PreviewPlotID else { return NSNumber(value: 10 + idx) }
        let thisR = isTrade ? rOffsets[id.groupID] : 2.0
        let ind = Int(idx)
        let xmult: Float = isTrade == isMC ? 1 : -1
        let ymult: Float = isMC ? -1 : 1
        
        if id.mcID == -2 { // Symbol
            let thisGroup = isTrade ? id.groupID : 1
            let thisX = symbolX[thisGroup]
            switch fieldEnum {
            case 0: return NSNumber(value: thisX*xmult)
            case 1: return NSNumber(value: thisR/thisX*ymult)
            default: return nil
            }
        }
        
        let y = baseX.map({thisR/$0})
        let x = baseX
        let yoffset = (1-id.randYScale)*y[scaleCenterIndex] + id.randYOffset
        let xoffset = (1-id.randXScale)*x[scaleCenterIndex] + id.randXOffset
        
        switch fieldEnum {
        case 0:
            return NSNumber(value: (x[ind]*id.randXScale+xoffset)*xmult)
        case 1:
            return NSNumber(value: (y[ind]*id.randYScale+yoffset)*ymult)
        default:
            return nil
        }
    }
}

//
//  TZPlotView.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/29/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }

        return nil
    }
}

class TZPlotThumbnailImageCell: NSImageCell {
}

class TZPlotView: NSObject, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {
    
    var graph: CPTGraph
    var representedPlot: TZPlot
    @objc var thumbnail: NSImage {
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.scale(toFitEntirePlots: graph.allPlots())
        let img = graph.imageOfLayer()
        return img
    }
    
    init(with inputPlot: TZPlot){
        let defaultTheme = CPTTheme(named: .plainWhiteTheme)
        graph = (defaultTheme?.newGraph() as! CPTGraph)
        representedPlot = inputPlot
        super.init()
        create(with: representedPlot)
    }
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        let numRecords = representedPlot.var1?.value.count
        return UInt(numRecords!)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        switch fieldEnum {
        case 0:
            return NSNumber(value: (representedPlot.var1?.value[Int(idx)])!)
        case 1:
            return NSNumber(value: (representedPlot.var2?.value[Int(idx)])!)
        default:
            return nil
        }
    }
    
    func create(with plot: TZPlot){
        let scatterPlot = CPTScatterPlot(frame: graph.bounds)
        scatterPlot.delegate = self
        scatterPlot.dataSource = self
        scatterPlot.plotSymbol = .cross()
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.delegate = self
        // plotSpace.scale(toFitEntirePlots: [scatterPlot])
        //plotSpace.allowsMomentum = true

        graph.add(scatterPlot)
        graph.paddingRight = 0
        graph.paddingTop = 0
        graph.paddingLeft = 20
        graph.paddingBottom = 20
        //plotSpace.scale(by: 2, aboutPoint: CGPoint(x: 0, y: 0))

        let xaxis = graph.axisSet!.axes![0]
        let yaxis = graph.axisSet!.axes![1]
        xaxis.labelingPolicy = .automatic
        yaxis.labelingPolicy = .automatic
        if plot.var1?.units == plot.var2?.units {
            _ = [xaxis, yaxis].sorted(by: { (axis1: CPTAxis, axis2: CPTAxis) in
                return axis1.majorTickLength > axis2.majorTickLength
            })
        }
    }
}

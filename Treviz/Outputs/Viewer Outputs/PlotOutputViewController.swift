//
//  PlotOutputViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/28/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

class PlotOutputViewController: NSViewController, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate {

    

    var graph: CPTGraph!
    var graphHostingView: CPTGraphHostingView { return self.view as! CPTGraphHostingView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultTheme = CPTTheme(named: .plainWhiteTheme)
        graph = (defaultTheme?.newGraph() as! CPTGraph)
        graphHostingView.hostedGraph = graph
        let scatterPlot = CPTScatterPlot(frame: graph.bounds)
        graph.add(scatterPlot)
        scatterPlot.delegate = self
        scatterPlot.dataSource = self
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.delegate = self
        plotSpace.scale(toFit: [scatterPlot])
    }
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return 20
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        switch fieldEnum {
        case 0:
            return NSNumber(value: idx)
        case 1:
            return NSNumber(value: 2*idx)
        default:
            return nil
        }
    }
}

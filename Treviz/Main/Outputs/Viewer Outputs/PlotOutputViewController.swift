//
//  PlotOutputViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/28/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSUserInterfaceItemIdentifier {
    static let plotThumbnailTableCellView = NSUserInterfaceItemIdentifier(rawValue: "plotThumbnailTableCellView")
}

class PlotOutputViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource {//}, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate  {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    
    @objc var plotViews: [TZPlotView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
    }
    
    func createPlot(plot: TZPlot) throws {
        let newGraph = try TZPlotView(with: plot)
        plotViews.append(newGraph)
        //graph.defaultPlotSpace?.allowsUserInteraction = true
        graphHostingView.hostedGraph = newGraph.graph
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return plotViews.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let curPlot = plotViews[row]
        let tableCellView =  tableView.makeView(withIdentifier: .plotThumbnailTableCellView, owner: self) as? NSTableCellView
        let imageView = tableCellView!.imageView!
        imageView.image = curPlot.thumbnail
        return tableCellView
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return plotViews[row]
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let newPlotView = plotViews[tableView.selectedRow]
        graphHostingView.hostedGraph = newPlotView.graph
    }
}

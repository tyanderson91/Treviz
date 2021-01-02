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

class PlotOutputSplitViewController: TZSplitViewController, TZPlotOutputViewer {
    
    @IBOutlet weak var selectorTabViewItem: NSSplitViewItem!
    @IBOutlet weak var viewerTabViewItem: NSSplitViewItem!
    var selectorViewController: PlotOutputSelectorViewController! {
        guard let vc = selectorTabViewItem.viewController as? PlotOutputSelectorViewController else { return nil }
        vc.parentSplitViewController = self
        return vc
    }
    var viewerViewController: PlotOutputViewerViewController! {
        guard let vc = viewerTabViewItem.viewController as? PlotOutputViewerViewController else { return nil }
        vc.parentSplitViewController = self
        return vc
    }
    
    var tableView: NSTableView! { return selectorViewController.tableView }
    var plotViews: [TZPlotView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        let newWidth = selectorViewController.view.bounds.width
        tableView.rowHeight = newWidth
        /*if abs((newWidth - selectorViewController.storedWidth)/selectorViewController.storedWidth) > 0.2  {
            selectorViewController.storedWidth = newWidth
            plotViews.forEach { $0.getThumbnail() }
        }*/
        //selectorViewController.storedWidth = newWidth
        tableView.reloadData()
        selectorViewController.maxWidthConstraint.constant = splitView.bounds.width/2
    }
    
    // MARK: TZPlotOutputViewer
    func clearPlots() {
        plotViews = []
    }
    func createPlot(plot: TZPlot) throws {
        let newGraph = try TZPlotView(with: plot)
        plotViews.append(newGraph)
        //graph.defaultPlotSpace?.allowsUserInteraction = true
        viewerViewController.graphHostingView.hostedGraph = newGraph.graph
        tableView.reloadData()
        let newWidth = selectorViewController.view.bounds.width
        tableView.rowHeight = newWidth
    }
}

class PlotOutputSelectorViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource {
    var parentSplitViewController: PlotOutputSplitViewController!
    var plotViews: [TZPlotView]! { return parentSplitViewController?.plotViews ?? [] }
    var graphHostingView: CPTGraphHostingView? { return parentSplitViewController.viewerViewController.graphHostingView }
    @IBOutlet weak var maxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var minWidthConstraint: NSLayoutConstraint!
    //var storedWidth: CGFloat = 0
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        //storedWidth = 100
        tableView.allowsColumnResizing = false
        tableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
    }

    
    // MARK: TableViewDelegate and DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return plotViews.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let curPlot = plotViews[row]
        let tableCellView =  tableView.makeView(withIdentifier: .plotThumbnailTableCellView, owner: self) as? NSTableCellView
        let imageView = tableCellView!.imageView!
        imageView.image = curPlot.thumbnail
        imageView.imageAlignment = .alignCenter
        return tableCellView
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return plotViews[row]
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let newPlotView = plotViews[tableView.selectedRow]
        graphHostingView!.hostedGraph = newPlotView.graph
    }
}

class PlotOutputViewerViewController: TZViewController {
    var parentSplitViewController: PlotOutputSplitViewController!
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    var plotViews: [TZPlotView]! { return parentSplitViewController?.plotViews ?? []}
}

class PlotOutputViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource, TZPlotOutputViewer {//}, CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotSpaceDelegate  {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    
    @objc var plotViews: [TZPlotView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: TZPlotOutputViewer
    func clearPlots() {
        plotViews = []
    }
    func createPlot(plot: TZPlot) throws {
        let newGraph = try TZPlotView(with: plot)
        plotViews.append(newGraph)
        //graph.defaultPlotSpace?.allowsUserInteraction = true
        graphHostingView.hostedGraph = newGraph.graph       
        tableView.reloadData()
    }
    
    // MARK: TableViewDelegate and DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return plotViews.count
    }
    

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let curPlot = plotViews[row]
        let tableCellView =  tableView.makeView(withIdentifier: .plotThumbnailTableCellView, owner: self) as? NSTableCellView
        let imageView = tableCellView!.imageView!
        imageView.image = curPlot.thumbnail
        imageView.imageAlignment = .alignCenter
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

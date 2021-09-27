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

/**
 SplitView dividing the plot viewer from the plot view selector
 */
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
        tableView.tableColumns[0].width = newWidth
        let r = tableView.selectedRow
        tableView.reloadData()
        tableView.selectRowIndexes(IndexSet(integer: r), byExtendingSelection: false)
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
        let newWidth = selectorViewController.defaultWidth//selectorViewController.view.bounds.width
        tableView.rowHeight = newWidth
        tableView.tableColumns[0].width = newWidth
        splitView.setPosition(newWidth, ofDividerAt: 0)
    }
    func didCreatePlots() {
    }
}
class PlotSelectorScrollView: NSScrollView {
    var currentScrollIsHorizontal: Bool = true;

    override func scrollWheel(with event: NSEvent) { // https://stackoverflow.com/a/31930488

        let phase: NSEvent.Phase = event.phase

        // Ensure that both scrollbars are flashed when the user taps trackpad with two fingers
        if (phase == .mayBegin) {
            super.scrollWheel(with: event) ;
            self.nextResponder?.scrollWheel(with: event);
            return;
        }
        // Check the scroll direction only at the beginning of a gesture for modern scrolling devices
        // Check every event for legacy scrolling devices
        if (phase == .began || (phase == .stationary && event.momentumPhase == .stationary)) {
            currentScrollIsHorizontal = abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY);
        }
        if (!currentScrollIsHorizontal ) {
            super.scrollWheel(with: event);
        } else {
            self.nextResponder!.scrollWheel(with: event);
        }
    }
}

class PlotOutputSelectorViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource {
    let defaultWidth = CGFloat(50)
    var parentSplitViewController: PlotOutputSplitViewController!
    var plotViews: [TZPlotView]! { return parentSplitViewController?.plotViews ?? [] }
    var graphHostingView: CPTGraphHostingView? { return parentSplitViewController.viewerViewController.graphHostingView }
    @IBOutlet weak var scrollView: PlotSelectorScrollView!
    @IBOutlet weak var maxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var minWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsColumnResizing = false
        tableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        tableView.alignment = .justified
        scrollView.horizontalScrollElasticity = .none
        tableView.intercellSpacing.width = 0
        tableView.intercellSpacing.height = 0
    }
    override func viewWillAppear() {
        tableView.rowHeight = view.bounds.width
    }
    
    override func viewDidAppear() {
        parentSplitViewController.splitViewDidResizeSubviews(Notification(name: .init("someNotification")))
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

class PlotOutputViewController: TZViewController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    
    @objc var plotViews: [TZPlotView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

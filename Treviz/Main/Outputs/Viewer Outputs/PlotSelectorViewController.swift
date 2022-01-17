//
//  PlotOutputSelector1.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/1/22.
//  Copyright © 2022 Tyler Anderson. All rights reserved.
//

import Cocoa
import CorePlot

fileprivate extension NSUserInterfaceItemIdentifier {
    static var idColumn = NSUserInterfaceItemIdentifier.init(rawValue: "idColumn")
    static var titleColumn = NSUserInterfaceItemIdentifier.init(rawValue: "titleColumn")
    static var descriptionColumn = NSUserInterfaceItemIdentifier.init(rawValue: "descriptionColumn")
    static var thumbnailColumn = NSUserInterfaceItemIdentifier.init(rawValue: "thumbnailColumn")

    static var idTableCellView = NSUserInterfaceItemIdentifier.init(rawValue: "idTableCellView")
    static var titleTableCellView = NSUserInterfaceItemIdentifier.init(rawValue: "titleTableCellView")
    static var descriptionTableCellView = NSUserInterfaceItemIdentifier.init(rawValue: "descriptionTableCellView")
    static var thumbnailImageView = NSUserInterfaceItemIdentifier.init(rawValue: "thumbnailImageView")
}

/**
 This view controller presents all of the configured plots in a table view for selection. It also owns the creation and presentation of all plot views
 */
class PlotSelectorViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource, TZPlotOutputViewer {
    
    @IBOutlet weak var tableView: NSTableView!
    var plots: [TZPlot] {
        return analysis.plots.compactMap({return $0 as? TZPlot})
    }
    var selectedPlot: TZPlot? {
        let irow = tableView.selectedRow
        if irow > -1 {
            return plots[irow]
        } else { return nil }
    }
    var plotViewMap = [TZPlot: TZPlotView]()
    var tabViewController: DynamicTabViewController!
    /*
    @IBAction func newOutput(_ sender: Any) {
        let sb = NSStoryboard(name: "OutputSetup", bundle: nil)
        let newOutputVC = sb.instantiateController(withIdentifier: "newOutputViewController")
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        analysis.plotOutputViewer = self
        self.tableView.rowHeight = 40
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll), name: .addedOutput, object: nil)
    }
    @objc func reloadAll(){
        self.tableView.reloadData()
    }
    
    // MARK: TableViewDelegate and DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return plots.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        assert(plots.count>row)
        let matchingPlot = plots[row]
        
        switch tableColumn!.identifier {
        case .idColumn:
            guard let newView = tableView.makeView(withIdentifier: .idTableCellView, owner: self) as? NSTableCellView else { return nil }
            newView.textField?.stringValue = String(describing: row)
            return newView
        case .titleColumn:
            guard let newView = tableView.makeView(withIdentifier: .titleTableCellView, owner: self) as? NSTableCellView else { return nil }
            newView.textField?.stringValue = matchingPlot.title
            return newView
        case .descriptionColumn:
            guard let newView = tableView.makeView(withIdentifier: .descriptionTableCellView, owner: self) as? NSTableCellView else { return nil }
            newView.textField?.stringValue = matchingPlot.displayName
            return newView
        case .thumbnailColumn:
            guard let newView = tableView.makeView(withIdentifier: .thumbnailImageView, owner: self) as? NSImageView else { return nil }
            if let matchingImage = thumbnailForPlot(plot: matchingPlot) as? NSImage {
                newView.image = matchingImage
            } else {
                newView.image = matchingPlot.plotType.icon
            }
            return newView
            
        default:
            return nil
        }
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        let thumbnailColumnIndex = tableView.column(withIdentifier: .thumbnailColumn)
        if thumbnailColumnIndex >= 0 {
            let thumbnailColumn = tableView.tableColumns[thumbnailColumnIndex]
            tableView.rowHeight = thumbnailColumn.width
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0 {
            let selectedPlot = plots[tableView.selectedRow]
            showPlotView(plot: selectedPlot)
        }
    }
    
    func showPlotView(plot: TZPlot){
        guard let selectedPlotView = plotViewMap[plot] else { return }
        let tabName = "Plot:\(plot.title)"
        let plotTabExists = tabViewController.switchToView(title: tabName)
        if !plotTabExists {
            let sb = NSStoryboard(name: "Outputs", bundle: nil)
            let newGraphView = sb.instantiateController(identifier: "plotOutputViewer") {aCoder in
                return PlotOutputViewController(coder: aCoder, analysis: self.analysis, plotView: selectedPlotView)
            }
            newGraphView.title = tabName
            tabViewController.addViewController(controller: newGraphView)
        }
    }
    
    func thumbnailForPlot(plot: TZPlot) -> Any? {
        return plotViewMap[plot]?.thumbnail ?? nil
    }
    
    // MARK: Protocol TZPlotOutputViewer
    func clearPlots() {
        //plotViewMap = [:]
    }
    func createPlot(plot: TZPlot) throws {
        let newGraph = try TZPlotView(with: plot)
        if let _ = plotViewMap[plot], let vc = tabViewController.tabHeaderItem(named: "Plot:\(plot.title)") {
            // if the plot view currently exists as an active tab, get some configuration info from it
            guard let pvc = vc.childVC as? PlotOutputViewController else { return } // TODO: Throw error
            pvc.replacePlotView(newPlotView: newGraph)
            plotViewMap[plot] = newGraph
        } else { // TODO: Catch instances where the previous plot style may have changed and return this new graph rather than trying to update the old one
            plotViewMap[plot] = newGraph
        }
    }
    func didCreatePlots() {
        tableView.reloadData()
        tableViewColumnDidResize(Notification(name: Notification.Name(rawValue: "dummy")))
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.starts(with: "newOutput") {
            let newVC = segue.destinationController as! VariableOutputSetupView
            newVC.analysis = self.analysis
            self.addChild(newVC)
        }
    }
    
    @IBAction func newOutput(_ sender: Any) {
        guard let wind = view.window else { return }
        if wind.styleMask.contains(.fullScreen) {
            performSegue(withIdentifier: "newOutputSheetSegue", sender: self)
        } else {
            performSegue(withIdentifier: "newOutputModalSegue", sender: self)
        }
    }
    
}


//MARK: PlotOutputViewController
/**
 This view controller is a wrapper for the CPTGraphHostingView that actually presents the Core Plot graphics
 */
class PlotOutputViewController: TZViewController {
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    var representedPlotView: TZPlotView!
    
    func replacePlotView(newPlotView: TZPlotView) {
        guard let oldView = representedPlotView else {
            representedPlotView = newPlotView
            return
        }
        if let xyPlotSpace = oldView.graph.defaultPlotSpace as? CPTXYPlotSpace {
            graphHostingView.hostedGraph = newPlotView.graph
            representedPlotView = newPlotView
            let xrange = xyPlotSpace.xRange
            let yrange = xyPlotSpace.yRange
            let newPlotSpace = newPlotView.graph.defaultPlotSpace as? CPTXYPlotSpace
            newPlotSpace?.xRange = xrange
            newPlotSpace?.yRange = yrange
            newPlotView.graph.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.graphHostingView.hostedGraph = representedPlotView.graph
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init?(coder: NSCoder, analysis: Analysis, plotView: TZPlotView) {
        super.init(coder: coder)
        self.analysis = analysis
        self.representedPlotView = plotView
    }
}

// MARK: PlotSelectorTableView
class PlotSelectorTableView: NSTableView {
    var selectorVC: PlotSelectorViewController! { return delegate as? PlotSelectorViewController }

    override func mouseDown(with event: NSEvent){
        let point = event.locationInWindow
        let tablePoint = self.convert(point, from: nil)
        let row = self.row(at: tablePoint)
        if row == -1 { // If mouse click was outside of the rows
            self.deselectAll(nil)
            super.mouseDown(with: event)
        } else if event.clickCount >= 2 { // Double click to pin the plot view
            guard let curPlot = selectorVC.selectedPlot else { return }
            let header = selectorVC.tabViewController.tabHeaderItem(named: "Plot:\(curPlot.title)")
            header?.isPinned = true
        } else {
            super.mouseDown(with: event)
        }
        
    }
}

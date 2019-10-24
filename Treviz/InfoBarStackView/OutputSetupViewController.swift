/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View Controller controlling the NSStackView.
 */

import Cocoa

extension NSStoryboardSegue.Identifier{
    static let variableSelectorSegue = "variableSelectorSegue"
}
extension NSUserInterfaceItemIdentifier{
    static let plotNameColumn = NSUserInterfaceItemIdentifier(rawValue: "plotNameColumn")
    static let plotDescripColumn = NSUserInterfaceItemIdentifier(rawValue: "plotDescripColumn")
    static let plotNameTableCellView = NSUserInterfaceItemIdentifier(rawValue: "plotNameTableCellView")
    static let plotDescripTableCellView = NSUserInterfaceItemIdentifier(rawValue: "plotDescripTableCellView")
}

class OutputSetupViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource { //TODO : make all output setup view controllers the same base class
    
    @IBOutlet weak var stack: CustomStackView!
    @IBOutlet weak var tableView: NSTableView!
    var allPlots : [TZOutput] = []
    var maxPlotNum : NSInteger = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Have the stackView strongly hug the sides of the views it contains.
        stack.parent = self
        stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
            
        // Load and install all the view controllers from our storyboard in the following order.
        let vc1 = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "SingleAxisOutputSetupViewController") as! SingleAxisOutputSetupViewController
        let vc2 = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "TwoAxisOutputSetupViewController") as! TwoAxisOutputSetupViewController
        let vc3 = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "ThreeAxisOutputSetupViewController") as! ThreeAxisOutputSetupViewController
        let vc4 = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "MonteCarloOutputSetupViewController") as! MonteCarloOutputSetupViewController
        for thisVC in [vc1,vc2,vc3,vc4]{
            thisVC.outputSetupViewController = self
            thisVC.representedObject = self.representedObject
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable(_:)), name: .didAddPlot, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.populateOutputSet(_:)), name: .didLoadAnalysisData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.populateOutputSet(_:)), name: .didLoadAppDelegate, object: nil)
        
        //addViewController(withIdentifier: "CollectionViewController")
        //addViewController(withIdentifier: "OtherViewController")
        
        /*
        let newPlot = TZPlot1line2d()
        newPlot.plotType = PlotType.singleLine2d
        newPlot.var1 = Variable.init("t")
        //newPlot.var1?.name = "Time"
        newPlot.setName()
        allPlots.append(newPlot)*/
    }
    
    func addOutput(_ newOutput : TZOutput){
        newOutput.curTrajectory = self.analysis.traj
        allPlots.append(newOutput)
        self.tableView.reloadData()
    }
    
    @objc func refreshTable(_ notification: Notification){
        self.tableView.reloadData()
    }
    @objc func populateOutputSet(_ notification: Notification){
        self.allPlots = analysis.analysisData.plots
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {return nil}
        let thisPlot = allPlots[row]
        var newView : NSTableCellView? = nil
        switch column.identifier {
        case .plotDescripColumn:
            newView = tableView.makeView(withIdentifier: .plotDescripTableCellView, owner: nil) as? NSTableCellView
            if let textField = newView?.textField{
                textField.stringValue = thisPlot.displayName}
        case .plotNameColumn:
            newView = tableView.makeView(withIdentifier: .plotNameTableCellView, owner: nil) as? NSTableCellView
            if let textField = newView?.textField{
                textField.stringValue = thisPlot.title ?? ""}
        default:
            return nil
        }
        return newView
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return allPlots.count
    }

}

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
    static let plotIDColumn = NSUserInterfaceItemIdentifier(rawValue: "plotIDColumn")
    static let plotNameTableCellView = NSUserInterfaceItemIdentifier(rawValue: "plotNameTableCellView")
    static let plotIDTableCellView = NSUserInterfaceItemIdentifier(rawValue: "plotIDTableCellView")
    static let plotDescripTableCellView = NSUserInterfaceItemIdentifier(rawValue: "plotDescripTableCellView")
}

class OutputSetupViewController: TZViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var stack: CustomStackView!
    @IBOutlet weak var tableView: NSTableView!
    var allPlots : [TZOutput] {if analysis == nil {return []} else {return analysis.plots}}
    //var plotViews : [AddOutputViewController] = []
    var stackViewContainerDict = Dictionary<TZOutput, StackItemContainer>()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Have the stackView strongly hug the sides of the views it contains.
        stack.parent = self
        stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
            
        // Load and install all the view controllers from our storyboard in the following order.
        //let vc1 = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "SingleAxisOutputSetupViewController") as! SingleAxisOutputSetupViewController
        /*
         let vc2 = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "TwoAxisOutputSetupViewController") as! TwoAxisOutputSetupViewController
        let vc3 = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "ThreeAxisOutputSetupViewController") as! ThreeAxisOutputSetupViewController
        let vc4 = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "MonteCarloOutputSetupViewController") as! MonteCarloOutputSetupViewController
        for thisVC in [vc1,vc2,vc3,vc4]{
            thisVC.outputSetupViewController = self
            thisVC.representedObject = self.representedObject
        }*/
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable(_:)), name: .didAddPlot, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable(_:)), name: .didLoadAnalysisData, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable(_:)), name: .didLoadAppDelegate, object: nil)
        
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
        analysis.plots.append(newOutput)
        self.tableView.reloadData()
        addOutputView(with: newOutput)
    }
    
    func addOutputView(with output: TZOutput){
        let newOutputVC = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "SingleAxisOutputSetupViewController") as! SingleAxisOutputSetupViewController
        newOutputVC.loadAnalysis(self.analysis)
        newOutputVC.representedOutput = output
        //newOutputVC.conditionsArrayController.content = analysis.conditions
        //newOutputVC.plotTypeArrayController.content = newOutputVC.plotTypes
        newOutputVC.objectController.content = output
        
        // GUI changes
        newOutputVC.addRemoveOutputButton.image = NSImage(named: NSImage.removeTemplateName)
        newOutputVC.editingOutputStackView.isHidden = true
        newOutputVC.displayOutputStackView.isHidden = false
        if output is TZPlot {newOutputVC.selectedOutputTypeLabel.stringValue = "Plot"}
        else if output is TZTextOutput {newOutputVC.selectedOutputTypeLabel.stringValue = "Text"}
        stackViewContainerDict[output] = newOutputVC.stackItemContainer
    }
    
    func removeOutput(_ output: TZOutput){
        if let stackItemContainer = stackViewContainerDict[output]{
            stackItemContainer.deleteFromHost()
        }
    }
    /*
    func addOutputView(output: TZOutput){
        
        var curPlotType : TZPlotType!
        if text != nil {
            var curPlotType = text!.plotType
        } else {
            var curPlotType = plot!.plotType
        }
        /*
        var newVC : AddOutputViewController!
        switch curPlotType.nAxis { //TODO: find a more robust way of assigning output type
        case 1:
            newVC = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "SingleAxisOutputSetupViewController") as! SingleAxisOutputSetupViewController
        case 2:
            newVC = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "TwoAxisOutputSetupViewController") as! TwoAxisOutputSetupViewController
        case 3:
            newVC = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "ThreeAxisOutputSetupViewController") as! ThreeAxisOutputSetupViewController
        default:
            newVC = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "MonteCarloOutputSetupViewController") as! MonteCarloOutputSetupViewController
        }
        if newVC != nil {
            newVC.includeTextCheckbox.state = text == nil ? .off : .on
            newVC.includePlotCheckbox.state = plot == nil ? .off : .on
            newVC.populateWithOutput(text: text, plot: plot)
        }*/
        
    }*/
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if ["add1AxisSegue", "add2AxisSegue", "add3AxisSegue", "addMCSegue"].contains(segue.identifier) {
            let target = segue.destinationController as! AddOutputViewController
            target.representedObject = self.analysis
            target.outputSetupViewController = self
        }
    }
    
    @objc func refreshTable(_ notification: Notification){
        self.tableView.reloadData()
    }
    @objc func populateOutputSet(_ notification: Notification){
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
        case .plotIDColumn:
            newView = tableView.makeView(withIdentifier: .plotIDTableCellView, owner: nil) as? NSTableCellView
            if let textField = newView?.textField{
                textField.stringValue = "\(thisPlot.id)"}
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

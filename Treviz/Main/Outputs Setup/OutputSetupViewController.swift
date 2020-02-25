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

class OutputSetupViewController: TZViewController{//}, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var stack: CustomStackView!
    @IBOutlet weak var tableView: NSTableView!
    @objc dynamic var allPlots : [TZOutput] {
        get {if analysis == nil {return []} else {return analysis.plots} }
        set {if analysis != nil {analysis.plots = newValue} }
        }
    @objc var selectedOutputIndex = IndexSet()
    var stackViewContainerDict = Dictionary<TZOutput, StackItemContainer>()
    @IBOutlet var outputsArrayController: NSArrayController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Have the stackView strongly hug the sides of the views it contains.
        stack.parent = self
        stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable(_:)), name: .didLoadAnalysisData, object: nil)
    }
    
    
    func addOutput(_ newOutput : TZOutput){
        newOutput.curTrajectory = self.analysis.traj
        //newOutput.title = "New Output Title"
        // let numPlots = allPlots.count
        outputsArrayController.insert(newOutput, atArrangedObjectIndex: allPlots.count)
        addOutputView(with: newOutput)
    }
    
    func addOutputView(with output: TZOutput){
        let newOutputVC = stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "SingleAxisOutputSetupViewController") as! SingleAxisOutputSetupViewController
        newOutputVC.representedOutput = output
        newOutputVC.outputSetupViewController = self
        newOutputVC.loadAnalysis(self.analysis)
        //newOutputVC.representedOutput = output
        //newOutputVC.conditionsArrayController.content = analysis.conditions
        //newOutputVC.plotTypeArrayController.content = newOutputVC.plotTypes
        newOutputVC.objectController.content = output
        
        // GUI changes
        newOutputVC.titleTextField.isHidden = true
        newOutputVC.titleTextFieldConstraint.constant = 0
        
        outputsArrayController.content = analysis.plots
        newOutputVC.addRemoveOutputButton.image = NSImage(named: NSImage.removeTemplateName)
        newOutputVC.editingOutputStackView.isHidden = true
        newOutputVC.displayOutputStackView.isHidden = false
        //newOutputVC.stackItemContainer?.header.viewController.title = output.title
        if output is TZPlot {newOutputVC.selectedOutputTypeLabel.stringValue = "Plot"}
        else if output is TZTextOutput {newOutputVC.selectedOutputTypeLabel.stringValue = "Text"}
        stackViewContainerDict[output] = newOutputVC.stackItemContainer
        
        //newOutputVC.bind(.title, to: output, withKeyPath: "title", options: nil)
        let outputVCStackItem = newOutputVC.stackItemContainer
        if let header = outputVCStackItem?.header.viewController as? HeaderViewController{
            header.headerTextField.bind(.value, to: output, withKeyPath: "title", options: nil)
            header.canEditHeader = true
            header.headerTextField.isEditable = true
        }
    }
    
    func removeOutput(_ output: TZOutput){
        if let stackItemContainer = stackViewContainerDict[output]{
            stackItemContainer.deleteFromHost()
        }
        outputsArrayController.removeObject(output)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if ["add1AxisSegue", "add2AxisSegue", "add3AxisSegue", "addMCSegue"].contains(segue.identifier) {
            let target = segue.destinationController as! AddOutputViewController
            target.analysis = self.analysis
            target.outputSetupViewController = self
            target.title = "Add Output"
        }
    }
    
    
    @objc func refreshTable(_ notification: Notification){
        if notification.object as? Analysis == analysis { // This is required to prevent running twice for two different open windows.
            //TODO: Get rid of this design pattern by initializing with analysis object
            for thisOutput in analysis.plots {
                addOutputView(with: thisOutput)
            }
        }
        self.outputsArrayController.content = allPlots
        self.tableView.bind(.content, to: outputsArrayController!, withKeyPath: "arrangedObjects", options: nil)
    }
    
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 51 {//NSDeleteCharacter {
            if tableView.selectedRow != -1 {
                let outputToRemove = allPlots[tableView.selectedRow]
                removeOutput(outputToRemove)
            }
        }
    }
}

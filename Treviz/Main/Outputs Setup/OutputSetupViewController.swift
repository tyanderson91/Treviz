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
    @IBOutlet weak var toolbarOffsetConstraint: NSLayoutConstraint!
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
        
        for thisOutput in analysis.plots {
        }
        
        self.outputsArrayController.content = allPlots
        self.tableView.bind(.content, to: outputsArrayController!, withKeyPath: "arrangedObjects", options: nil)
    }
    
    func addOutput(_ newOutput : TZOutput){
        newOutput.curTrajectory = self.analysis.traj
        outputsArrayController.insert(newOutput, atArrangedObjectIndex: allPlots.count)
    }

    
    func removeOutput(_ output: TZOutput){
        if let stackItemContainer = stackViewContainerDict[output]{
            stackItemContainer.deleteFromHost()
        }
        outputsArrayController.removeObject(output)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard ["add1AxisSegue", "add2AxisSegue", "add3AxisSegue", "addMCSegue","addVariableSegue"].contains(segue.identifier) else { return }
        let target = segue.destinationController as! AddOutputViewController
        var newOutput: TZOutput!
        switch segue.identifier {
        case "add1AxisSegue", "addVariableSegue":
            newOutput = TZOutput(id: 0, plotType: .singleValue)
        case "add2AxisSegue":
            newOutput = TZOutput(id: 0, plotType: .oneLine2d)
        case "add3AxisSegue":
            newOutput = TZOutput(id: 0, plotType: .oneLine3d)
        case "addMCSegue":
            return
        default:
            return
        }
        target.analysis = self.analysis
        target.outputSetupViewController = self
        target.shouldCollapse = false
        target.title = "Add Output"
        target.representedOutput = newOutput
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

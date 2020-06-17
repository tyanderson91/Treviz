//
//  AddOutputViewController.swift
//  Treviz
//
//  Contains all of the reusable code between the various output setup wiew controller options
//
//  Created by Tyler Anderson on 9/28/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

enum outputLocation{
    case plot, text
}

class AddOutputViewController: BaseViewController, VariableGetter {
    func variableDidChange(_ sender: VariableSelectorViewController) {
    }
    //TODO : Add a way to add variable selectors and associated logic
    
    @IBOutlet weak var conditionsPopupButton: NSPopUpButton!
    var conditions: [Condition]? {
        if let asys = analysis { return asys.conditions } else { return nil }
    }
    
    @IBOutlet weak var plotTypeCell: NSPopUpButtonCell!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var titleTextFieldConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var plotTypePopupButton: NSPopUpButton!
    var plotTypeArrayController = NSArrayController() // TODO: Replace array controller with custom creating menu items so that plot icons can be added
    @objc var plotTypes: [TZPlotType]? {
        return TZPlotType.allPlotTypes.filter { plotTypeSelector($0) }
    }
    
    @IBOutlet weak var addRemoveOutputButton: NSButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    @IBOutlet weak var includePlotCheckbox: NSButton!
    @IBOutlet var objectController: NSObjectController!
    @IBOutlet weak var editingOutputStackView: NSStackView!
    @IBOutlet weak var displayOutputStackView: NSStackView!
    @IBOutlet weak var selectedOutputTypeLabel: NSTextField!
    
    
    func plotTypeSelector(_ plotType: TZPlotType)->(Bool) {return true}//Chooses whether a given plot type applies to the current options
    var outputSetupViewController : OutputSetupViewController!
    var maxPlotID : Int { return self.analysis?.plots.map( {return $0.id} ).max() ?? 0 }
    private var selectedConditionIndex: Int = 0
    
    @objc var representedOutput: TZOutput!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    convenience init?(coder: NSCoder, analysis curAnalysis: Analysis, output: TZOutput){
        self.init(coder: coder, analysis: curAnalysis)
        representedOutput = output
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)

        displayOutputStackView.isHidden = true
        editingOutputStackView.isHidden = false
        
        objectController.content = representedOutput
        plotTypeArrayController.content = plotTypes
        
        plotTypePopupButton.bind(.content, to: plotTypeArrayController, withKeyPath: "arrangedObjects", options: nil)
        plotTypePopupButton.bind(.contentValues, to: plotTypeArrayController, withKeyPath: "arrangedObjects.name", options: nil)
        plotTypePopupButton.bind(.selectedObject, to: objectController!, withKeyPath: "selection.plotType")
        self.bind(.title, to: objectController!, withKeyPath: "selection.title")
        
        conditionsPopupButton.addItems(withTitles: analysis.conditions.compactMap({$0.name}))
        if let curCond = representedOutput.condition {
            conditionsPopupButton.selectItem(withTitle: curCond.name)
        }
    }
    
    override func getHeaderTitle() -> String { return representedOutput?.title ?? "New Output" }
    
    func createOutput()-> TZOutput?{ //Should be overwritten by each subclass
        return nil
    }
    func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        return
    }
    
    @objc func conditionsChanged(_ notification: Notification){
        guard representedOutput.condition != nil else { return }
        conditionsPopupButton.removeAllItems()
        conditionsPopupButton.addItems(withTitles: analysis.conditions.compactMap({$0.name}))
        if !analysis.conditions.contains(where: {$0 === representedOutput.condition!}) {
            representedOutput.condition = nil
            conditionsPopupButton.select(nil)
            conditionsPopupButton.removeAllItems()
            conditionsPopupButton.addItems(withTitles: analysis.conditions.compactMap({$0.name}))
            conditionsPopupButton.select(nil)
        }
        else { conditionsPopupButton.selectItem(withTitle: representedOutput.condition?.name ?? "")}
    }
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
        setOutputType(type: .text)
    }
    @IBAction func includePlotCheckboxClicked(_ sender: Any) {
        setOutputType(type: .plot)
    }
    func setOutputType(type: outputLocation){ // Can override with specific rules for each plot type
        let textOn = self.includeTextCheckbox.state.rawValue
        let plotOn = self.includePlotCheckbox.state.rawValue
        if textOn + plotOn == 0 {
            switch type {
            case .text:
                self.includePlotCheckbox.state = NSControl.StateValue.on
            case .plot:
                self.includeTextCheckbox.state = NSControl.StateValue.on
            }
        }
    }
    
    @IBAction func plotTypeWasSelected(_ sender: Any) {
    }
    
    @IBAction func addRemoveOutputButtonClicked(_ sender: Any) {
        if addRemoveOutputButton.image == NSImage(named: NSImage.addTemplateName) {
            self.title = representedOutput.title
            if includePlotCheckbox.state == .on {
                let newPlot = TZPlot(id: maxPlotID+1, with: representedOutput)
                outputSetupViewController.addOutput(newPlot)
            }
            if includeTextCheckbox.state == .on {
                let newText = TZTextOutput(id: maxPlotID+1, with: representedOutput)
                outputSetupViewController.addOutput(newText)
            }
            self.removeFromParent()
            outputSetupViewController.dismiss(self)
        } else if addRemoveOutputButton.image == NSImage(named: NSImage.removeTemplateName) {
            outputSetupViewController.removeOutput(representedOutput)
        }
    }
    
    @IBAction func didChangeCondition(_ sender: Any) {
        guard let senderButton = sender as? NSPopUpButton else { return }
        guard let selectedConditionName = senderButton.selectedItem?.title else {return}
        if let selectedCondition = analysis.conditions.first(where: {$0.name == selectedConditionName}) {
            representedOutput.condition = selectedCondition
        }
    }
    

}

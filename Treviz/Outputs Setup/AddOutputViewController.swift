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

class AddOutputViewController: BaseViewController { //TODO : Add a way to add variable selectors and associated logic
    
    @IBOutlet weak var conditionsPopupButton: NSPopUpButton!
    var conditionsArrayController = NSArrayController()
    @objc var conditions: [Condition]? {
        if let asys = analysis { return asys.conditions } else { return nil }
    }
    
    @IBOutlet weak var plotTypePopupButton: NSPopUpButton!
    var plotTypeArrayController = NSArrayController()
    @objc var plotTypes: [TZPlotType]? {
        guard let allPlotTypes = analysis?.plotTypes else {return nil}
        return allPlotTypes.filter { plotTypeSelector($0) }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(self.populatePlotTypes(_:)), name: .didLoadAppDelegate, object: nil)

        //populatePlotTypes()
        displayOutputStackView.isHidden = true
        editingOutputStackView.isHidden = false
        
        representedOutput = TZOutput(id: 0, plotType: TZPlotType.allPlotTypes[0])
        objectController.content = representedOutput
        
        loadAnalysis(representedObject as? Analysis)
        //conditionsArrayController.content = conditions
        conditionsPopupButton.bind(.content, to: conditionsArrayController, withKeyPath: "arrangedObjects", options: nil)
        conditionsPopupButton.bind(.contentValues, to: conditionsArrayController, withKeyPath: "arrangedObjects.name", options: nil)
        conditionsPopupButton.bind(.selectedObject, to: objectController!, withKeyPath: "selection.condition", options: nil)
        
        plotTypePopupButton.bind(.content, to: plotTypeArrayController, withKeyPath: "arrangedObjects", options: nil)
        plotTypePopupButton.bind(.contentValues, to: plotTypeArrayController, withKeyPath: "arrangedObjects.name", options: nil)
        plotTypePopupButton.bind(.selectedObject, to: objectController, withKeyPath: "selection.plotType", options: nil)
    }
    
    /*
    func setWidth(component: Any, width: CGFloat){
        let conditionWidth = NSLayoutConstraint(item: component, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,multiplier: 1, constant: width)
        self.view.addConstraint(conditionWidth)
    }*/
    override func viewWillAppear() {
        self.view.appearance = NSAppearance(named: .darkAqua)
    }
    
    func loadAnalysis(_ analysis: Analysis?){
        if analysis != nil {
            self.representedObject = analysis
            outputSetupViewController = analysis!.viewController.mainSplitViewController.outputSetupViewController
        }
        conditionsArrayController.content = conditions
        plotTypeArrayController.content = plotTypes
    }
    
    func createOutput()-> TZOutput?{ //Should be overwritten by each subclass
        return nil
    }
    func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        return
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
            //self.title = representedOutput.title
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

}

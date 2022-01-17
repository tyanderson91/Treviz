//
//  VariableOutputSetupView.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/25/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//
import Cocoa

extension Notification.Name {
    static var addedOutput = Notification.Name("addedOutput")
}

extension NSUserInterfaceItemIdentifier {
    static let var1Selector = NSUserInterfaceItemIdentifier("var1Selector")
    static let var2Selector = NSUserInterfaceItemIdentifier("var2Selector")
    static let var3Selector = NSUserInterfaceItemIdentifier("var3Selector")
    static let catVarSelector = NSUserInterfaceItemIdentifier("catVarSelector")

}

class VariableOutputSetupView: AddOutputViewController {
    /**
     GridView row corresponding to different optional inputs
     */
    enum VarGridRows: Int {
        case one = 3
        case two = 4
        case three = 5
        case category = 6
        case condition = 8
    }
    
    var var1ViewController : ParameterSelectorViewController!
    var var2ViewController : ParameterSelectorViewController!
    var var3ViewController : ParameterSelectorViewController!
    var categoryViewController: ParameterSelectorViewController!
    
    override func plotTypeSelector(_ plotType: TZPlotType)->(Bool){ return true }
    
    @IBOutlet weak var gridView: CollapsibleGridView!
    
    @IBAction func addOutputButtonClicked(_ sender: Any) {
        if let newOutput: TZOutput = createOutput()
        {
            analysis.plots.append(newOutput)
            NotificationCenter.default.post(Notification(name: .addedOutput, object: nil, userInfo: nil))
            self.parent?.dismiss(self)
        }
    }
    
    override func getHeaderTitle() -> String { return NSLocalizedString("New Output", comment: "") }
    
    override func viewDidLoad() {
        
        let storyboard = NSStoryboard(name: "ParamSelector", bundle: nil)
        var1ViewController = storyboard.instantiateInitialController() { aDecoder in
            let v1 = ParameterSelectorViewController(coder: aDecoder, analysis: self.analysis)
            v1?.identifier = .var1Selector
            v1?.onlyVars = true; return v1
        }
        self.addChild(var1ViewController)
        gridView.cell(atColumnIndex: 1, rowIndex: VarGridRows.one.rawValue).contentView = var1ViewController.view
        
        var2ViewController = storyboard.instantiateInitialController() { aDecoder in
            let v2 = ParameterSelectorViewController(coder: aDecoder, analysis: self.analysis)
            v2?.identifier = .var2Selector
            v2?.onlyVars = true; return v2
        }
        self.addChild(var2ViewController)
        gridView.cell(atColumnIndex: 1, rowIndex: VarGridRows.two.rawValue).contentView = var2ViewController.view
        
        var3ViewController = storyboard.instantiateInitialController() { aDecoder in
            let v3 = ParameterSelectorViewController(coder: aDecoder, analysis: self.analysis)
            v3?.identifier = .var3Selector
            v3?.onlyVars = true; return v3
        }
        self.addChild(var3ViewController)
        gridView.cell(atColumnIndex: 1, rowIndex: VarGridRows.three.rawValue).contentView = var3ViewController.view
        
        categoryViewController = storyboard.instantiateInitialController() { aDecoder in
            let cv = ParameterSelectorViewController(coder: aDecoder, analysis: self.analysis)
            cv?.identifier = .catVarSelector
            return cv
        }
        self.addChild(categoryViewController)
        gridView.cell(atColumnIndex: 1, rowIndex: VarGridRows.category.rawValue).contentView = categoryViewController.view
        
        if representedOutput == nil {
            representedOutput = initializeNewOutput()
        }
        configureForPlotType(newPlotType: representedOutput.plotType)
                
        var1ViewController.selectedParameter = self.representedOutput.var1
        var2ViewController.selectedParameter = self.representedOutput.var2
        var3ViewController.selectedParameter = self.representedOutput.var3
        
        if self.representedOutput.categoryVar == nil && categoryViewController.selectedParameter?.id == TradeGroupParam().id {
            self.representedOutput.categoryVar = TradeGroupParam()
        }
        if self.representedOutput.condition == nil {
            conditionsPopupButton.select(nil)
        }
        
        super.viewDidLoad()
        
        // Add horizontal separators to divide relevant sections
        gridView.mergeCells(inHorizontalRange: NSRange(location: 0, length: 2), verticalRange: NSRange(location: VarGridRows.one.rawValue-1, length: 1))
        gridView.mergeCells(inHorizontalRange: NSRange(location: 0, length: 2), verticalRange: NSRange(location: VarGridRows.condition.rawValue-1, length: 1))
        let newBox1 = NSBox(); newBox1.boxType = .separator
        gridView.cell(atColumnIndex: 0, rowIndex: VarGridRows.one.rawValue-1).contentView = newBox1
        let newBox2 = NSBox(); newBox2.boxType = .separator
        gridView.cell(atColumnIndex: 0, rowIndex: VarGridRows.condition.rawValue-1).contentView = newBox2
    }
    
    override func paramDidChange(_ sender: ParameterSelectorViewController) {
        guard sender.identifier != nil else {return}
        switch sender.identifier! {
        case .var1Selector:
            let v1 = var1ViewController.selectedParameter as? Variable
            representedOutput.var1 = v1
            UserDefaults.standard.set(v1?.id, forKey: "newPlot.defaultVar1")
        case .var2Selector:
            let v2 = var2ViewController.selectedParameter as? Variable
            representedOutput.var2 = v2
            UserDefaults.standard.set(v2?.id, forKey: "newPlot.defaultVar2")
        case .var3Selector:
            let v3 = var3ViewController.selectedParameter as? Variable
            representedOutput.var3 = v3
            UserDefaults.standard.set(v3?.id, forKey: "newPlot.defaultVar3")
        case .catVarSelector:
            let cv = categoryViewController.selectedParameter
            representedOutput.categoryVar = cv
            UserDefaults.standard.set(cv?.id, forKey: "newPlot.defaultCatVar")
        default:
            return
        }
    }
    
    /**
     This function sets the view and output settings for a newly selected plot type
     */
    private func configureForPlotType(newPlotType: TZPlotType){
        var rowsToShow: [VarGridRows] = []
        var rowsToHide: [VarGridRows] = []
        
        // Convenience function
        func showHideRows(type: CollapsibleGridView.showHide, gridRow: [VarGridRows]){
            let iRow: [Int] = gridRow.map {$0.rawValue}
            self.gridView.showHide(type, .row, index: iRow)
        }
         
        let hasVar2 = newPlotType.nAxis >= 2
        let hasVar3 = newPlotType.nAxis >= 3 || newPlotType == .contour2d
        
        if hasVar2 {
            rowsToShow.append(VarGridRows.two)
        } else {
            rowsToHide.append(VarGridRows.two)
            representedOutput.var2 = nil
            var2ViewController.deselectAll()
        }
        if hasVar3 {
            rowsToShow.append(VarGridRows.three)
        } else {
            rowsToHide.append(VarGridRows.three)
            representedOutput.var3 = nil
            var3ViewController.deselectAll()
        }
        if newPlotType.requiresCategoryVar {
            rowsToShow.append(VarGridRows.category)
        } else {
            rowsToHide.append(VarGridRows.category)
            representedOutput.categoryVar = nil
            categoryViewController.deselectAll()
        }
        if newPlotType.requiresCondition {
            rowsToShow.append(VarGridRows.condition)
        } else {
            rowsToHide.append(VarGridRows.condition)
            representedOutput.condition = nil
            conditionsPopupButton.select(nil)
        }
        showHideRows(type: .hide, gridRow: rowsToHide)
        showHideRows(type: .show, gridRow: rowsToShow)
        
        representedOutput.plotType = newPlotType

        UserDefaults.standard.set(newPlotType.name, forKey: "newPlot.defaultPlotType")
        let nonPlotTypes: [TZPlotType] = [.singleValue, .multiValue]
        if nonPlotTypes.contains(newPlotType) {
            includePlotCheckbox.isEnabled = false
        } else { includePlotCheckbox.isEnabled = true }
        
        if newPlotType.requiresCategoryVar {
            representedOutput.categoryVar = categoryViewController.selectedParameter
        } else {
            representedOutput.categoryVar = nil
        }
        if !newPlotType.requiresCondition {
            representedOutput.condition = nil
        }
    }
    
    @IBAction func didChangePlotType(_ sender: NSPopUpButton) {
        guard let newPlotTypeName = sender.selectedItem?.title else { return }
        guard let newPlotType = TZPlotType.getPlotTypeByName(newPlotTypeName) else { return }
        configureForPlotType(newPlotType: newPlotType)
    }
    
    func initializeNewOutput()->TZOutput { // Initialization of new output based on previous preferences set by the last plot
        let newOutput = TZOutput(id: 0, plotType: .singleValue)
        newOutput.title = ""
        if let defaultVar1 = UserDefaults.standard.string(forKey: "newPlot.defaultVar1"){
            newOutput.var1 = analysis.varList.first(where: {$0.id == defaultVar1})
        }
        if let defaultVar2 = UserDefaults.standard.string(forKey: "newPlot.defaultVar2"){
            newOutput.var2 = analysis.varList.first(where: {$0.id == defaultVar2})
        }
        if let defaultVar3 = UserDefaults.standard.string(forKey: "newPlot.defaultVar3"){
            newOutput.var3 = analysis.varList.first(where: {$0.id == defaultVar3})
        }
        if let defaultCatVar = UserDefaults.standard.string(forKey: "newPlot.defaultCatVar"){
            newOutput.categoryVar = analysis.inputSettings.first(where: {$0.id == defaultCatVar})
        }
        if let defaultCondition = UserDefaults.standard.string(forKey: "newPlot.defaultCondition"){
            newOutput.condition = analysis.conditions.first(where: {$0.name == defaultCondition})
        }
        if let defaultPlotTypeName = UserDefaults.standard.string(forKey: "newPlot.defaultPlotType") {
            newOutput.plotType = TZPlotType.getPlotTypeByName(defaultPlotTypeName) ?? TZPlotType.singleValue
        } else { newOutput.plotType = .singleValue }
        
        let nonPlotTypes: [TZPlotType] = [.singleValue, .multiValue]
        var defaultShouldPlot: Bool
        if nonPlotTypes.contains(newOutput.plotType){
            defaultShouldPlot = false
            includePlotCheckbox.isEnabled = false
        } else {
            defaultShouldPlot = UserDefaults.standard.bool(forKey: "newPlot.shouldMakePlot")
        }
        let defaultShouldText = UserDefaults.standard.bool(forKey: "newPlot.shouldMakeText")
        includePlotCheckbox.state = defaultShouldPlot ? .on : .off
        includeTextCheckbox.state = defaultShouldText ? .on : .off
        
        return newOutput
    }
    
    override func keyDown(with event: NSEvent){
        if event.keyCode==53 { //Escape
            parent!.dismiss(self)
            self.removeFromParent()
            self.delete()
        } else {
            super.keyDown(with: event)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        view.window?.makeFirstResponder(nil) // Deselect the title box
        super.mouseDown(with: event)
        view.window?.makeFirstResponder(self)
    }
    override func createOutput()->TZOutput? {
        do {
            try representedOutput.assertValid()
            let newPlot = TZPlot(id: maxPlotID+1, with: representedOutput)
            return newPlot
        } catch {
            analysis.logError(error.localizedDescription)
            return nil
        }
    }
}

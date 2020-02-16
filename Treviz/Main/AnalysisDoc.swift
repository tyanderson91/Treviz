//
//  AnalysisData.swift
//  Treviz
//
//  Input/ Output functions for analysis-specific data and config options
//
//  Created by Tyler Anderson on 3/30/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//
import Foundation
import Cocoa
import Yams

enum PropagatorType {
    case explicit
    case rungeKutta4
}

typealias YamlString = String
/**
 Structure for reading and writing initial variable values
 params id: Variable ID
 param isParam: Whether the variable is to be used as a parameter in the analysis
 param value: Initial value
 */
struct InitStateSetting {
    let id: VariableID
    let isParam: Bool
    let value: Double
}

class AnalysisDoc: NSDocument {

    var analysis = Analysis()
    // Connections to interface
    var appDelegate : AppDelegate!
    var windowController : MainWindowController! //Implicit optional, should always be assigned after initialization
    var viewController : MainViewController!
    var plotTypes : [TZPlotType]! = nil
    var initVars : [Variable]! = nil
    
    /*
    override var windowNibName: String? {
        // Override returning the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
        return "AnalysisDoc"
    }
    */
    override init() {
        super.init()
        //NotificationCenter.default.addObserver(self, selector: #selector(self.initReadData(_:)), name: .didLoadAppDelegate, object: nil)
        loadPlotTypes(from: "PlotTypes")
        loadVars(from: "InitVars")
        initVars = State.sortVarIndices(initVars)
        
        analysis.plotTypes = plotTypes
        analysis.varList = initVars
        analysis.inputSettings = analysis.varList.compactMap { ($0.copy() as! Parameter) } // TODO: Better way to copy?
        loadVarGroups(from: "InitStateStructure")
        
        initReadData()
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        self.windowController = (storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Analysis Window Controller")) as! MainWindowController)
        windowController.analysis = analysis
        self.addWindowController(windowController)
        self.viewController = (windowController.contentViewController as! MainViewController)
        self.viewController.representedObject = analysis
        self.viewController.analysis = analysis
        
        NotificationCenter.default.post(name: .didLoadAnalysisData, object: nil)
    }
    
    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        let asysData = try NSKeyedArchiver.archivedData(withRootObject: analysis as Any, requiringSecureCoding: false)
        return asysData
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        
        analysis = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Analysis)!
        /*if newAnalysis != nil {
            analysis.conditions.append(newAnalysis!.terminalCondition)
            analysis.terminalCondition = newAnalysis!.terminalCondition
        }*/
        NotificationCenter.default.post(name: .didAddCondition, object: nil)
        NotificationCenter.default.post(name: .didLoadAnalysisData, object: nil)
        //viewController.mainSplitViewController.inputsViewController.settingsViewController.terminalConditionPopupButton
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    /*
    override func read(from url: URL, ofType typeName: String) throws {
        do {
            let asysData = try Data(contentsOf: url)
            try read(from: asysData, ofType: typeName)
        }
        //readSettings(from: "AnalysisSettings")
    }*/
    
    override class var autosavesInPlace: Bool {
        return false
    }
    
    
    func initReadData(){ //TODO: override with persistent data, last opened analysis, etc.
        // For now, this is just a test configuration
        
        analysis.name = "Test Analysis"
        analysis.defaultTimestep = 0.1
        analysis.vehicle = Vehicle()
        
        // Read all inputs
        //readSettings(from: "AnalysisSettings")
        //if var tvar = self.inputSettings.first(where: {$0.id == "t"}) {tvar.isParam = true}
        
        
        analysis.traj = State(variables: analysis.varList)
        for thisVar in analysis.inputSettings {
            analysis.traj[thisVar.id, 0] = (thisVar as! Variable)[0]
        }
        analysis.traj["mtot",0] = 10.0

        readSettings(from: "AnalysisSettings")
        NotificationCenter.default.post(name: .didLoadAnalysisData, object: nil)
    }
    
    /**
     Read initial state variable info from a given yaml file
     Should be an array of dictionaries, and each dictionary should contain:
     * VariableID
     * Initial value (Double)
     * IsParam (Bool)
     */
    /*
    func readInitVars(from file: String){
        let inputList = getYamlObject(from: file) as! [[String:Any]]
        
        for thisVar in inputList {
            let thisVarID = thisVar["id"] as! VariableID
            let curVar = self.initVars.first(where: { $0.id == thisVarID})!
            // assert(curVar.value.count == 0)
            let val = thisVar["value"]
            if val is Int {
                curVar.value = [Double(val as! Int)]
            } else if val is Double {
                curVar.value = [val as! Double]
            }
            curVar.isParam = thisVar["isParam"] as! Bool
            inputSettings.append(curVar)
        }
    }*/
    
    /**
       Returns a variable described by the yaml input key using the value(s) in the yaml value
       - Parameter yamlObj: a Dictionary of the type [String: Any] read from a yaml file.
       */
    func initVar(varID: VariableID, varStr: Any) -> Variable? {
        guard let thisVar = analysis.inputSettings.first(where: { $0.id == varID}) as? Variable else {return nil}
        if let val = varStr as? NSNumber {
            thisVar.value = [VarValue(truncating: val)]
            return thisVar
        } else {return nil}
    }
    
    /**
     Creates a single Output from a Dictionary of the type that a yaml file can read. keys can include name (plot name), variable (variable id), type (plot type), condition, and output type (Plot by default)
     - Parameter yamlObj: a Dictionary of the type [String: Any] read from a yaml file.
     */
    func initOutput(fromYaml yamlObj: [String: Any]) -> TZOutput? {
        var outputDict = yamlObj
        if let plotTypeStr = yamlObj["plot type"] as? String{
            outputDict["plot type"] = plotTypes.first(where: {$0.name == plotTypeStr}) ?? ""
        }
        if let idInt = yamlObj["id"] as? Int {
            outputDict["id"] = idInt
        } else {
            let newID = ((analysis.plots.compactMap {$0.id}).max() ?? 0) + 1
            outputDict["id"] = newID
        }
        if let varstr = yamlObj["variable1"] as? VariableID{
            outputDict["variable1"] = initVars.first(where: {$0.id == varstr}) ?? ""
        }
        else if let varstr = yamlObj["variable"] as? VariableID{
            outputDict["variable1"] = initVars.first(where: {$0.id == varstr}) ?? ""
        }
        if let varstr = yamlObj["variable2"] as? VariableID{
            outputDict["variable2"] = initVars.first(where: {$0.id == varstr}) ?? ""
        }
        if let varstr = yamlObj["variable3"] as? VariableID{
            outputDict["variable3"] = initVars.first(where: {$0.id == varstr}) ?? ""
        }
        if let condstr = yamlObj["condition"] as? String{
            if condstr == "terminal" {
                outputDict["condition"] = analysis.terminalCondition
            } else if let thisCondition = analysis.conditions.first(where: {$0.name == condstr}) {
                outputDict["condition"] = thisCondition
            }
        }
        
        if let outputTypeStr = yamlObj["output type"] as? String{
            switch outputTypeStr {
            case "plot":
                return TZPlot(with: outputDict)
            case "text":
                return TZTextOutput(with: outputDict)
            default:
                return nil
            }
        } else {
            return TZPlot(with: outputDict)
        }
    }
    
    
    func readSettings(from file: String){
        guard let yamlDict: [String:Any] = getYamlObject(from: file) as? [String : Any] else {return}
        
        //if let inputList = try yamlListDict["Initial Variables"] as? [String: Int] {return}
        //guard let yamlList: [[String:Any]] = getYamlObject(from: file) as? [[String : Any]] else {return}
        //for thisYaml in yamlList {
        
        if let inputList = yamlDict["Initial Variables"] as? [String: Any] {
            for (curVarID, curVarVal) in inputList {
                //let thisVar =  self.initVars.first(where: { $0.id == curVarID})!
                //let val = inputList[thisVarID]
                //thisVar.value = [Double(truncating: val!)]
                _ = initVar(varID: curVarID, varStr: curVarVal)// { inputSettings.append(thisVar) }
            }
        }
        
        if let inputList = yamlDict["Parameters"] as? [[String: Any]] {
            for paramSet in inputList {
                for thisKey in paramSet.keys { //TODO: better way to do this
                    let curVarID = thisKey
                    let thisVar =  analysis.inputSettings.first(where: { $0.id == curVarID }) as! Variable
                    thisVar.value = [VarValue(truncating: paramSet[curVarID] as! NSNumber)]
                    thisVar.isParam = true
                }
            }
        }
        
        if let conditionList = yamlDict["Conditions"] as? [[String: Any]] {
            // self.conditions = []
            for thisConditionDict in conditionList {
                if let newCond = Condition(fromYaml: thisConditionDict, inputConditions: analysis.conditions) {
                    //initCondition(fromYaml: thisConditionDict) {
                    analysis.conditions.append(newCond)
                } // TODO: else print error
            }
        }
        if let terminalConditionDict = yamlDict["Terminal Condition"] as? [String: Any] {
            if let newCond = Condition(fromYaml: terminalConditionDict, inputConditions: analysis.conditions) {
                newCond.name = "Terminal"
                analysis.conditions.append(newCond)
                analysis.terminalCondition = newCond
            }
        }
        if let outputList = yamlDict["Outputs"] as? [[String: Any]] {
            analysis.plots = []
            for thisOutputDict in outputList {
                if let newOutput = initOutput(fromYaml: thisOutputDict) {
                    analysis.plots.append(newOutput)
                }
            }
        }
        analysis.traj = State(variables: analysis.varList)
    }
    
    func loadVars(from plist: String){
        guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
        guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return}//return empty if filename not found
        initVars = []
        for thisVar in inputList {
            guard let dict = thisVar as? NSDictionary else {return}
            let newVar = Variable(dict["id"] as! VariableID, named: dict["name"] as! String, symbol: dict["symbol"] as! String)
            newVar.units = dict["units"] as! String
            newVar.value = [0]
            initVars.append(newVar)
        }
    }
    
    func loadPlotTypes(from plist: String){
        guard let plotFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
        
        guard let inputList = NSArray.init(contentsOfFile: plotFilePath) else {
            self.plotTypes = nil
            return}
        var initPlotTypes : [TZPlotType] = []
        for thisPlot in inputList {
            guard let dict = thisPlot as? NSDictionary else {return}
            let newPlot = TZPlotType(dict["id"] as! String, name: dict["name"] as! String, requiresCondition: dict["condition"] as! Bool, nAxis: dict["naxis"] as! Int, nVars: dict["nvar"] as! Int)
            initPlotTypes.append(newPlot)
        }
        self.plotTypes = initPlotTypes
        TZPlotType.allPlotTypes = initPlotTypes
    }
    
    /**
     This function reads in the current physics model and pre-populates all the required initial states with 0 values
     */
    func defaultInitSettings()->[Variable] { //TODO: vary depending on the physics type
        var varList = [Variable]()
        for thisVar in analysis.varList {
            guard let newVar = thisVar.copy() as? Variable else {continue}
            varList.append(newVar)
        }
        return varList
    }
    
    func loadVarGroups(from plist: String){
         guard let varFilePath = Bundle.main.path(forResource: plist, ofType: "plist") else {return}
         guard let inputList = NSArray.init(contentsOfFile: varFilePath) else {return} //return empty if filename not found
         analysis.initStateGroups = InitStateHeader(id: "default")
         loadVarGroupsRecurs(input: analysis.initStateGroups, withList: inputList as! [NSDictionary])
     }
     
     private func loadVarGroupsRecurs(input: InitStateHeader, withList list: [NSDictionary]){
         for dict in list {
             guard let itemType = dict["itemType"] as? String else { return }
             guard let itemID = dict["id"] as? VariableID else { return }
             let name = dict["name"] as? String
             
             if itemType == "var"{
                 if let newVar = analysis.inputSettings.first(where: {$0.id == itemID}) as? Variable {
                    input.variables.append(newVar)
                 }
                 continue
             } else {
                 var newHeader = InitStateHeader(id: "")
                 if itemType == "header" {
                     newHeader = InitStateHeader(id: itemID)}
                 else if itemType == "subHeader" {
                     newHeader = InitStateSubHeader(id: itemID)}
                 else {return}
                 newHeader.name = name!
                 input.subheaders.append(newHeader)
                 if let children = dict["items"] as? NSArray {
                     loadVarGroupsRecurs(input: newHeader, withList: children as! [NSDictionary])
                 }
             }
         }
     }
}

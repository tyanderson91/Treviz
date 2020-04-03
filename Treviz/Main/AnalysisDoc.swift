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


class AnalysisDoc: NSDocument {

    var analysis = Analysis()
    // Connections to interface
    var appDelegate : AppDelegate!
    var windowController : MainWindowController! //Implicit optional, should always be assigned after initialization
    var viewController : MainViewController!
    var initVars : [Variable]! = nil
    
    override init() {
        super.init()
        setupConstants() // TODO: load variables for new analylsis
    }
    
    // MARK: NSDocument setup and read/write methods
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        
        #if STORYBOARD_WINDOW_CONTROLLER
        windowController = (storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Analysis Window Controller")) as! MainWindowController)
        /*if #available(OSX 10.15, *) {
            let mainViewController = storyboard.instantiateController(identifier: NSStoryboard.SceneIdentifier("mainViewController"), creator: { (aDecoder: NSCoder)->MainViewController in
                MainViewController(coder: aDecoder, newAnalysis: self.analysis)!
            })
            let mainWindow = NSWindow(contentViewController: mainViewController)
            self.windowController = MainWindowController(window: mainWindow)
        }*/
        /*
        if #available(OSX 10.15, *) {
            let mainWindowController = storyboard.instantiateController(identifier: NSStoryboard.SceneIdentifier("Analysis Window Controller")) { aDecoder in
                return MainWindowController(coder: aDecoder, newAnalysis: self.analysis, storyboard: storyboard)
            }
            self.windowController = mainWindowController
        }*/
        //let mainWindowController = storyboard.instantiateController(withIdentifier: "Analysis Window Controller") as! MainWindowController
        //self.windowController = mainWindowController
        #else
        if let mainVC = storyboard.instantiateController(withIdentifier: "mainViewController") as? MainViewController {
            mainVC.analysis = analysis
            let window = NSWindow(contentViewController: mainVC)
            
            //window.contentViewController = mainVC
            window.contentView = mainVC.view
            window.titleVisibility = .visible
            windowController = MainWindowController(window: window)
            windowController.createToolbar()
            DistributedNotificationCenter.default.addObserver(windowController as Any, selector: #selector(windowController.completeAnalysis), name: .didFinishRunningAnalysis, object: nil)
            window.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true
            
        }
        #endif
        
        self.windowController.analysis = analysis
        self.addWindowController(windowController)
        self.viewController = (windowController.contentViewController as! MainViewController)
        self.viewController.representedObject = analysis
        self.viewController.analysis = analysis
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
        setupConstants()
        switch typeName {
        case "public.yaml":
            analysis.inputSettings = analysis.varList.compactMap { ($0.copy() as! Parameter) } // TODO: Better way to copy?
            readFromYaml(data: data)
            analysis.name = "YAML Document"
        case "com.tyleranderson.treviz.analysis":
            analysis = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Analysis)!
            analysis.name = "Analysis Document"
        default:
            return
        }
        setupConstants()
        analysis.defaultTimestep = 0.1
        
        // TODO: Definitely find a more robust way to handle this
        for plot in analysis.plots {
            plot.var1 = analysis.varList.first(where: { $0.id == plot.var1?.id })
            plot.var2 = analysis.varList.first(where: { $0.id == plot.var2?.id })
            plot.var3 = analysis.varList.first(where: { $0.id == plot.var3?.id })
            plot.categoryVar = analysis.varList.first(where: { $0.id == plot.categoryVar?.id })
        }
        analysis.traj = State(variables: analysis.varList)
    }

    override class var autosavesInPlace: Bool {
        return false
    }
    
    // MARK: Initial analysis setup functions and constants
    
    func setupConstants(){
        loadVars(from: "InitVars")
        initVars = State.sortVarIndices(initVars)
        
        analysis.varList = initVars
        loadVarGroups(from: "InitStateStructure")
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

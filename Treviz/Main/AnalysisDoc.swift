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

enum AnalysisDocError: Error, LocalizedError {
    case UnknownDataTypeError
    
    public var errorDescription: String? {
        switch self {
        case .UnknownDataTypeError:
            return "Could not save file. Unknown data type"
        }
    }
}
class AnalysisDoc: NSDocument {

    var analysis = Analysis()
    // Connections to interface
    var appDelegate : AppDelegate!
    var windowController : MainWindowController! //Implicit optional, should always be assigned after initialization
    var viewController : MainViewController!
    
    override init() {
        super.init()
        analysis.setupConstants()
    }
    
    // MARK: NSDocument setup and read/write methods
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        
        #if STORYBOARD_WINDOW_CONTROLLER
        
        windowController = (storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Analysis Window Controller")) as! MainWindowController)
        
        let window = windowController.window!
        
        let mainVC = storyboard.instantiateController(identifier: "mainViewController") { aDecoder in
            return MainViewController(coder: aDecoder, analysis: self.analysis)
        }
        windowController.contentViewController = mainVC
        window.contentView = mainVC.view
        
        DistributedNotificationCenter.default.addObserver(windowController as Any, selector: #selector(windowController.completeAnalysis), name: .didFinishRunningAnalysis, object: nil)
        //window.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true

        #else
        if let mainVC = storyboard.instantiateController(withIdentifier: "mainViewController") as? MainViewController {
            mainVC.analysis = analysis
            
            let window = NSWindow(contentViewController: mainVC)
            //window.contentViewController = mainVC
            window.contentView = mainVC.view
            window.titleVisibility = .visible
            windowController = MainWindowController(window: window)
            windowController.createToolbar()
            
            //window.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true
        }
        #endif
        // Make window clear
        //self.windowController.window!.isOpaque = false
        //windowController.window!.backgroundColor = NSColor.init(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
        
        self.windowController.analysis = analysis
        self.addWindowController(windowController)
        self.viewController = (windowController.contentViewController as! MainViewController)
        self.viewController.representedObject = analysis
        self.viewController.analysis = analysis
    }
    /*
    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }*/

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        //let asysData = try NSKeyedArchiver.archivedData(withRootObject: analysis as Any, requiringSecureCoding: false)
        switch typeName {
        case "public.json":
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let asysData = try encoder.encode(analysis)
            return asysData
        case "com.TylerAnderson.Treviz.Analysis":
            do {
                let archiver = NSKeyedArchiver(requiringSecureCoding: false)
                try archiver.encodeEncodable(analysis, forKey: NSKeyedArchiveRootObjectKey)
                return archiver.encodedData
            } catch { analysis.logMessage("Error when saving file")
                throw error
            }
        default:
            let dataError = AnalysisDocError.UnknownDataTypeError
            analysis.logMessage(dataError.errorDescription!)
            throw dataError
        }
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        switch typeName {
        case "public.yaml":
            analysis.inputSettings = analysis.varList//.compactMap { ($0.copy() as! Parameter) } // TODO: Better way to copy?
            analysis.readFromYaml(data: data)
            analysis.name = "YAML Document"
        case "public.json":
            let decoder = JSONDecoder()
            analysis = try decoder.decode(Analysis.self, from: data)
            analysis.name = "Analysis Document"
        case "com.tyleranderson.treviz.analysis":
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            analysis = unarchiver.decodeDecodable(Analysis.self, forKey: NSKeyedArchiveRootObjectKey)!
        default:
            return
        }
        analysis.name = "Analysis (\(typeName))"
        analysis.defaultTimestep = 0.1
        
        analysis.traj = State(variables: analysis.varList)
    }

    override class var autosavesInPlace: Bool {
        return false
    }
    
}

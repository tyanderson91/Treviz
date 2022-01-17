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

    var analysis : Analysis!
    // Connections to interface
    var windowController : MainWindowController! //Implicit optional, should always be assigned after initialization
    var viewController : MainViewController!
    
    override init() {
        super.init()
    }
    
    convenience init(type typeName: String) throws {
        self.init()
        let defaultPhase = TZPhase(id: "default")
        analysis = Analysis(initPhase: defaultPhase)
        // Rest of initialization code here
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
        windowController.changeToolbar(style: UserDefaults.toolbarStyle, showText: UserDefaults.showToolbarText)

        #else
        if let mainVC = storyboard.instantiateController(withIdentifier: "mainViewController") as? MainViewController {
            mainVC.analysis = analysis
            
            let window = NSWindow(contentViewController: mainVC)
            //window.contentViewController = mainVC
            window.contentView = mainVC.view
            window.titleVisibility = .visible
            //window.titlebarAppearsTransparent = true
            //window.tat
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
        var userOptions : [CodingUserInfoKey : Any] = [.simpleIOKey: false]

        switch typeName {
        case "public.json":
            let encoder = JSONEncoder()
            encoder.userInfo = userOptions
            encoder.outputFormatting = .prettyPrinted
            let asysData = try encoder.encode(analysis)
            return asysData
        case "com.TylerAnderson.Treviz.Analysis":
            do {
                let archiver = NSKeyedArchiver(requiringSecureCoding: false)
                try archiver.encodeEncodable(analysis, forKey: NSKeyedArchiveRootObjectKey)
                return archiver.encodedData
            } catch { analysis.logError("could not save file")
                throw error
            }
        case "public.yaml":
            let encoder = YAMLEncoder()
            encoder.options.allowUnicode = true
            encoder.options.indent = 2
            userOptions[.simpleIOKey] = true
            if let asysString = try? encoder.encode(analysis, userInfo: userOptions) {
                let asysData = asysString.data(using: String.Encoding.utf8)!
                return asysData
            } else {
                let dataError = AnalysisDocError.UnknownDataTypeError
                analysis.logError(dataError.errorDescription!)
                throw dataError
            }
        default:
            let dataError = AnalysisDocError.UnknownDataTypeError
            analysis.logError(dataError.errorDescription!)
            throw dataError
        }
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        var userOptions : [CodingUserInfoKey : Any] = [.simpleIOKey: false]
        
        switch typeName {
            
        case "public.yaml":
            //analysis.phase[0].inputSettings = analysis.varList//.compactMap { ($0.copy() as! Parameter) } // TODO: Better way to copy?
            userOptions[.simpleIOKey] = true
            let decoder = Yams.YAMLDecoder(encoding: .utf8)
            if let stryaml = String(data: data, encoding: String.Encoding.utf8) {
                analysis = try decoder.decode(Analysis.self, from: stryaml, userInfo: userOptions)
            }
            /*
            let dxRunVariant = VariableRunVariant(param: analysis.phases[0].allParams.first(where: {$0.id == "default.dx"})!)!
            dxRunVariant.tradeValues = [30, 29.6, 29.2, 28.8, 28.4, 28.0, 27.6, 27.2, 26.7]
            dxRunVariant.variantType = .trade
            let dyRunVariant = VariableRunVariant(param: analysis.phases[0].allParams.first(where: {$0.id == "default.dy"})!)!
            dyRunVariant.tradeValues = [50, 49, 48, 47, 45.9, 44.8, 43.7, 42.6, 41.4]
            dyRunVariant.variantType = .trade
            let x0RunVariant = VariableRunVariant(param: analysis.phases[0].allParams.first(where: {$0.id == "default.x"})!)!
            x0RunVariant.variantType = .trade
            x0RunVariant.tradeValues = [0, 5, 10, 15, 20, 25, 30, 35, 40]
            let y0RunVariant = VariableRunVariant(param: analysis.phases[0].allParams.first(where: {$0.id == "default.y"})!)!
            y0RunVariant.min = 0
            y0RunVariant.max = 5
            y0RunVariant.variantType = .montecarlo
            y0RunVariant.distributionType = .uniform
            */
            analysis.numMonteCarloRuns = 5
            //analysis.runVariants = [dxRunVariant, dyRunVariant, y0RunVariant, x0RunVariant]
            //analysis.runVariants.forEach({$0.parameter.isParam = true})
            analysis.useGroupedVariants = true
            //analysis.tradeGroups = Array<RunGroup>.init(repeating: RunGroup(), count: analysis.numTradeGroups)
            
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
        if analysis.name == "" {
            analysis.name = "Analysis (\(typeName))"
        }
        if analysis.phases.count == 0 {
            analysis.phases = [TZPhase(id: "default")]
            analysis.logError("No phases found. Creating one from default")
        }
    }

    override class var autosavesInPlace: Bool {
        return false
    }
    
}

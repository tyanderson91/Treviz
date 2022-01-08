//
//  Analysis.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.

import Cocoa

extension CodingUserInfoKey {
    static let simpleIOKey: CodingUserInfoKey = CodingUserInfoKey(rawValue: "simpleIO")!
    static let deepCopyKey: CodingUserInfoKey = CodingUserInfoKey(rawValue: "deepCopy")!
}

enum AnalysisError: Error {
    case NoTerminalCondition
    case TimeStepError
}

enum AnalysisRunMode {
    case serial
    case parallel
}
extension AnalysisError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .NoTerminalCondition:
            return NSLocalizedString("Missing terminal condition", comment: "")
        case .TimeStepError:
            return NSLocalizedString("Unset timestep settings", comment: "")
        }
    }
}
/**
The Analysis class is the subclass of NSDocument that controls all the analysis document information and methods
Data reading and writing occurs in AnalysisData and is passed to this class
Data configurations common to all analyses (e.g. plot types) lives in the App Delegate
In the Model-View-Controller paradigm, Analysis is the model that brings together all other models for a single document.
In addition, this class contains class-level functions such as initiating the analysis run
* Output sets: set of all output objects (text, plot, animation) and output configurations
* Initial State: fully defined initial state
* Environment: data defining the planet, atmosphere, and physics to run
* Vehicle: Vehicle config information, including mass and aerodynamic configuration and Guidance, Navigation, and Control data
* Conditions: All conditions for use in outputs and terminal condition
* Terminal condition: The final condition or set of conditions that ends the simulation
* Run settings: things like default timestep, propagator, etc.
*/
class Analysis: NSObject, Codable {
    
    var varList : [Variable]! {
        if phases.count == 1 {
            let onlyPhase = phases[0]
            var summaryVars = onlyPhase.varList.compactMap({$0.copyWithoutPhase()})
            summaryVars.append(contentsOf: onlyPhase.varList)
            return summaryVars
        } else { return nil }
    }
    var calculatedVarTemplates: [StateCalcVariable] = []
    
    // Analysis-specific data and configs (read/writing functions in AnalysisData.swift)
    var name : String = ""
    var conditions : [Condition] = []
    var inputSettings : [Parameter] {
        var tempSettings = [Parameter]()
        for thisPhase in phases {
            tempSettings.append(contentsOf: thisPhase.allParams)
        }
        return tempSettings
    }
    var activeParameters : [Parameter] { //TODO: this should contain more than just input settings
        return inputSettings.filter {$0.isParam}
    }
    @objc var plots : [TZOutput] = []
    
    // Phase variables
    var phases : [TZPhase] = []
    var vehicles = [Vehicle()]
    var propagatorType : PropagatorType = .explicit
    var defaultTimestep : VarValue = 0.01
    var initState: StateDictSingle {
        get { return StateDictSingle(from: self.traj, at: 0) }
    }
    weak var terminalCondition : Condition! {
        get { return phases[0].terminalCondition }
    }
    var traj: State!
    
    // Run settings
    var pctComplete: Double = 0
    var numComplete: Int = 0
    var isRunning = false
    var hasRunData: Bool {
        if !self.runs.isEmpty {
            return !self.runs[0].trajData.isEmpty
        } else {
            return false
        }
    }
    var returnCode : Int = 0
    let analysisDispatchQueue = DispatchQueue(label: "analysisRunQueue", qos: .utility)
    let dispatchGroup = DispatchGroup()
    let runProcessingGroup = DispatchGroup()
    let processingQueue = DispatchQueue(label: "outputProcessingQueue", qos: .userInteractive)
    var progressReporter: AnalysisProgressReporter?
    var runMode = AnalysisRunMode.parallel {
        didSet {
            for thisPhase in self.phases {
                thisPhase.runMode = self.runMode
            }
        }
    }

    // Run variant parameters
    var runVariants: [RunVariant] = []
    var useGroupedVariants: Bool = false // Grouped versus Permutation
    var numMonteCarloRuns: Int = 1
    var runs: [TZRun] = []
    var tradeGroups: [RunGroup] = []
    
    // Logging
    var _bufferLog = NSMutableAttributedString() // This string is used to store any logs prior to the initialization of the log message text view
    var logMessageView: TZLogger? {
        didSet {
            if _bufferLog.string != "" {
                logMessageView?.logMessage(_bufferLog)
                _bufferLog = NSMutableAttributedString()
            }
        }
    }
    
    // Outputs
    var textOutputViewer: TZTextOutputViewer?
    var plotOutputViewer: TZPlotOutputViewer?
    var visualViewer: TZVizualizer?
    
    override init(){
        super.init()
        phases = []
    }
    init(initPhase phase: TZPhase){
        super.init()
        phases = [phase]
        traj = State(varList)
    }
    
    // Validity check prior to running
    /**
     Check whether the analysis has enough inputs defined in order to run
     If this function throws an error, the analysis cannot be run
     */
    func isValid() throws {
        try phases.forEach { try $0.isValid() }
    }
    
    // MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case analysisName
        case conditions = "Conditions"
        case plots = "Outputs"
        case phases = "Phases"
        case runVariants = "Run Variants"
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let simpleIO : Bool = decoder.userInfo[.simpleIOKey] as? Bool ?? false
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try? container.decode(String.self, forKey: .analysisName)) ?? "New Analysis"

        if simpleIO {
            var allConds = try container.nestedUnkeyedContainer(forKey: .conditions)
            while(!allConds.isAtEnd){
                let decoder = try allConds.superDecoder()
                if let thisCond = Condition(decoder: decoder, referencing: self) {
                    conditions.append(thisCond)
                }
            }
        } else {
            var allConds = try container.nestedUnkeyedContainer(forKey: .conditions)
            while(!allConds.isAtEnd){
                let decoder = try allConds.superDecoder()
                if let thisCond = Condition(decoder: decoder, referencing: self) {
                    conditions.append(thisCond)
                }
            }
        }
            
        do {
            var allPhases = try container.nestedUnkeyedContainer(forKey: .phases)
            while(!allPhases.isAtEnd){
                let decoder = try allPhases.superDecoder()
                if let thisPhase = TZPhase(decoder: decoder, referencing: self) {
                    phases.append(thisPhase)
                }
            }
        } catch { // If there is only one phase assumed and its data is stored in the top level file
            if let defaultPhase = TZPhase(decoder: decoder, referencing: self) {
                phases = [defaultPhase]
            }
        }
        
        if container.contains(.runVariants) {
            do {
            if simpleIO {
                let allRunVariants = try container.nestedContainer(keyedBy: RunVariant.VariantTypeKeys.self, forKey: .runVariants)
                if allRunVariants.contains(.single) {
                    var singleRunVariants = try allRunVariants.nestedUnkeyedContainer(forKey: .single)
                    try processVariantType(curRunVariants: &singleRunVariants, type: .single, simpleIO: true)
                }
                if allRunVariants.contains(.mc) {
                    var mcRunVariants = try allRunVariants.nestedUnkeyedContainer(forKey: .mc)
                    try processVariantType(curRunVariants: &mcRunVariants, type: .montecarlo, simpleIO: true)
                }
                if allRunVariants.contains(.trade) {
                    var tradeRunVariants = try allRunVariants.nestedUnkeyedContainer(forKey: .trade)
                    try processVariantType(curRunVariants: &tradeRunVariants, type: .trade, simpleIO: true)
                }
            } else {
                var allRunVariants = try container.nestedUnkeyedContainer(forKey: .runVariants)
                try processVariantType(curRunVariants: &allRunVariants, type: nil, simpleIO: false)
            }
            } catch {
                logMessage("Error reading run variants: \(error.localizedDescription)")
            }

        }
        if tradeGroups.isEmpty {
            tradeGroups = Array<RunGroup>.init(repeating: RunGroup(), count: numTradeGroups)
        }
        
        var allTZOutputs = try container.nestedUnkeyedContainer(forKey: .plots)
        var plotsTemp = allTZOutputs
        while(!allTZOutputs.isAtEnd)
        {
            let output = try allTZOutputs.nestedContainer(keyedBy: TZOutput.CustomCoderType.self)
            let type = try output.decode(TZOutput.OutputType.self, forKey: TZOutput.CustomCoderType.type)
            var newOutput : TZOutput?
            let decoder = try plotsTemp.superDecoder()

            switch type {
            case .text:
                newOutput = TZTextOutput(decoder: decoder, referencing: self)
            case .plot:
                newOutput = TZPlot(decoder: decoder, referencing: self)
            }
            
            guard newOutput != nil else { continue }
            let reqCat = newOutput?.plotType.requiresCategoryVar
            if newOutput!.plotType.requiresCategoryVar && newOutput!.categoryVar == nil {
                newOutput?.categoryVar = TradeGroupParam() // Default to use trade groups if no other category variable is input
            }
            plots.append(newOutput!)
        }
        
        // Final settings
        traj = State(varList)
    }
    
    func encode(to encoder: Encoder) throws {
        let simpleIO : Bool = encoder.userInfo[.simpleIOKey] as? Bool ?? false
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .analysisName)
        // Need to write the simplest conditions first, so the compound conditions have something to refer to when they are read in later
        let sortedConditions = conditions.sorted(by: {$0.subConditionCount < $1.subConditionCount})
        if simpleIO {
            var condsDict = [[String: Condition]]()
            for thisCond in sortedConditions {
                condsDict.append([thisCond.name: thisCond])
            }
            try container.encode(condsDict, forKey: .conditions)
        } else {
            try container.encode(sortedConditions, forKey: .conditions)
        }

        if phases.count == 1 && phases[0].id == "default" && simpleIO {
            let thisPhase = phases[0]
            try thisPhase.encode(to: encoder)
        } else {
            try container.encode(phases, forKey: .phases)
        }
        
        if runVariants.count > 0 {
            if simpleIO { // TODO: Figure the best way to write inactive run variants
                var newContainer = container.nestedContainer(keyedBy: RunVariant.VariantTypeKeys.self, forKey: .runVariants)
                if mcRunVariants.count > 0 {
                    try newContainer.encode(mcRunVariants as? [RunVariant], forKey: .mc)
                }
                if tradeRunVariants.count > 0 {
                    try newContainer.encode(tradeRunVariants, forKey: .trade)
                }
                let singleRunVariants = runVariants.filter({$0.variantType == .single})
                if singleRunVariants.count > 0 {
                    try newContainer.encode(singleRunVariants, forKey: .single)
                }
            } else {
                try container.encode(runVariants, forKey: .runVariants)
            }
        }
        
        try container.encode(plots, forKey: .plots)
    }
    
    /** Creates a data object containing all of the configurations required for setting up a run */
    func copyForRuns() throws->Data {
        let encoder = JSONEncoder()
        encoder.userInfo = [CodingUserInfoKey.simpleIOKey: false, CodingUserInfoKey.deepCopyKey: true]
        let data = try encoder.encode(self.phases)
        //let asysString = String(data: data, encoding: .utf8)!
        //logMessage(asysString)
        return data
    }
}

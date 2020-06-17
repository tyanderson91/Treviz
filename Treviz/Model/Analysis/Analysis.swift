//
//  Analysis.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.

import Cocoa

enum PropagatorType {
    case explicit
    case rungeKutta4
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
    
    var varList : [Variable]!// {return appDelegate.initVars}
    var initStateGroups : InitStateHeader!
    
    // Analysis-specific data and configs (read/writing functions in AnalysisData.swift)
    var name : String = ""
    weak var terminalCondition : Condition!
    var traj: State!
    var initState: StateArray { return traj[0] }
    var conditions : [Condition] = [] // TODO: Turn this into a set instead of an array
    var inputSettings : [Parameter] = []
    var parameters : [Parameter] { //TODO: this should contain more than just input settings
        return inputSettings.filter {$0.isParam}
    }
    @objc var plots : [TZOutput] = []
    var defaultTimestep : VarValue = 0.01
    var vehicle : Vehicle!
    var propagatorType : PropagatorType = .explicit
    var pctComplete: Double = 0

    // Run tracking
    var isRunning = false
    var returnCode : Int = 0
    let analysisDispatchQueue = DispatchQueue(label: "analysisRunQueue", qos: .utility)
    var progressReporter: AnalysisProgressReporter?
    
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
    
    override init(){
        super.init()
    }
    // Validity check prior to running
    /**
     Check whether the analysis has enough inputs defined in order to run
     If this function does not return true, the analysis cannot be run
     - TODO: point out which inputs need to be fixed
     */
    func isValid()->Bool{
        var checks : [Bool] = [] // Array of booleans for each individual condition that must be satisfied
        for _ in self.initStateGroups.subheaders {
            checks.append(true) // thisSet.isValid
        }
        checks.append(contentsOf: [
            self.terminalCondition != nil,
            self.defaultTimestep > 0
        ])
        return checks.allSatisfy { $0 }
    }
    
    
    // MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case name
        case terminalCondition
        case conditions
        case inputSettings
        case plots
    }

    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        inputSettings = try container.decode(Array<Variable>.self, forKey: .inputSettings)
        setupConstants()

        var allConds = try container.nestedUnkeyedContainer(forKey: .conditions)
        while(!allConds.isAtEnd){
            let decoder = try allConds.superDecoder()
            if let thisCond = Condition(decoder: decoder, referencing: self) {
                conditions.append(thisCond)
            }
        }
        
        do {
            let terminalConditionName = try container.decode(String.self, forKey: .terminalCondition)
            terminalCondition = conditions.first { $0.name == terminalConditionName }
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

            if newOutput != nil { plots.append(newOutput!) }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(conditions, forKey: .conditions)
        try container.encode(terminalCondition.name, forKey: .terminalCondition)
        let nonzerovars = (inputSettings as? [Variable])?.filter({$0.value[0] != 0 || $0.isParam})
        try container.encode(nonzerovars, forKey: .inputSettings)
        try container.encode(plots, forKey: .plots)
    }
}

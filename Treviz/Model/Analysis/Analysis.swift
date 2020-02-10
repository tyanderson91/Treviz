//
//  Analysis.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.

import Cocoa

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

class Analysis: NSObject {

    //TODO: possibly subclass NSPersistentDocument if using CoreData
    
    // Connections to interface
    var appDelegate : AppDelegate!
    //var windowController : MainWindowController! //Implicit optional, should always be assigned after initialization
    var viewController : MainViewController!
    
    //AppDelegate variables
    @objc var varList : [Variable]! {return appDelegate.initVars}
    var initStateGroups : InitStateHeader!
    var plotTypes : [TZPlotType]! {return appDelegate.plotTypes}
    
    // Analysis-specific data and configs (read/writing functions in AnalysisData.swift)
    var name : String = ""
    @objc weak var terminalConditions : Condition!
    var traj: State!
    @objc var conditions : [Condition] = []
    var inputSettings : [Parameter] = []
    var parameters : [Parameter] { //TODO: this should contain more than just input settings
        return inputSettings.filter {$0.isParam}
    }
    @objc var plots : [TZOutput] = []
    var defaultTimestep : VarValue = 0.01
    var vehicle : Vehicle!
    var propagatorType : PropagatorType = .explicit
    
    
    // Run tracking
    var isRunning = false
    var returnCode : Int = 0

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
            self.terminalConditions != nil,
            self.defaultTimestep > 0
        ])
        return checks.allSatisfy { $0 }
    }
}

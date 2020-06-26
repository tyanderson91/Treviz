//
//  AnalysisRunFunctions.swift
//  Treviz
//
//  Contains all the code required to actually run an analysis, including the main run loop
//
//  Created by Tyler Anderson on 10/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension Analysis {
        
    func runAnalysis() {
        //Check if enough inputs are defined
        do { try self.isValid() }
        catch {
            self.logMessage("Cannot run analysis due to error in input settings: \(error.localizedDescription)")
            return
        }
        
        // Setup
        
        for thisVar in self.traj.variables { // Delete all data except for initial state
            //let initVal = thisVar.value[0]
            //thisVar.value = [initVal]
            if thisVar.value.count > 1 { thisVar.value.removeLast(thisVar.value.count - 1) }
            if let existingVar = inputSettings.first(where: { (var1: Parameter)->Bool in return var1.id == thisVar.id }) {
                thisVar.value[0] = (existingVar as? Variable)?.value[0] ?? 0
            }
        } // TODO: make this a bit cleaner, using something like the below
        /*
        self.traj.variables = self.traj.variables.compactMap {
            $0.value = [$0.value[0]]
            //let newVar = $0
            //if let existingVar = inputSettings.first(where: { (var1: Parameter)->Bool in return var1.id == newVar.id }) {
            //    newVar.value[0] = (existingVar as? Variable)?.value[0] ?? 0
            //} else { newVar.value = [0] }
            //newVar.value = [$0.value[0]]
            return $0//newVar
        }*/
        self.traj.sortVarIndices() // Ensure that time is the first variable, x is second, etc.
        let dt : VarValue = defaultTimestep

        // let outputTextView = self.viewController.textOutputView!
        
        self.terminalCondition.reset(initialState: traj[0])
        
        traj["mtot",0] = 10.0
        isRunning = true
        //progressReporter?.startProgressTracking()
        analysisDispatchQueue.async {
            var i = 0
            // let initState = self.traj[0]
            while self.isRunning {
                let curstate = self.traj[i]
                var newState = StateArray()
                switch self.propagatorType {
                case .explicit:
                    newState = self.equationsOfMotion(curState: curstate, dt: dt)
                case .rungeKutta4:
                    newState = curstate
                }
                i += 1
                self.traj[i] = newState
                
                // var pctComplete = 0.0
                // self.isRunning = !self.terminalCondition.evaluateSingle(self.traj.copyAtIndex(i))
                // Only use this if ALL state variable can be represented in array form
                let curtraj = self.traj![i]
                self.isRunning = !self.terminalCondition.evaluateStateArray(curtraj)
                
                if !self.isRunning {
                    self.returnCode = 1
                }
                
                DispatchQueue.main.async {
                    let curIndex = self.traj["t"].value.count - 2
                    let curState = self.traj[curIndex]
                    self.progressReporter?.updateProgress(at: curState)
                }
            }

            DispatchQueue.main.async {
                self.progressReporter?.completeAnalysis()
            }
        }
    }
    
    /**
     This is the primary wrapper function for determining the next state based on the current state. It is called by the propagator at least once per timestep, and calls all the functions that determine the forces, moments, and subsequent motion of a vehicle
     */
    func equationsOfMotion(curState: StateArray, dt: VarValue)->StateArray { //TODO: Move calculation of forces and moments to separate function
        
        var x = curState[State.ix]
        var y = curState[State.iy]
        var dx = curState[State.idx]
        var dy = curState[State.idy]
        var t = curState[State.it]
        var m = curState[State.imtot]
        
        let F_g = -9.81*m
        let a_y = F_g/m
        let a_x : VarValue = 0
        
        t += dt
        dy += a_y * dt
        y += dy*dt
        dx += a_x*dt
        x += dx*dt
        m += 0
        let newState : Array<VarValue> = [t, x, y, 0, dx, dy, 0, m]
        
        return newState
    }
}

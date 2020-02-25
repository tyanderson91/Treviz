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
        guard self.isValid() else { return }  // TODO: error code for this case
        
        // Setup
        for thisVar in self.traj.variables { // Delete all data except for initial state
            if thisVar.value.count > 1 { thisVar.value.removeLast(thisVar.value.count - 1) }
            if let existingVar = inputSettings.first(where: { (var1: Parameter)->Bool in return var1.id == thisVar.id }) {
                thisVar.value[0] = (existingVar as? Variable)?.value[0] ?? 0
            }
        }
        self.traj.sortVarIndices() // Ensure that time is the first variable, x is second, etc.
        let dt : VarValue = defaultTimestep

        // let outputTextView = self.viewController.textOutputView!
        
        self.terminalCondition.reset(initialState: traj[0])
        
        isRunning = true
        traj["mtot",0] = 10.0
        DispatchQueue.global().async {
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
                self.isRunning = !self.terminalCondition.evaluateStateArray(self.traj![i])
                
                if !self.isRunning {
                    self.returnCode = 1
                }
                /*
                DispatchQueue.main.async {
                    let curIndex = self.traj["t"].value.count - 2
                    let curState = self.traj[curIndex]
                    /*
                    let t = curState[State.it]
                    let x = curState[State.ix]
                    let y = curState[State.iy]
                    
                    outputTextView.string="t: \(String(format: "%.5f", t)), "
                    outputTextView.string += "X: \(String(format: "%.5f", x)), "
                    outputTextView.string += "Y: \(String(format: "%.5f", y))\n"*/
                    // outputTextView.string.append(String(describing: pctcomp))
                    self.pctComplete = self.pctComplete(cond: self.terminalCondition, initState: initState, curState: curState)
                }*/
            }
            DistributedNotificationCenter.default.post(name: .didFinishRunningAnalysis, object: nil)
        }
    }
    
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
    


    
    /**
     Provide an estimate for the percentage completion of the analysis based on the initial state, current state, and terminal conditions
      - parameters:
        - cond: Condition, the terminal conditions
        - initState: StateArray, the beginning value of all changing values
        - curState: StateArray, the state at the current point in the analysis
     - returns:
        pctComplete: Double, a number between 0 and 1 representing the estimated completion
     */
    private func pctComplete(cond: Condition, initState :StateArray, curState: StateArray)->Double{
        var tempPctComplete = 0.0
        for thisCond in cond.conditions {
            var curPctComplete = 0.0
            if let thisCond1 = thisCond as? SingleCondition {
                let thisVar = State.getValue(thisCond1.varID, curState)!
                let initVar = State.getValue(thisCond1.varID, initState)!
                if thisCond1.equality != nil {
                    let finalVar = thisCond1.equality!
                    curPctComplete = Double((thisVar-initVar) / (finalVar-initVar))
                }
                else if thisCond1.specialCondition != nil {
                    
                } else {
                    let finalVar = thisCond1.ubound != nil ? thisCond1.ubound! : thisCond1.lbound!
                    curPctComplete = Double((thisVar-initVar) / (finalVar-initVar))
                }
            } else { curPctComplete = pctComplete(cond: thisCond as! Condition, initState: initState, curState: curState) }
        
            tempPctComplete = (tempPctComplete < curPctComplete) ? curPctComplete : tempPctComplete
            if tempPctComplete < 0{
                tempPctComplete = 0}
            else if tempPctComplete > 1{
                tempPctComplete = 1}
            }
        return tempPctComplete
    }
}

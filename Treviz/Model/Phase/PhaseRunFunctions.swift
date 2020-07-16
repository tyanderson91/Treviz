//
//  PhaseRunFunctions.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/26/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//
import Cocoa

extension TZPhase {
    
    func runAnalysis() {
        //Check if enough inputs are defined
        for thisVar in self.varList { // Delete all data except for initial state
            if thisVar.value.count > 1 { thisVar.value.removeLast(thisVar.value.count - 1) }
        }
        traj = self.varList.compactMap({$0.stripPhase()})
        traj = traj.filter({self.requiredVarIDs.contains($0.id)})
        
        let dt : VarValue = defaultTimestep
        
        let initState = StateDictSingle(from: traj, at: 0)
        self.terminalCondition.reset(initialState: initState)
        self.returnCode = .NotStarted
        
        traj["mtot",0] = 10.0
        isRunning = true
        var i = 0
        while self.isRunning {
            let curstate = self.traj[i]
            var newState = StateDictSingle()
            switch self.propagatorType {
            case .explicit:
                newState = self.equationsOfMotion(curState: curstate, dt: dt)
            case .rungeKutta4:
                newState = curstate
            }
            i += 1
            self.traj[i] = newState
            
            let curtraj = self.traj![i]
            self.isRunning = !self.terminalCondition.evaluateStateArray(curtraj)
            
            if !self.isRunning {
                self.returnCode = .Success
            }
            
            DispatchQueue.main.async {
                let curIndex = self.traj["t"].value.count - 2
                let curState = self.traj[curIndex]
                self.progressReporter?.updateProgress(at: curState)
            }
        }

        DispatchQueue.main.async {
            self.varList.updateFromDict(traj: self.traj)
            self.analysis.processPhase(self)
        }
    }
    
    /**
     This is the primary wrapper function for determining the next state based on the current state. It is called by the propagator at least once per timestep, and calls all the functions that determine the forces, moments, and subsequent motion of a vehicle
     */
    func equationsOfMotion(curState: StateDictSingle, dt: VarValue)->StateDictSingle { //TODO: Move calculation of forces and moments to separate function
        
        var x = curState["x"]!
        var y = curState["y"]!
        var dx = curState["dx"]!
        var dy = curState["dy"]!
        var t = curState["t"]!
        var m = curState["mtot"]!
        
        let F_g = -9.81*m
        let a_y = F_g/m
        let a_x : VarValue = 0
        
        t += dt
        dy += a_y * dt
        y += dy*dt
        dx += a_x*dt
        x += dx*dt
        m += 0
        let newState : StateDictSingle = ["t":t, "x":x, "y":y, "z":0, "dx":dx, "dy":dy, "dz":0, "mtot":m]
        
        return newState
    }
}
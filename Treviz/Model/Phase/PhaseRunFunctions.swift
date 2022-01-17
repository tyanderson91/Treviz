//
//  PhaseRunFunctions.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/26/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//
import Cocoa

extension TZPhase {
    typealias SIMDD2 = SIMD2<VarValue>
    typealias SIMDD3 = SIMD3<VarValue>
    
    func runAnalysis() {
        //Check if enough inputs are defined
        for thisVar in self.varList { // Delete all data except for initial state
            if thisVar.value.count > 1 { thisVar.value.removeLast(thisVar.value.count - 1) }
        }
        let baseVars1 = self.varList.compactMap({$0.copyWithoutPhase()})
        let baseVars = baseVars1.filter({self.requiredVarIDs.contains($0.id)})
        //traj
        traj = StateDictArray(from: baseVars, at: 0)
        
        let dt : VarValue = runSettings.defaultTimestep.value
        
        let initState = traj[0]
        self.terminalCondition.reset(initialState: initState)
        self.returnCode = .NotStarted
        
        traj["mtot"] = [self.vehicle.mass]
        isRunning = true
        var i = 0
        while self.isRunning {
            let curstate = self.traj[i]
            var newState = StateDictSingle()
            switch runSettings.propagatorType.value as! PropagatorType {
            case .explicit:
                newState = self.equationsOfMotion(curState: curstate, dt: dt)
            case .rungeKutta4:
                newState = self.equationsOfMotion(curState: curstate, dt: dt)
            }
            i += 1
            self.traj.append(newState)
            
            let curtraj = self.traj![i]
            do { self.isRunning = try !self.terminalCondition.evaluateSingleState(curtraj) }
            catch {
                self.isRunning = false
                analysis.logError("trouble evaluating terminal condition: \(error)")
            }
            
            if !self.isRunning {
                self.returnCode = .Success
            }
            /*
            DispatchQueue.main.async {
                let t = self.traj["t"]
                var curIndex = t!.count - 2
                curIndex = curIndex < 0 ? 0 : curIndex
                let curState = self.traj[curIndex]
                self.progressReporter?.updateProgress(at: curState)
            }*/
        }
/*
        if self.runMode == .parallel {
            DispatchQueue.main.async {
                self.varList.updateFromDict(traj: self.traj)
                self.parentRun.processPhase(self)
            }
        }
        else {*/
            self.varList.updateFromDict(traj: self.traj)
            self.parentRun.processPhase(self)
        //}
    }
    
    /**
     This is the primary wrapper function for determining the next state based on the current state. It is called by the propagator at least once per timestep, and calls all the functions that determine the forces, moments, and subsequent motion of a vehicle
     */
    func equationsOfMotion(curState: StateDictSingle, dt: VarValue)->StateDictSingle { //TODO: Move calculation of forces and moments to separate function
        var pos = SIMDD2(curState["x"]!, curState["y"]!)
        var vel = SIMDD2(curState["dx"]!, curState["dy"]!)

        var t = curState["t"]!
        var m = curState["mtot"]!
        
        let F_g = SIMDD2(0, -9.81)*m
        let accel = F_g/m
        
        pos += vel*dt
        vel += accel*dt
        t += dt
        m += 0
        let newState : StateDictSingle = ["t":t, "x":pos.x, "y":pos.y, "z":0, "dx":vel.x, "dy":vel.y, "dz":0, "mtot":m]
        
        return newState
    }
}

//
//  OutputDataSet.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/19/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa
import OrderedDictionary
/**
 Structure to contain the number sets that feed into text and plot outputs
 Format varies depending on whether categories and conditions are used
 */

struct OutputDataSet {
    var allGroups: OrderedDictionary<String, [OutputDataSetSingle]> = ["":[OutputDataSetSingle()]]
    var allDataSets: [OutputDataSetSingle]? {
        var tmpSets = [OutputDataSetSingle]()
        for (_, groupsets) in allGroups {
            tmpSets.append(contentsOf: groupsets)
        }
        return tmpSets
    }
    var singleSet: OutputDataSetSingle? {
        get {
            if multiSet != nil { return multiSet!.first }
            else { return nil }
        } set {
            if multiSet != nil && newValue != nil { multiSet![0] = newValue! }
        }
    }
    var groupedSet: OrderedDictionary<String, OutputDataSetSingle>? {
        get {
            var newDict = OrderedDictionary<String, OutputDataSetSingle>()
            allGroups.forEach({newDict[$0] = $1.first})
            return newDict
        } set {
            newValue?.forEach({allGroups[$0] = [$1]})
        }
    }
    var multiSet: [OutputDataSetSingle]? {
        get {
            return allGroups.first?.value
        } set {
            allGroups[allGroups.first?.key ?? ""] = newValue
        }
    }
    
    var var1: [VarValue]? {
        get { return singleSet?.var1 }
        set { singleSet?.var1 = newValue }
    }
    var var2: [VarValue]? {
        get { return singleSet?.var2 }
        set { singleSet?.var2 = newValue }
    }
    var var3: [VarValue]? {
        get { return singleSet?.var3 }
        set { singleSet?.var3 = newValue }
    }
}

struct OutputDataSetSingle {
    var var1: [VarValue]?
    var var2: [VarValue]?
    var var3: [VarValue]?
    var identifier: String = ""
    var groupName: String = ""
    
    init(){}
    
    init(traj: [Variable], output: TZOutput, identifier idIn: String="", groupName groupNameIn: String="") throws {
        if output.plotType.requiresCondition {
            guard let condStates = traj[output.condition!] else {
                throw TZOutputError.UnmatchedConditionError }
            if output.var1 != nil { var1 = condStates[output.var1!.id]! }
            if output.var2 != nil { var2 = condStates[output.var2!.id]! }
            if output.var3 != nil { var3 = condStates[output.var3!.id]! }
        } else {
            if output.var1 != nil { var1 = traj[output.var1!.id]?.value }
            if output.var2 != nil { var2 = traj[output.var2!.id]?.value }
            if output.var3 != nil { var3 = traj[output.var3!.id]?.value }
        }
        identifier = idIn
        groupName = groupNameIn
    }
}


extension TZOutput {
    func getData() throws -> OutputDataSet? {
        guard runData != nil else { throw TZOutputError.RunMissingTrajectoryError } // Collection of all runs
        //let curRun = runData![0]
        //guard let curTraj = curRun.trajData else { throw TZOutputError.RunMissingTrajectoryError }
        
        var outputDataSet = OutputDataSet()
        //var lineSet = dataSet.singleSet!
        if categoryVar == nil {
            var dataSets: [OutputDataSetSingle] = []
            for thisRun in self.runData! {
                let curDataSet = try OutputDataSetSingle(traj: thisRun.trajData, output: self, identifier: thisRun.id)
                dataSets.append(curDataSet)
            }
            outputDataSet.multiSet = dataSets
        } else {
            outputDataSet.allGroups = [:]
            for thisRun in self.runData! {
                guard let matchingParam = thisRun.parameters.first(where: {$0.id == categoryVar!.id})
                else { throw TZOutputError.MissingVariableError }
                let curVal = matchingParam.stringValue
                let groupName = thisRun.tradeGroupName
                //let groupName = "\(matchingParam.id)=\(curVal)" // TODO: Fix this for all group name types
                let curDataSet = try OutputDataSetSingle(traj: thisRun.trajData, output: self, identifier: thisRun.id, groupName: groupName)
                if outputDataSet.allGroups.containsKey(groupName) { outputDataSet.allGroups[groupName]!.append(curDataSet) }
                else { outputDataSet.allGroups[groupName] = [curDataSet] }
            }
        }
        return outputDataSet
    }
}

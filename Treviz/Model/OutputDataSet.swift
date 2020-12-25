//
//  OutputDataSet.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/19/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 Structure to contain the number sets that feed into text and plot outputs
 Format varies depending on whether categories and conditions are used
 */

struct OutputDataSet {
    var allGroups: [Int: [OutputDataSetSingle]] = [0:[OutputDataSetSingle()]]
    var singleSet: OutputDataSetSingle? {
        get {
            if multiSet != nil { return multiSet!.first }
            else { return nil }
        } set {
            if multiSet != nil && newValue != nil { multiSet![0] = newValue! }
        }
    }
    var groupedSet: [Int: OutputDataSetSingle]? {
        get {
            var newDict = Dictionary<Int, OutputDataSetSingle>()
            allGroups.forEach({newDict[$0] = $1.first})
            return newDict
        } set {
            newValue?.forEach({allGroups[$0] = [$1]})
        }
    }
    var multiSet: [OutputDataSetSingle]? {
        get {
            return allGroups[0]
        } set {
            allGroups[0] = newValue
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
}


extension TZOutput {
    func getData() throws -> OutputDataSet? {
        guard runData != nil else { throw TZOutputError.RunMissingTrajectoryError } // Collection of all runs
        let curRun = runData![0]
        guard let curTraj = curRun.trajData else { throw TZOutputError.RunMissingTrajectoryError }
        
        var dataSet = OutputDataSet()
        var lineSet = dataSet.singleSet!
                 
        if plotType.requiresCondition {
            guard let condStates = curTraj[condition!] else {
                throw TZOutputError.UnmatchedConditionError }
            if var1 != nil { lineSet.var1 = condStates[var1!.id]! }
            if var2 != nil { lineSet.var2 = condStates[var2!.id]! }
            if var3 != nil { lineSet.var3 = condStates[var3!.id]! }
            dataSet.singleSet = lineSet
            return dataSet
        } else if categoryVar == nil {
            if var1 != nil { lineSet.var1 = curTraj[var1!.id]?.value }
            if var2 != nil { lineSet.var2 = curTraj[var2!.id]?.value }
            if var3 != nil { lineSet.var3 = curTraj[var3!.id]?.value }
            dataSet.singleSet = lineSet
            return dataSet
        } else { return nil } // TODO: Implement category variables
    }
}
/*struct CategoryOutputDataSet: Dictionary<Parameter, OutputDataSet>, OutputDataSet{ //TODO: make Parameter able to be used as a dictionary key. Likely requires PAT: https://www.youtube.com/watch?v=XWoNjiSPqI8&feature=youtu.be
    
}*/

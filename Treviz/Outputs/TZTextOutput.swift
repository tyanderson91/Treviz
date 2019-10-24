//
//  TZTextOutput.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/2/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class TZTextOutput: TZOutput {
    func getText()->NSAttributedString{
        let outputString = NSMutableAttributedString()
        switch self.plotType.name {
        case "Single Value":
            outputString.append(loopThroughSingleVar())
        default:
            outputString.append(NSAttributedString())
        }
        return outputString as NSAttributedString
    }
    
    convenience init(id: Int, with output : TZOutput) {// TODO: conform to "copying" protocol?
        self.init(id : id, plotType: output.plotType)
        displayName = output.displayName + " (Text)"
        title = output.title
        var1 = output.var1
        var2 = output.var2
        var3 = output.var3
        categoryVar = output.categoryVar
        condition = output.condition
        curTrajectory = output.curTrajectory
    }
    
    private func loopThroughSingleVar()->NSAttributedString {
        guard let thisVar = self.var1 else {return NSAttributedString(string: "No variable assigned")}
        guard let curTraj = curTrajectory else {return NSAttributedString(string: "No trajectory assigned")}
        assert(condition?.isSinglePoint ?? false, "Condition not set or condition produces muliple points")
        guard let varDoubleValues = curTraj[thisVar, condition!] else {
            return NSAttributedString(string: "No matching points could be found for output set '\(self.displayName)'")}
        let stringOutput = NSMutableAttributedString(string: "\(thisVar.name): ", attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: 12)])
        let strval = String(format: "%2.4f", varDoubleValues[0])
        stringOutput.append(NSAttributedString(string: strval, attributes: [NSAttributedString.Key.font : NSFont.systemFont(ofSize: 12)]))
        return stringOutput as NSAttributedString
    }
}

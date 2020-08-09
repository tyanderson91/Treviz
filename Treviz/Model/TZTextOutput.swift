//
//  TZTextOutput.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/2/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
TZTextOutput is the object that contains formatting information for outputs printed to the text console. Nearly every output that can be shown in a graph can also have its information printed to the console for use in other programs.
*/
final class TZTextOutput: TZOutput {
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingsKeys.self)
        try container.encode("text", forKey: .outputType)
        try super.encode(to: encoder)
    }
    /**
     Takes the output configuration stored in the TZOutput instance and renders it as a block of text suitable for displaying in a text view
     */
    func getText() throws->NSAttributedString{
        var outputString = NSMutableAttributedString()
        do {
            switch self.plotType {
            case .singleValue:
                guard let thisVar = self.var1 else { throw TZOutputError.MissingVariableError }
                let data = try getData() as! OutputDataSetLines
                outputString = NSMutableAttributedString(string: "\(self.displayName):\t", attributes: [NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: 12)])
                if let var1Data = data.var1 {
                    var strvals = [String]()
                    for thisVal in var1Data {
                        strvals.append(String(format: "%2.4f", thisVal))
                    }
                    let strval = strvals.joined(separator: ", ")
                    outputString.append(NSAttributedString(string: strval, attributes: [NSAttributedString.Key.font : NSFont.systemFont(ofSize: 12)]))
                }

            default:
                outputString = NSMutableAttributedString()
            }
        }
        
        return outputString as NSAttributedString
    }
}

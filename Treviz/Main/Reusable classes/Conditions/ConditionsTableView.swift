//
//  ConditionsTableView.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/12/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//


import Cocoa

class ConditionsTableView: NSTableView {

    var analysis: Analysis!
    var conditionViewController: ConditionsViewController!

    var tableSelector: ((NSTableView) -> ())?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func keyDown(with event: NSEvent) {

        if event.characters?.count == 1 {
            let character = event.keyCode
            switch (character) {
            case UInt16(126):
                tableSelector!(self)
            case UInt16(125):
                tableSelector!(self)
            default:
                super.keyDown(with: event)
            }
        }
        super.keyDown(with: event)
    }
    
}

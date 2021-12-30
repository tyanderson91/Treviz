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
        super.keyDown(with: event)

        if event.characters?.count == 1 {
            let character = event.keyCode
            switch (character) {
            case UInt16(126):
                tableSelector!(self)
            case UInt16(125):
                tableSelector!(self)
            default:
                break
            }
        }
    }
    
    override func mouseDown(with event: NSEvent){
        let point = event.locationInWindow
        let tablePoint = self.convert(point, from: nil)
        let row = self.row(at: tablePoint)
        if row == -1 { // If mouse click was outside of the rows
            self.deselectAll(nil)
        }
        super.mouseDown(with: event)
    }
}

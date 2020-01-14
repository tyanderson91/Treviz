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
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func keyDown(with event: NSEvent) {

        if event.characters?.count == 1 {
            let character = event.keyCode
            switch (character) {
            case UInt16(126):
                if selectedRow == 0 {
                    selectRowIndexes([numberOfRows - 1], byExtendingSelection: false)
                    scrollRowToVisible(numberOfRows - 1)
                    //scrollToEndOfDocument(nil)
                } else {
                    super.keyDown(with: event)
                }
                break
            case UInt16(125):
                if selectedRow == numberOfRows - 1 {
                    selectRowIndexes([0], byExtendingSelection: false)
                    scrollRowToVisible(0)
                    //scrollToBeginningOfDocument(nil)
                } else {
                    super.keyDown(with: event)
                }
            default:
                super.keyDown(with: event)
                break
            }
        } else {
            super.keyDown(with: event)
        }
    }
    
    func changeSelection(){
        
    }
    
}

//
//  EditableHeaderTextField.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/24/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

class EditableHeaderTextField: NSTextField {

    var canEdit = false
    override var intrinsicContentSize: NSSize {
        let height = self.attributedStringValue.size().height
        let width = self.attributedStringValue.size().width + 10
        let setwidth = width > 70 ? width : 70
        return NSMakeSize(setwidth, height)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        self.resignFirstResponder()
        let text = self.stringValue
        self.setFrameSize(NSSize(width: text.count, height: 50))
    }
    
}

//
//  InitStateOutlineView.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/6/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class InitStateOutlineView: NSOutlineView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func refreshSetting(_ inputSetting : InputSetting){
        self.reloadItem(inputSetting)
        if let headingItem = inputSetting.heading{
            self.refreshSetting(headingItem)
        }
    }
    
}

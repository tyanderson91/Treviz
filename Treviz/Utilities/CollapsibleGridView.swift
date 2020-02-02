//
//  CollapsibleGridView.swift
//  testApp
//
//  Created by Tyler Anderson on 8/8/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

protocol CanHide {
    var isHidden: Bool {get set}
}
extension NSGridRow: CanHide {
}
extension NSGridColumn: CanHide {
}

class CollapsibleGridView: NSGridView {

    var shouldAnimate = true
    enum showHide {
        case show, hide//,toggle
    }
    
    enum rowCol {
        case row, column
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    func showHide(_ method: showHide, _ rowsCols: rowCol, index: [Int]){
        var numUnits = 0
        var extractor : ((Int)->(CanHide))!
        switch rowsCols {
        case .row:
            numUnits = self.numberOfRows
            extractor = self.row
        case .column:
            numUnits = self.numberOfColumns
            extractor = self.column
        }
        
        let shouldCollapse = method == .hide
        for i in index {
            guard i>=0 && i<numUnits else { print("Invalid index \(i). Cannot show/collapse"); continue }
            var thisUnit = extractor(i)
            let alreadyInState = (thisUnit.isHidden == shouldCollapse)
            if !alreadyInState {
                thisUnit.isHidden = shouldCollapse
            }
        }
    }
}

//
//  CollapsibleStackView.swift
//  This is a class of stack views that allows collapsing an interier view
//
//  Created by Tyler Anderson on 8/6/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class CollapsibleStackView: NSStackView {

    var allViews : [NSView] {return self.arrangedSubviews}
    var shouldAnimate = false
    enum showHide {
        case show, hide//,toggle
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }

    /** Method shows or hides the subviews at the seletced indices */
    func showHideViews(_ method : showHide, index : [Int]) {
        let numViews = allViews.count

        let shouldCollapse = method == .hide
        for i in index {
            guard i>=0 && i<numViews else { print("Invalid index \(i). Cannot show/collapse"); continue }
            let thisView = allViews[i]
            let alreadyInState = (thisView.isHidden == shouldCollapse)
            if !alreadyInState {
                let viewCollapseMethod = (shouldAnimate ? thisView.animator() : thisView)
                viewCollapseMethod.isHidden = shouldCollapse
            }
        }
    }
}

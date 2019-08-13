//
//  CollapsibleGridView.swift
//  testApp
//
//  Created by Tyler Anderson on 8/8/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class CollapsibleGridView: NSGridView { // TODO : Make collapsible rows as well

    var shouldAnimate = true
    enum showHide {
        case show,hide//,toggle
    }
    
    enum rowCol {
        case row,column
    }
    
    enum collapseViewError : Error{
        case invalidIndex
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    func showHideCols(_ method : showHide, index : [Int]) {
        
        let numCols = self.numberOfColumns
        
        var curindex = index
        switch method {
        case .show:
            curindex.sort(by: <) // Required to avoid index errors with a changing index
        case .hide:
            curindex.sort(by: >)
            //default:
            //curindex = index
        }
        
        for i in curindex {
            if i<0 || i>=numCols { print("Invalid index \(i). Cannot show/collapse"); continue }
            
            if method == .show{
                showCol(i)
            }
            else if (method == .hide) {
                collapseCol(i)
            }
        }
    }
    
   private  func collapseCol(_ subViewIndex : Int){
        let thisCol = self.column(at: subViewIndex)
        if thisCol.isHidden == false {
            if shouldAnimate{
                thisCol.isHidden = true
                /*NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 2
                thisCol.width = 0
                NSAnimationContext.endGrouping()*/
            } else {
                thisCol.isHidden = true
            }
        }
    }
    
    private func showCol(_ subViewIndex : Int){
        let curCol = self.column(at: subViewIndex)
        if curCol.isHidden == true {// TODO : figure out a woy to animate this
            if shouldAnimate{
                let thisCol = self.animator().column(at: subViewIndex)
                thisCol.isHidden = false
                /*NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 2
                thisCol.width = 100
                NSAnimationContext.endGrouping()*/
                //self.animator().insertArrangedSubview(thisView, at : subViewIndex)
            } else {
                //self.insertArrangedSubview(thisView, at : subViewIndex)
                let thisCol = self.column(at: subViewIndex)
                thisCol.isHidden = false
            }
        }
    }
}

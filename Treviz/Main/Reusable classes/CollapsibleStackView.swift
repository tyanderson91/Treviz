//
//  CollapsibleStackView.swift
//  This is a class of stack views that allows collapsing an interier view
//
//  Created by Tyler Anderson on 8/6/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

// TODO : Make code cleaner and shorter if possible
import Cocoa

class CollapsibleStackView: NSStackView {

    var allViews : [NSView]? //TODO : Figure out if I really even need to store these views
    var numShown : Int = 0
    var shouldAnimate = true
    enum showHide {
        case show,hide//,toggle
    }
    
    enum collapseViewError : Error{
        case invalidIndex
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        initAllViews()
        // Drawing code here.
    }
    
    func initAllViews(){
        if allViews == nil {
            allViews = self.arrangedSubviews
        }
        numShown = 0
        for thisView in allViews!{
            numShown += (thisView.isHidden ? 0 : 1)
        }
    }
    
    func showHideViews(_ method : showHide, index : [Int]) {
        initAllViews()
        let numViews = allViews!.count
        var curindex = index
        
        switch method {
        case .show:
            curindex.sort(by: <)
        case .hide:
            curindex.sort(by: >)
        //default:
            //curindex = index
        }
        for i in curindex {
            if i<0 || i>=numViews { print("Invalid index \(i). Cannot show/collapse"); continue }
            
            if method == .show{
                showView(i)
            }
            else if (method == .hide) {
                collapseView(i)
            }
        }
    }
    
    private func collapseView(_ subViewIndex : Int){
        if !(allViews?[subViewIndex].isHidden)!{
            if let thisView = allViews?[subViewIndex] {
            //let thisView = arrangedSubviews[subViewIndex]
                if shouldAnimate{
                    thisView.animator().isHidden = true
                    self.animator().removeArrangedSubview(arrangedSubviews[subViewIndex])
                } else {
                    thisView.isHidden = true
                    self.removeArrangedSubview(arrangedSubviews[subViewIndex])
                }
            }
        }
    }
    
    private func showView(_ subViewIndex : Int){
        if (allViews?[subViewIndex].isHidden)!{
            if let thisView = allViews?[subViewIndex] {
                if shouldAnimate{
                    thisView.animator().isHidden = false
                    self.animator().insertArrangedSubview(thisView, at : subViewIndex)
                } else {
                    self.insertArrangedSubview(thisView, at : subViewIndex)
                    thisView.isHidden = false
                }
            }
        }
    }
}

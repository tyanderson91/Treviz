//
//  OutputsViewController.swift
//  Treviz
//
//  Controls display of all analysis output information
//
//  Created by Tyler Anderson on 3/8/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSStoryboardSegue.Identifier{
    static let outputSplitViewSegue = "outputSplitViewSegue"
    static let textOutputSplitViewSegue = "textOutputsSplitViewSegue"
    static let viewerOutputSplitViewSegue = "viewerOutputSplitViewSegue"
    //static let textOutputViewSegue = "textOutputViewSegue"
}

class OutputsViewController: TZViewController {
        
    @IBOutlet weak var outputsSplitView: NSView!
    var outputSplitViewController: OutputsSplitViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        //view.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .outputSplitViewSegue {
            self.outputSplitViewController =  segue.destinationController as? OutputsSplitViewController
            self.outputSplitViewController?.analysis = analysis
        }
    }
}


class OutputsSplitViewController: TZSplitViewController {
    
    @IBOutlet weak var viewerOutputSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var textOutputSplitViewItem: NSSplitViewItem!
    
    var viewerTabViewController: ViewerTabViewController {
        return viewerOutputSplitViewItem.viewController as! ViewerTabViewController
    }
    
    var textOutputViewController: TextOutputSplitViewController! {
        if let _textOutputViewVC = textOutputSplitViewItem.viewController as? TextOutputSplitViewController { return _textOutputViewVC }
        else {return nil}
    }
    var textOutputView: NSTextView! {
        return textOutputViewController?.textOutputView
    }
    var visualizerViewController: VisualizerViewController! { return viewerTabViewController.visualizerTabViewItem.viewController as? VisualizerViewController ?? nil }
    var plotViewController: PlotOutputViewController! { return viewerTabViewController.plotTabViewItem.viewController as? PlotOutputViewController ?? nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.analysis.plotOutputViewer = plotViewController
    }
    
}

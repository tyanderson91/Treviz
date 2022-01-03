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

/**
 The Outputs View Controller is primarily a container for the OutputsSplitViewController
 */
class OutputsViewController: TZViewController {
        
    @IBOutlet weak var toolbarOffsetConstraint: NSLayoutConstraint!
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

/**
 The OutputsSplitViewController is a controller for a vertical split view that divides the Outputs Viewer View Controller from the text output and logger
 */
class OutputsSplitViewController: TZSplitViewController {
    
    @IBOutlet weak var viewerOutputSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var textOutputSplitViewItem: NSSplitViewItem!
    
    var viewerTabViewController: DynamicTabViewController {
        return viewerOutputSplitViewItem.viewController as! DynamicTabViewController
    }
    
    var textOutputViewController: TextOutputSplitViewController! {
        if let _textOutputViewVC = textOutputSplitViewItem.viewController as? TextOutputSplitViewController { return _textOutputViewVC }
        else {return nil}
    }
    var textOutputView: NSTextView! {
        return textOutputViewController?.textOutputView
    }
    var visualizerViewController: VisualizerViewController!
    //var plotViewController: PlotOutputSplitViewController!
    var defaultImageVC: DefaultImageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sb1 = NSStoryboard(name: "Outputs", bundle: nil) // TODO: make separate viewer storyboard
        defaultImageVC = sb1.instantiateController(withIdentifier: "defaultImageViewController") as? DefaultImageViewController
        viewerTabViewController.setDefaultView(vc: defaultImageVC)
        
        let sb2 = NSStoryboard(name: "Outputs", bundle: nil)
        visualizerViewController = sb2.instantiateController(withIdentifier: "visualizerOutput") as? VisualizerViewController
        //plotViewController = sb2.instantiateController(withIdentifier: "plotOutputSplitViewController") as? PlotOutputSplitViewController
        //self.analysis.plotOutputViewer = newPlotViewController
        
        visualizerViewController.analysis = self.analysis
        //plotViewController.analysis = self.analysis
        
        let A = viewerTabViewController.addNewViewController(controller: visualizerViewController)
        A.isPinned = true
    }
    
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        visualizerViewController?.resizeView()
    }
}

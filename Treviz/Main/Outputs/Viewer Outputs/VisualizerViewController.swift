//
//  PlotViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 11/2/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class VisualizerViewController: TZViewController {

    @IBOutlet weak var placeholderImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        placeholderImageView.image = NSImage(named: analysis.phases[0].physicsSettings.centralBodyParam.stringValue)
        //placeholderImageView.image = nil
        // Do view setup here.
    }
    
}

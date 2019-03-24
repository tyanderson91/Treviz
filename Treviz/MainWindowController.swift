//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSToolbarDelegate {

    
    @IBOutlet weak var toolbar: NSToolbar!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let newSize = NSSize.init(width: 1500, height: 700)
        self.window?.setContentSize(newSize)
        let topLeftPoint = NSPoint.init(x: 100, y: 1500)
        self.window?.setFrameTopLeftPoint(topLeftPoint)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    /*
    override func perform(_ aSelector: runAnalysisClicked, on thr: Thread, with arg: Any?, waitUntilDone wait: Bool, modes array: [String]?) {
        <#code#>
    }
 */
}

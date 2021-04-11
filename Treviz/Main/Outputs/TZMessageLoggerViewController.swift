//
//  TZMessageLoggerViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/7/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

class TZMessageLoggerViewController: TZViewController, TZLogger {

    @IBOutlet var messageLoggerTextView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        analysis.logMessageView = self
        // Do view setup here.
    }
    
     //TZLogger implementation
    func logMessage(_ message: NSAttributedString) {
        self.messageLoggerTextView.textStorage?.append(message)
        self.messageLoggerTextView.textStorage?.append(NSAttributedString(string: "\n"))
        self.messageLoggerTextView.scrollToEndOfDocument(nil)
    }
    
    func logMessage(_ message: String) {
        let attrString = NSAttributedString(string: message)
        logMessage(attrString)
    }
    
}

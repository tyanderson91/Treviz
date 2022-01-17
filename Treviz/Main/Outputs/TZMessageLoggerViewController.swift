//
//  TZMessageLoggerViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/7/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 Message logger is the view controller for the text view that presents all log messages
 */
class TZMessageLoggerViewController: TZViewController, TZLogger {
    func makeErrorSound() {
        NSSound.beep()
    }

    @IBOutlet var messageLoggerTextView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        analysis.logMessageView = self
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

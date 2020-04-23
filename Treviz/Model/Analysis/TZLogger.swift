//
//  TZLogger.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/11/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 TZLogger is a protocol adopted to allow for the display of user-facing error, warning, and information messages
 */
protocol TZLogger {
    func logMessage(_ message: NSAttributedString)
    func logMessage(_ message: String)
}

extension Analysis: TZLogger {
    func logMessage(_ message: NSAttributedString) {
        if let messageView = logMessageView {
            messageView.logMessage(message)
        }
    }
    
    func logMessage(_ message: String) {
        if let messageView = logMessageView {
            messageView.logMessage(message)
        }
    }
    

}

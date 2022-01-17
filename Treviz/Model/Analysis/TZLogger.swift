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
    func makeErrorSound()
}
extension TZLogger {
    func logMessage(_ message: String) {
        logMessage(NSAttributedString(string: message))
    }
}

extension Analysis: TZLogger {
    func logMessage(_ message: NSAttributedString) {
        if let messageView = logMessageView {
            messageView.logMessage(message)
        } else {
            _bufferLog.append(message)
            _bufferLog.append(NSAttributedString(string: "\n"))
        }
    }
    func makeErrorSound() {
        logMessageView?.makeErrorSound()
    }
    func logError(errorMessage: NSAttributedString) {
        makeErrorSound()
        let newString = NSMutableAttributedString(string: "Error: ", attributes: [.foregroundColor:NSColor.red, .font:NSFont.boldSystemFont(ofSize: 12)])
        newString.append(errorMessage)
        logMessage(newString)
    }
    func logError(_ errorMessage: String) {
        logError(errorMessage: NSAttributedString.init(string: errorMessage))
    }
}

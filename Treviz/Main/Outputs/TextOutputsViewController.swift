//
//  TextOutputsViewController.swift
//  Treviz
//
//  Controls the display of text-based outputs
//
//  Created by Tyler Anderson on 3/21/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa


extension NSStoryboardSegue.Identifier{
    static let loggerViewSegue = "loggerViewSegue"
}

class TextOutputContainerViewController: TZViewController{
    @IBOutlet weak var textOutputSplitView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

/**
 This SplitViewController controls a horizontal split view separating the text outputs from the log view
 */
class TextOutputSplitViewController: TZSplitViewController{
    
    @IBOutlet weak var textOutputSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var messageLoggerSplitViewItem: NSSplitViewItem!
    var textOutputViewController: TextOutputsViewController! {
        return textOutputSplitViewItem.viewController as? TextOutputsViewController ?? nil
    }
    var textOutputView: NSTextView! {
        return textOutputViewController!.textOutputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

/**
 This view displays all text outputs sequentially
 */
class TextOutputsViewController: TZViewController {

    @IBOutlet var textOutputView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textOutputView.string.append("Analysis results will be shown below \n")
        self.analysis.textOutputViewer = self
    }
    
}
extension TextOutputsViewController: TZTextOutputViewer {
    func clearOutput() {
        self.textOutputView.string = ""
    }
    func printOutput(curOutput: TZTextOutput) throws {
        let newText = try curOutput.getText()
        textOutputView.textStorage?.append(newText)
        textOutputView.textStorage?.append(NSAttributedString(string: "\n\n"))
    }
}

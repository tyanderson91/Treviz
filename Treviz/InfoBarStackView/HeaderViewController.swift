/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View Controller managing the header user interface for each stack item, containing the title and disclosure button.
 */

import Cocoa

class HeaderViewController : NSViewController, StackItemHeader {
    
    @IBOutlet weak var headerTextField: NSTextField!
    @IBOutlet weak var showHideButton: NSButton!
    
    var disclose: (() -> ())? // This state will be set by the item view controller.
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        headerTextField.stringValue = title!
        
        // We want the header's color to be different color than its associated stack item.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        // view.layer?.borderColor = NSColor.controlBackgroundColor.cgColor
        // view.layer?.borderWidth = 1

        //#if !DisclosureTriangleAppearance
        // Track the mouse movement so we can show/hide the disclosure button.
        let trackingArea = NSTrackingArea(rect: self.view.bounds,
                                          options: [NSTrackingArea.Options.mouseEnteredAndExited,
                                                    NSTrackingArea.Options.activeAlways,
                                                    NSTrackingArea.Options.inVisibleRect],
                                          owner: self,
                                          userInfo: nil)
    
        // For the non-triangle disclosure button header, we want the button to auto hide/show on mouse tracking.
        view.addTrackingArea(trackingArea)
//#endif
    }
    
    // MARK: - Actions
    override func mouseUp(with event: NSEvent) {
        disclose?()
    }
    
    // MARK: - Mouse tracking
    
    override func mouseEntered(with theEvent: NSEvent) {
        
        // Mouse entered the header area, show disclosure button.
        super.mouseEntered(with: theEvent)
        showHideButton.isHidden = false
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        
        // Mouse exited the header area, hide disclosure button.
        super.mouseExited(with: theEvent)
        showHideButton.isHidden = true
    }
    
    // MARK: - StackItemHeader Procotol

    func update(toDisclosureState: StackItemContainer.DisclosureState) {
        
        switch toDisclosureState {
        case .open:
            showHideButton.state = NSControl.StateValue.on
        case .closed:
            showHideButton.state = NSControl.StateValue.off
        }

        // Save the disclosure state to user defaults for next launch.
        UserDefaults().set(toDisclosureState.rawValue, forKey: headerTextField.stringValue)
    }
    
}

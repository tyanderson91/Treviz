//
//  PreferencesViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/7/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Cocoa

class PreferencesWindowController:
    NSWindowController, NSWindowDelegate {
    var parentItem: NSMenuItem?
    var appDelegate: AppDelegate!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
        if let prefVC = self.contentViewController as? PreferencesViewController {
            prefVC.appDelegate = appDelegate
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func windowWillClose(_ notification: Notification) {
        parentItem?.isEnabled = true
    }
}

class PreferencesViewController: NSTabViewController {
    var appDelegate: AppDelegate!
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        UserDefaults.standard.setValue(tabViewItem?.identifier, forKey: "selectedPreferencesTab")
    }
    override func viewDidLoad() {
        let selectedTab = UserDefaults.standard.string(forKey: "selectedPreferencesTab")
        super.viewDidLoad()
        if selectedTab != nil {
            tabView.selectTabViewItem(withIdentifier: selectedTab!)
            let selectedVC = tabView.selectedTabViewItem?.viewController
            if let gvc = selectedVC as? GeneralPreferencesViewController {
                gvc.appDelegate = self.appDelegate
            }
        }
    }
    
    override func viewWillAppear() { // TODO: dependency injection earlier in the process
        let selectedVC = tabView.selectedTabViewItem?.viewController
        if let gvc = selectedVC as? GeneralPreferencesViewController {
            gvc.appDelegate = self.appDelegate
        }
    }
}

class GeneralPreferencesViewController: NSViewController {
    @IBOutlet weak var expandedToolbarButton: NSButton!
    @IBOutlet weak var unifiedToolbarButton: NSButton!
    @IBOutlet weak var compactToolbarButton: NSButton!
    @IBOutlet weak var showToolbarTextButton: NSButton!
    @IBOutlet weak var showFullSizeButton: NSButton!
    
    var appDelegate: AppDelegate!
    var windowControllers: Array<MainWindowController> { appDelegate.application.windows.compactMap({$0.windowController as? MainWindowController}) as Array<MainWindowController>
    }
    
    override func viewWillAppear() { // TODO: inject dependencies earlier
        let showText = UserDefaults.showToolbarText
        if showText {
            showToolbarTextButton.state = .on
        } else { showToolbarTextButton.state = .off }
        
        let style = UserDefaults.toolbarStyle
        expandedToolbarButton.state = .off
        unifiedToolbarButton.state = .off
        compactToolbarButton.state = .off
        showToolbarTextButton.isEnabled = true
        switch style {
        case "expanded": expandedToolbarButton.state = .on
        case "unified": unifiedToolbarButton.state = .on
        case "compact":
            compactToolbarButton.state = .on
            showToolbarTextButton.isEnabled = false
            showToolbarTextButton.state = .off
        default: return
        }
    }
    
    @IBAction func didSelectToolbarStyle(_ sender: NSButton) {
        guard let styleString = sender.identifier?.rawValue else { return }
        var showText: Bool
        if styleString == "compact" {
            showText = false
            UserDefaults.showToolbarText = false
            showToolbarTextButton.isEnabled = false
            showToolbarTextButton.state = .off
        } else {
            showText = UserDefaults.showToolbarText
            showToolbarTextButton.isEnabled = true
        }
        windowControllers.forEach({
            $0.changeToolbar(style: styleString, showText: showText )
        })
        UserDefaults.toolbarStyle = sender.identifier!.rawValue
    }
    
    @IBAction func didClickShowText(_ sender: NSButton) {
        let curStyle = UserDefaults.toolbarStyle
        var newState: Bool
        if sender.state == .on {
            newState = true
        } else {
            newState = false
        }
        windowControllers.forEach({ $0.changeToolbar(style: curStyle, showText: newState) })
        UserDefaults.showToolbarText = newState
    }
}

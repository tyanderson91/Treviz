//
//  AppDelegate.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
// Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

import Cocoa
import Yams

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var application: NSApplication!
    var prefsWC: PreferencesWindowController?
    var prefsVC: PreferencesViewController?
    func applicationWillFinishLaunching(_ notification: Notification) {
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let colormapDecoder = Yams.YAMLDecoder(encoding: .utf8)
        do {
            let cmapFile = Bundle.main.path(forResource: "colormaps", ofType: "yaml") ?? ""
            let cmapData = try String(contentsOfFile: cmapFile, encoding: .utf8)
            let cmaps = try colormapDecoder.decode(Array<ColorMap>.self, from: cmapData, userInfo: [:])
            ColorMap.allMaps = cmaps
        } catch {}
        setDefaults()
        
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func openPreferences(sender: Any){
        if prefsWC == nil {
            let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
            prefsWC = storyboard.instantiateController(identifier: "preferencesWindowController")/* { aDecoder in
                let pwc = PreferencesWindowController.init(coder: aDecoder)
                pwc?.appDelegate = self
                //(pwc?.contentViewController as? PreferencesViewController)?.appDelegate = self
                return pwc
            }*/
            
            /*
            prefsVC = storyboard.instantiateController(identifier: "preferencesViewController") { aDecoder in
                let pvc = PreferencesViewController.init(coder: aDecoder)
                pvc?.appDelegate = self
                return pvc
            }
            prefsWC?.contentViewController = prefsVC*/
            prefsWC?.appDelegate = self
            (prefsWC?.contentViewController as? PreferencesViewController)?.appDelegate = self
            prefsWC?.parentItem = sender as? NSMenuItem
        }
        prefsWC?.showWindow(sender)
    }
    
}

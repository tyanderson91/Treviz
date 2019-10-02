//
//  AppDelegate.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
// Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/"                 title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/"                 title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var application: NSApplication!
    
    var plotTypes : [PlotType]? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let thisWindow = application.mainWindow
        let windowController = thisWindow?.windowController
        if let doc = windowController?.document as? Analysis {
            doc.appDelegate = self
            loadPlotTypes(from: "PlotTypes")
        }
        
        NotificationCenter.default.post(name: .didLoadAppDelegate, object: nil)
        // Insert code here to initialize your application
        //let newAnalysis = Analysis()
        //print(newAnalysis.initialState)
        //newAnalysis.makeWindowControllers()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func loadPlotTypes(from plist: String){
        let plotFilePath = Bundle.main.path(forResource: plist, ofType: "plist")
        if (plotFilePath != nil) {
            let listOfPlots = PlotType.loadPlotTypes(filename: plotFilePath!)
            if listOfPlots.count > 0 {//If the initialization did not return an empty array
                self.plotTypes = listOfPlots
            } else {self.plotTypes = nil}
        }
        else {
            self.plotTypes = nil
        }
    }
    
}


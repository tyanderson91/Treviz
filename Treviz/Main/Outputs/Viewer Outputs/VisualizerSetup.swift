//
//  VisualizerSetup.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/2/22.
//  Copyright © 2022 Tyler Anderson. All rights reserved.
//

import Cocoa

class VisualizerSetupViewController: TZViewController {
    var tabViewController: DynamicTabViewController!
    var visualizerVC: VisualizerViewController!
    var tabView: DynamicTabHeaderViewController!
    var sidebarVC: SidebarTabViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initVC() {
        let sb = NSStoryboard(name: "Outputs", bundle: nil)
        visualizerVC = sb.instantiateController(withIdentifier: "visualizerOutput") as? VisualizerViewController
        visualizerVC.analysis = self.analysis
        visualizerVC.title = "Viz"
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let hasVC = tabViewController.switchToView(title: "Viz")
        if !hasVC {
            initVC()
            tabViewController.addViewController(controller: visualizerVC)
            tabView = tabViewController.tabHeaderItem(named: "Viz")
            tabView.teardownAction = {
                self.visualizerVC.controlsVC.pausePlayback()
                self.visualizerVC = nil
            } // TODO: Make this delete the whole view
        }
    }
}

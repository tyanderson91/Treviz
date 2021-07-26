//
//  PlotViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 11/2/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import SpriteKit
import SceneKit

/**
 Subclass of SpriteKit view to implement custom interactive behavior
 */
class TZSKView: SKView {
    var tzscene: TZScene? { return scene as? TZScene }
    
    override func keyDown(with event: NSEvent) {
        guard tzscene != nil else { return }
        let key = event.keyCode
        if key == 49 { // space
            if let cont = tzscene!.playbackController {
                cont.playPauseButtonToggled(self)
            }
        }
    }
    
    /**Changes the scene background when the OS changes from dark mode to light mode*/
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        let dmode = self.effectiveAppearance.name
        if dmode.rawValue == "NSAppearanceNameDarkAqua" {
            tzscene?.backgroundScene?.changeMode(darkMode: true)
        } else if dmode.rawValue == "NSAppearanceNameAqua" {
            tzscene?.backgroundScene?.changeMode(darkMode: false)
        }
    }
}

/**
 This controller presents the view that shows 2d and 3d visualizations via SpriteKit and SceneKit. It implements the methods in the TZVizualizer protocol to serve as the main output for trajectory visualization from an analysis
 */
class VisualizerViewController: TZViewController, TZVizualizer, SKSceneDelegate {
    
    @IBOutlet weak var placeholderImageView: NSImageView!
    @IBOutlet weak var skView: TZSKView!
    //@IBOutlet weak var sceneView: SCNView!
    
    var trajectory: State!
    var curScene: TZScene!
    var controlsVC: TZPlaybackController!
    var dockControls = true
    
    var preferences = VisualizerPreferences()
    static var preferencesGetter: PlotPreferencesGetter? // Assigned to the current Application on startup, used as an interface to UserDefaults
    
    // Constraints to the playback controller, turned off and on to govern whether the controls are docked
    @IBOutlet weak var controlsFixedWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsEqualWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsBottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var scene2dBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        placeholderImageView?.image = NSImage(named: analysis.phases[0].physicsSettings.centralBodyParam.stringValue)
        analysis.visualViewer = self
        
        dockControls = UserDefaults.dockVisualizationController
        
        let sceneSize = skView.bounds.size
        curScene = TZScene(size: sceneSize)
        super.viewDidLoad()
        curScene.isPaused = true
        self.view.viewDidChangeEffectiveAppearance() // Sets the correct scene background
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let playbackVC = segue.destinationController as? TZPlaybackController {
            controlsVC = playbackVC
            curScene.playbackController = playbackVC
            playbackVC.scene = curScene
        }
    }

    /**
     This function choses which type of view to present in the visualizer
     - parameter iview: index of view to show. 1 is a placeholder image, 2 is spritekit view (2d), and 3 is scenekit view (3d)
     */
    func toggleView(_ iview: Int){
        let curViews: [NSView] = [placeholderImageView, skView]//, sceneView]
        for i in 0...curViews.count-1 {
            if i == iview { curViews[i].isHidden = false }
            else { curViews[i].isHidden = true}
        }
    }
    
    /**
     Called by the Analysis when the run is completed. Draws from the output trade group(s) or run(s), depending on the type of analysis.
     */
    func loadTrajectoryData() {
        guard UserDefaults.showVisualization else { return }
        if let prefGetter = VisualizerViewController.preferencesGetter {
            preferences = prefGetter.getPreferences()
            curScene.preferences = preferences
        }
        
        // 2D SpriteKit view
        skView.presentScene(curScene)
        var groups: [RunGroup]
        if analysis.tradeGroups.count > 0 {
            groups = analysis.tradeGroups
        } else {
            var rg = RunGroup(name: "TempGroup")
            rg.runs = analysis.runs
            groups = [rg]
        }
        curScene.loadData(groups: groups)
        
        skView.viewDidChangeEffectiveAppearance()
        toggleView(1) // Switch to SpriteKit view
        controlsVC.view.isHidden = false
    }
    
    func resizeView(){
        if !skView.isHidden {
            (skView.scene as? TZScene)?.resizeScene()
        }
    }
}

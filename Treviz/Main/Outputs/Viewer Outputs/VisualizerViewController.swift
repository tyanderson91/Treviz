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

class VisualizerViewController: TZViewController, TZVizualizer, SKSceneDelegate {
    @IBOutlet weak var placeholderImageView: NSImageView!
    @IBOutlet weak var skView: SKView!
    //@IBOutlet weak var sceneView: SCNView!
    
    var trajectory: State!
    var curScene: TZScene!
    var controlsVC: TZPlaybackController!
    
    override func viewDidLoad() {
        //view.wantsLayer = true
        //view.layer?.backgroundColor = NSColor.black.cgColor
        placeholderImageView?.image = NSImage(named: analysis.phases[0].physicsSettings.centralBodyParam.stringValue)
        analysis.visualViewer = self
        
        toggleView(1)
        
        let sceneSize = skView.bounds.size
        curScene = TZScene(size: sceneSize)
        super.viewDidLoad()
        curScene.isPaused = true
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let id = segue.identifier
        if let playbackVC = segue.destinationController as? TZPlaybackController {
            controlsVC = playbackVC
            curScene.playbackController = playbackVC
            playbackVC.scene = curScene
        }
    }

    func toggleView(_ iview: Int){
        
        let curViews: [NSView] = [placeholderImageView, skView]//, sceneView]
        for i in 0...curViews.count-1 {
            if i == iview { curViews[i].isHidden = false }
            else { curViews[i].isHidden = true}
        }
    }
    
    func loadTrajectories(trajectories: [State]) {
        guard UserDefaults.showVisualization else { return }
        // 2D SpriteKit view
        toggleView(1)
        skView.presentScene(curScene)
        curScene.loadData(data: trajectories)
        
        curScene.runAll()
        curScene.playbackController.continuePlayback()
    }
}

class TZPlaybackController: NSViewController, VisualizerPlaybackController {
    var scene: TZScene!
    var speedOptions: [CGFloat] = [0.1, 0.2, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    var curSpeedOption: Int = 3
    var maxTime: VarValue = 1.0
    var shouldRepeat: Bool = false
    
    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var slowDownButton: NSButton!
    @IBOutlet weak var speedUpButton: NSButton!
    @IBOutlet weak var curSpeedLabel: NSTextField!
    @IBOutlet weak var scrubber: NSSlider!
    @IBOutlet weak var setRepeatButton: NSButton!
    let speedFormatter = NumberFormatter()
    @IBOutlet weak var goBackButton: NSButton!
    @IBOutlet weak var goForwardButton: NSButton!
    @IBOutlet weak var goToBeginningButton: NSButton!
    @IBOutlet weak var goToEndButton: NSButton!
    @IBOutlet weak var shouldDockButton: NSButton!
    
    override func viewDidLoad() {
        box.fillColor = NSColor(deviceWhite: 1.0, alpha: 0.5)
        playPauseButton.state = .off
        super.viewDidLoad()
        
        let boxTrackingArea = NSTrackingArea(rect: box.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        view.addTrackingArea(boxTrackingArea)
        setSpeedLabel()
        shouldRepeat = setRepeatButton.state == .on ? true : false
    }

    
    override func mouseEntered(with event: NSEvent) {
        box.animator().isHidden = false
    }
    override func mouseExited(with event: NSEvent) {
        box.animator().isHidden = true
    }
 
    func setSpeedLabel(){
        if playbackSpeed > 10 {
            speedFormatter.format = "0X"
        } else if playbackSpeed >= 0.1 {
            speedFormatter.format = "0.0X"
        } else {
            speedFormatter.format = "0.00X"
        }
        if curSpeedOption >= 10 || curSpeedOption < -1 {
            speedFormatter.format = "0E0X"
            speedFormatter.numberStyle = .scientific
        } else {
            speedFormatter.numberStyle = .none
        }

        curSpeedLabel.stringValue = speedFormatter.string(from: NSNumber(cgFloat: playbackSpeed)) ?? "UNKNOWN"
    }
    
    @IBAction func didPressPlayPause(_ sender: NSControl) {
        /*if scene.isComplete {
            continuePlayback()
            scene.runAll()
        }  else */if scene.isPaused {
            continuePlayback()
        } else {
            pausePlayback()
        }
    }
    
    func continuePlayback(){
        scene.isPaused = false
        playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
    }
    func pausePlayback(){
        scene.isPaused = true
        playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
    }
    
    @IBAction func didChangeSpeed(_ sender: NSControl) {
        if sender.identifier?.rawValue == "slowDownButton" { curSpeedOption -= 1 }
        else if sender.identifier?.rawValue == "speedUpButton" { curSpeedOption += 1 }
        scene.speed = playbackSpeed
        setSpeedLabel()
    }
    
    @IBAction func didPressRepeat(_ sender: Any) {
        shouldRepeat = setRepeatButton.state == .on ? true : false
    }
    
    @IBAction func didChangePlaybackPosition(_ sender: Any) {
    }
    
}

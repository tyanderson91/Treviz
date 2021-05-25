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
    static let spriteHeight: CGFloat = 20.0
    @IBOutlet weak var placeholderImageView: NSImageView!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var sceneView: SCNView!
    
    var usableRect: CGRect!
    let screenMargin: CGFloat = 15
    
    var trajectory: State!
    
    var curScene: SKScene!
    var actions: [SKAction] = []
    var vehicle: SKSpriteNode!
    let speedOptions: [CGFloat] = [0.1, 0.2, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    var curSpeedOption: Int = 3
    var timescale: CGFloat {
        if curSpeedOption < speedOptions.count && curSpeedOption >= 0 {
            return speedOptions[curSpeedOption]
        } else if curSpeedOption >= speedOptions.count {
            let exp = Double(curSpeedOption-speedOptions.count+2)
            return CGFloat(10**exp)
        } else if curSpeedOption < 0 {
            let exp = Double(curSpeedOption-1)
            return CGFloat(10**exp)
        } else {
            return 1.0
        }
    }
    
    var currentTime: Double = 0.0
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var controlsBoxView: NSView!
    var boxTrackingArea: NSTrackingArea!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var fastForwardButton: NSButton!
    @IBOutlet weak var slowDownButton: NSButton!
    @IBOutlet weak var currentSpeedLabel: NSTextField!
    @IBOutlet weak var scrubber: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        controlsBox.fillColor = NSColor(deviceWhite: 1.0, alpha: 0.3)
        controlsBox.borderWidth = 0.0
        controlsBox.cornerRadius = 10.0

        placeholderImageView.image = NSImage(named: analysis.phases[0].physicsSettings.centralBodyParam.stringValue)
        analysis.visualViewer = self
        
        setSpeedLabel()

        let boxTrackingArea = NSTrackingArea(rect: controlsBoxView.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited], owner: self, userInfo: nil)
        view.addTrackingArea(boxTrackingArea)
        mouseExited(with: NSEvent())
    }

    func setSpeedLabel(){
        currentSpeedLabel.stringValue = "\(timescale)x"
    }
    
    func toggleView(_ iview: Int){
        let curViews: [NSView] = [placeholderImageView, skView, sceneView]
        for i in 0...curViews.count-1 {
            if i == iview { curViews[i].isHidden = false }
            else { curViews[i].isHidden = true}
        }
        if iview == 1 { // 2D scenekit
            if boxTrackingArea == nil {
                let rect = controlsBoxView.bounds
                boxTrackingArea = NSTrackingArea(rect: controlsBoxView.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
                controlsBox.addTrackingArea(boxTrackingArea)
            }
        }
    }
    func loadVisual(trajectory: State) {
        guard UserDefaults.showVisualization else { return }
        
        // 2D SpriteKit view
        toggleView(1)
        let sceneSize = skView.bounds.size
        usableRect = skView.bounds.insetBy(dx: screenMargin, dy: screenMargin)
        
        curScene = SKScene(size: sceneSize)
        curScene.anchorPoint = CGPoint(x: usableRect.minX/skView.bounds.height, y: usableRect.minY/skView.bounds.height)
        vehicle = SKSpriteNode(imageNamed: "Ship_top")
        let aspectRatio = vehicle.size.width/vehicle.size.height
        vehicle.scale(to: CGSize(width: aspectRatio*VisualizerViewController.spriteHeight, height: VisualizerViewController.spriteHeight))
        curScene.addChild(vehicle)
        curScene.scaleMode = .resizeFill
        skView.presentScene(curScene)
        self.trajectory = trajectory
        
        scrubber.maxValue = Double(trajectory["t"]!.value.count-1)
        scrubber.minValue = 0.0
    
    }
    
    func viewDidResize() {
        usableRect = skView.bounds.insetBy(dx: screenMargin, dy: screenMargin)
    }
    
    override func mouseEntered(with event: NSEvent) {
        //let fadeAnimator = NSAnimator
        controlsBoxView.animator().isHidden = false
        controlsBox.animator().isTransparent = false
    }
    override func mouseExited(with event: NSEvent) {
        controlsBox.animator().isTransparent = true
        controlsBoxView.animator().isHidden = true
    }
    @IBAction func playPauseClicked(_ sender: Any) {
        let box = controlsBoxView.bounds
        if sceneView.isPlaying {
            curScene.isPaused = !curScene.isPaused
        } else {
            runAnimation()
        }
    }
    @IBAction func didChangeSpeed(_ sender: NSButton) {
        if sender.identifier?.rawValue == "slowDownButton" { curSpeedOption -= 1 }
        else if sender.identifier?.rawValue == "speedUpButton" { curSpeedOption += 1 }
        setSpeedLabel()
        actions.forEach({$0.speed = timescale})
    }
    @IBAction func didChangePosition(_ sender: Any) {
    }
    
    
    func runAnimation(){
        viewDidResize()
        vehicle.position = CGPoint(x: 0.0, y: 0.0)
        actions = []

        let times = trajectory["t"]!
        let x: Variable = trajectory["x"]!
        let y: Variable = trajectory["y"]!
        
        let minX = x.value.min()!
        let minY = y.value.min()!
        let xrange = x.value.max()! - minX
        let yrange = y.value.max()! - minY
        let xscale = usableRect.width/CGFloat(xrange)
        let yscale = usableRect.height/CGFloat(yrange)
        let scale = CGFloat(min(xscale,yscale))
        let xOffset = CGFloat(minX)
        let yOffset = CGFloat(minY)
        
        let dx = trajectory["dx"]!
        let dy = trajectory["dy"]!
        for idx in 0...(times.value.count)-2 {
            let dt = (times[idx+1]!-times[idx]!)
            let x1 = CGFloat(x[idx]!)
            let y1 = CGFloat(y[idx]!)
            let dx1 = CGFloat(dx[idx]!)
            let dy1 = CGFloat(dy[idx]!)
            let rotation_angle = atan2(dy1, dx1)
            let newPoint = CGPoint(x: (x1-xOffset)*scale, y: (y1-yOffset)*scale)
            
            let rot = SKAction.rotate(toAngle: rotation_angle, duration: dt)
            rot.speed = timescale
            let mov = SKAction.move(to: newPoint, duration: dt)
            mov.speed = timescale
            let act = SKAction.group([rot, mov])
            act.speed = timescale
            
            actions.append(act)
        }
        sceneView.isPlaying = true
        curScene.isPaused = false
        vehicle.run(SKAction.sequence(actions), completion: {self.sceneView.isPlaying = false})
        //curScene.run(SKAction.sequence(actions), completion: {self.sceneView.isPlaying = false})
    }
    
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
    }
}

class TwoDSceneView: SKView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.addRect(CGRect(x: 0, y: 0, width: dirtyRect.width, height: 10.0))
        context.setFillColor(CGColor.green)
        context.drawPath(using: .fill)
    }
}

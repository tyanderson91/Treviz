//
//  PlaybackController.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/9/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import SpriteKit


enum PlaybackState {
    case beginning, running, end, paused, scrubbing
}
protocol VisualizerPlaybackController {
    var scene: TZScene! { get set }
    var speedOptions: [CGFloat] { get }
    var curSpeedOption: Int { get set }
    var playbackSpeed: CGFloat { get }
    var shouldRepeat: Bool { get set }
    var state: PlaybackState { get set }
    
    func didPressPlayPause(_ sender: Any)
    func continuePlayback()
    func pausePlayback()
    func reset()
    func updatePlaybackPosition(to time: TimeInterval)
}
extension VisualizerPlaybackController {
    var playbackSpeed: CGFloat {
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
}

class PlaybackScrubber: NSSlider {
    var controller: TZPlaybackController!
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        startedScrubbing()
    }
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        startedScrubbing()
        return super.draggingEntered(sender)
    }
    override func mouseDragged(with event: NSEvent) {
        //super.mouseDragged(with: event)
        startedScrubbing()
    }
    func startedScrubbing(){
        let newTime = self.doubleValue
        controller.elapsedTime = newTime
        if let scene = controller.scene {
            scene.stop()
            scene.isPaused = false
            scene.go(to: newTime)
            controller._didChangePosition = true
            controller.playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
        }
    }
}

class TZPlaybackController: NSViewController, VisualizerPlaybackController {
    var scene: TZScene!
    var speedOptions: [CGFloat] = [0.1, 0.2, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    var curSpeedOption: Int = 3
    var maxTime: TimeInterval = 0
    var minTime: TimeInterval = 0
    var shouldRepeat: Bool = false
    
    var startTime: TimeInterval = 0.0
    var elapsedTime: TimeInterval = 0.0 {
        didSet {
            let number = NSNumber(value: elapsedTime)
            currentTimeTextField.stringValue = currentTimeNumberFormatter.string(from: number)!
        }
    }
    var t1: TimeInterval = 0.0
    var _didPause = true
    var _didChangePosition = false
    var _shouldPause = false
    var _shouldEnd = false
    var _didEnd = false
    var _endCounter = 0
    var state: PlaybackState = .beginning
    
    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var slowDownButton: NSButton!
    @IBOutlet weak var speedUpButton: NSButton!
    @IBOutlet weak var curSpeedLabel: NSTextField!
    @IBOutlet weak var scrubber: PlaybackScrubber!
    @IBOutlet weak var setRepeatButton: NSButton!
    let speedFormatter = NumberFormatter()
    @IBOutlet weak var goBackButton: NSButton!
    @IBOutlet weak var goForwardButton: NSButton!
    @IBOutlet weak var goToBeginningButton: NSButton!
    @IBOutlet weak var goToEndButton: NSButton!
    @IBOutlet weak var shouldDockButton: NSButton!
    @IBOutlet weak var currentTimeTextField: NSTextField!
    @IBOutlet var currentTimeNumberFormatter: NumberFormatter!
    
    override func viewDidLoad() {
        box.fillColor = NSColor(deviceWhite: 1.0, alpha: 0.5)
        playPauseButton.state = .off
        super.viewDidLoad()
        
        let boxTrackingArea = NSTrackingArea(rect: box.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        view.addTrackingArea(boxTrackingArea)
        setSpeedLabel()
        shouldRepeat = setRepeatButton.state == .on ? true : false
        
        scrubber.sendAction(on: .leftMouseDragged)
        scrubber.target = self
        scrubber.action = #selector(didChangePlaybackPosition(_:))
        currentTimeTextField.isBezeled = false
        
        scrubber.controller = self
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
    
    @IBAction func didPressPlayPause(_ sender: Any) {
        if state == .beginning || state == .end {
            scene.runAll()
        } else if _didChangePosition {
            scene.run(at: elapsedTime)
            _didChangePosition = false
            continuePlayback()
        } else if scene.isPaused {
            continuePlayback()
        } else {
            pausePlayback()
        }
        if !(sender is NSButton) {
            playPauseButton.state = ( playPauseButton.state == .on ? .off  : .on )
        }
    }
    
    func continuePlayback(){
        _shouldPause = false
        scene.isPaused = false
        state = .running
        playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
    }
    func pausePlayback(){
        _shouldPause = true
        state = .paused
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
    
    @IBAction func didChangePlaybackPosition(_ sender: NSSlider) {
        scene.isPaused = false
        let newTime = sender.doubleValue
        state = .scrubbing
        elapsedTime = newTime
        scene.go(to: newTime)
    }
    
    func reset(){
        minTime = scene.minTime
        maxTime = scene.maxTime
        startTime = 0
        elapsedTime = minTime
        currentTimeNumberFormatter.format = "0.0s"
        
        scrubber.doubleValue = minTime
        scrubber.maxValue = maxTime
        scrubber.minValue = minTime

        state = .beginning
        scene.isPaused = true
        playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
    }
    
    func updatePlaybackPosition(to time: TimeInterval){
        if t1 == 0 { // First cycle, set the initial time
            scrubber.doubleValue = minTime
            elapsedTime = minTime
        } else if _didPause {
            _didPause = false
        } else if _didChangePosition {
        } else {
            let dt = time - t1
            elapsedTime += dt*Double(scene.speed)
            scrubber.doubleValue = elapsedTime
        }
    
        t1 = time
        if _shouldPause {
            _shouldPause = false
            scene.isPaused = true
            _didPause = true
        }
        
        if elapsedTime >= maxTime && state == .running {
            _shouldEnd = true
            _endCounter += 1
        }
        
        //if _endCounter > 3 { cleanup() }
        if _shouldEnd {
            cleanup()
        }
    }
    
    func cleanup(){
        _shouldEnd = false
        state = .end
        _endCounter = 0
        scene.isPaused = true
        t1 = 0
        playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
    }
    
    @IBAction func didGoToEnd(_ sender: Any) {
        scene.isPaused = false
        state = .running
        scene.stop()
        scene.run(.wait(forDuration: 0.1)) { self.elapsedTime = self.maxTime}
        scene.go(to: maxTime)
        //elapsedTime = maxTime
        //_shouldEnd = true
    }
    
    @IBAction func didGoToBeginning(_ sender: Any) {
        if state == .running {
            reset()
            scene.runAll()
        } else {
            reset()
        }
    }
    
    @IBAction func didShiftTime(_ sender: Any) {
        var timeShift: TimeInterval
        if let button = sender as? NSButton {
            switch button.identifier?.rawValue {
            case "back10Button":
                timeShift = -1.0
            case "fwd10Button":
                timeShift = 1.0
            default:
                timeShift = 0.0
            }
        } else {
            timeShift = 0.0
        }
        let newTime = elapsedTime + timeShift
        if newTime < minTime {
            elapsedTime = minTime
            state = .beginning
        } else if newTime > maxTime {
            elapsedTime = maxTime
            state = .end
            _shouldEnd = true
        } else {
            elapsedTime = newTime
        }
        
        scene.stop()
        scene.isPaused = false
        scene.go(to: elapsedTime)
        if state == .running {
            scene.run(at: elapsedTime)
        } else if state == .paused {
            scene.run(SKAction.wait(forDuration: 0.1)) {
                self._didPause = true
                self._didChangePosition = true
            }
        }
        state = .scrubbing
        scrubber.doubleValue = elapsedTime
    }
    
}

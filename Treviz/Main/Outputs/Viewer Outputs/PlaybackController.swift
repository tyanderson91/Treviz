//
//  PlaybackController.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/9/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//
import Foundation
import SpriteKit

class TZPlaybackController: NSViewController, VisualizerPlaybackController {
    var scene: TZScene!
    var speedOptions: [CGFloat] = [0.1, 0.2, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    var curSpeedOption: Int = 3
    var maxTime: TimeInterval = 1
    var minTime: TimeInterval = 0
    var shouldRepeat: Bool = false
    
    var elapsedTime: TimeInterval = 0.0 {
        didSet {
            let number = NSNumber(value: elapsedTime)
            currentTimeTextField.stringValue = currentTimeNumberFormatter.string(from: number)!
        }
    }
    var t1: TimeInterval = 0.0
    var _resetTimeBase = false
    var _shouldPause = false
    var _didEnd = false
    var state: PlaybackState = .beginning
    var _mouseInside: Bool = false
    var _shouldPersist: Bool = false {
        didSet {
            showHideBox()
        }
    }
    
    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var slowDownButton: NSButton!
    @IBOutlet weak var speedUpButton: NSButton!
    @IBOutlet weak var curSpeedLabel: NSTextField!
    @IBOutlet weak var setRepeatButton: NSButton!
    let speedFormatter = NumberFormatter()
    @IBOutlet weak var goBackButton: NSButton!
    @IBOutlet weak var goForwardButton: NSButton!
    @IBOutlet weak var goToBeginningButton: NSButton!
    @IBOutlet weak var goToEndButton: NSButton!
    @IBOutlet weak var shouldDockButton: NSButton!
    @IBOutlet weak var currentTimeTextField: NSTextField!
    @IBOutlet var currentTimeNumberFormatter: NumberFormatter!
    var scrubberController: CustomPlaybackScrubberController!
    var visualizerController: VisualizerViewController! { return parent as? VisualizerViewController }
    
    // Constraints
    @IBOutlet weak var topStackSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomStackSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomScrubberSpaceConstraint: NSLayoutConstraint!
    private let dockedMargin: CGFloat = 2
    private let cornerRadius: CGFloat = 8
    private let smallMargin: CGFloat = 5
    private let largin: CGFloat = 7
    private let floatingOffset: CGFloat = 10
    private let boxLineWidth: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        box.viewDidChangeEffectiveAppearance()
        let boxTrackingArea = NSTrackingArea(rect: box.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        view.addTrackingArea(boxTrackingArea)
        setSpeedLabel()
        shouldRepeat = setRepeatButton.state == .on ? true : false
        currentTimeTextField.isBezeled = false
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "scrubberSegue", let vc = segue.destinationController as? CustomPlaybackScrubberController {
            vc.playbackController = self
            scrubberController = vc
        }
    }

    override func mouseEntered(with event: NSEvent) {
        _mouseInside = true
        showHideBox()
    }
    override func mouseExited(with event: NSEvent) {
        _mouseInside = false
        if !_shouldPersist && visualizerController.floatControls {
            showHideBox()
        }
    }
    
    // MARK: Controls
    @IBAction func didPressPlayPause(_ sender: Any) {
        switch state {
        case .beginning:
            state = .running
            _shouldPause = false
            scene.start()
            setPlayPauseButton(paused: false)
        case .end:
            goToBeginning()
            state = .running
            scene.start()
            setPlayPauseButton(paused: false)
        case .running:
            self.pausePlayback()
        case .paused:
            self.continuePlayback()
        default:
            return
        }
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
    
    func didChangePosition(){
        scene.stop()
        scrubberController.curValue = elapsedTime
        switch self.state {
        case .running:
            scene.run(at: elapsedTime)
            self.continuePlayback()
        case .paused:
            scene.run(at: elapsedTime)
            _resetTimeBase = true
            self.pausePlayback()
        default:
            return
        }
    }
    
    @IBAction func didGoToEnd(_ sender: Any) {
        shouldRepeat = false
        setRepeatButton.state = .off
        goToEnd()
    }
    
    @IBAction func didGoToBeginning(_ sender: Any) {
        goToBeginning()
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
        goToTime(time: newTime)
        didChangePosition()
    }
    
    @IBAction func didSelectNewTime(_ sender: NSTextField) {
        let stringVal = sender.stringValue
        let dubVal = sender.doubleValue
        
        if let newTime = TimeInterval.init(stringVal) {
            goToTime(time: newTime)
        }
    }
    
    @IBAction func didClickDock(_ sender: Any) {
        guard let v = visualizerController else { return }
        v.floatControls = !v.floatControls
        if v.floatControls {
            box.isHidden = true
            v.controlsEqualWidthConstraint.priority = .defaultLow
            v.controlsFixedWidthConstraint.priority = .defaultHigh
            v.controlsBottomOffsetConstraint.constant = floatingOffset
            v.controlsTopConstraint.priority = .defaultLow
            v.scene2dBottomConstraint.priority = .defaultHigh
            bottomStackSpaceConstraint.constant = smallMargin
            topStackSpaceConstraint.constant = largin
            bottomScrubberSpaceConstraint.constant = smallMargin
            box.cornerRadius = cornerRadius
            box.borderWidth = boxLineWidth
            shouldDockButton.image = NSImage(systemSymbolName: "arrow.down.backward.square", accessibilityDescription: "")
            view.needsLayout = true
        } else {
            v.controlsFixedWidthConstraint.priority = .defaultLow
            v.controlsEqualWidthConstraint.priority = .defaultHigh
            v.controlsBottomOffsetConstraint.constant = 0
            v.scene2dBottomConstraint.priority = .defaultLow
            v.controlsTopConstraint.priority = .defaultHigh
            bottomStackSpaceConstraint.constant = dockedMargin
            topStackSpaceConstraint.constant = dockedMargin
            bottomScrubberSpaceConstraint.constant = dockedMargin
            box.cornerRadius = 0
            box.borderWidth = 0
            shouldDockButton.image = NSImage(systemSymbolName: "arrow.up.forward.square", accessibilityDescription: "")
            view.needsLayout = true
        }
    }
    
    // MARK: Visuals
    func showHideBox(){
        if _mouseInside || _shouldPersist {
            box.animator().isHidden = false
        } else {
            box.animator().isHidden = true
        }
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
    
    func setPlayPauseButton(paused: Bool){
        if paused {
            playPauseButton.state = .off
            playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
        } else {
            playPauseButton.state = .on
            playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
        }
    }
    
    /** This function is run on every loop of the scene animation. This controls the playback when the animation is in motion */
    func updatePlaybackPosition(to time: TimeInterval){
        if t1 == 0 { // First cycle, only set the initial time
        } else if _resetTimeBase {
            _resetTimeBase = false
        } else {
            let dt = time - t1
            elapsedTime += dt*Double(scene.speed)
            scrubberController.curValue = elapsedTime
        }
    
        t1 = time
        if _shouldPause {
            _shouldPause = false
            scene.isPaused = true
            _resetTimeBase = true
        }
        
        if elapsedTime >= maxTime && state == .running {
            cleanup()
        }
    }
    
    // MARK: Workhorse functions
    func continuePlayback(){
        _shouldPause = false
        scene.isPaused = false
        state = .running
        setPlayPauseButton(paused: false)
    }
    func pausePlayback(){
        _shouldPause = true
        state = .paused
        setPlayPauseButton(paused: true)
    }
    
    func startedScrubbing(){
        if state == .running {
            _shouldPause = true
        }
        state = .scrubbing
        scene.stop()
    }
    
    func goToTime(time newTime: TimeInterval) {
        if newTime < minTime {
            elapsedTime = minTime
            goToBeginning()
        } else if newTime >= maxTime {
            elapsedTime = maxTime
            if state == .scrubbing {
                scene.go(to: elapsedTime)
            } else {
                goToEnd()
            }
        } else {
            if state == .beginning || state == .end {
                state = .paused
                _resetTimeBase = true
            }
            elapsedTime = newTime
            scene.go(to: elapsedTime)
        }
        scrubberController.curValue = elapsedTime
    }
    
    func goToBeginning(){
        scene.go(to: minTime)
        switch state {
        case .running:
            scene.start()
        case .paused:
            scene.stop()
            state = .beginning
        case .end:
            state = .beginning
            reset()
        default:
            return // shouldn't happen
        }
        elapsedTime = minTime
        scrubberController.curValue = elapsedTime
    }
    func goToEnd(){
        scene.go(to: maxTime)
        elapsedTime = maxTime
        scrubberController.curValue = elapsedTime
        cleanup()
    }
    
    func reset(){
        
        minTime = scene.minTime
        maxTime = scene.maxTime
        t1 = 0
        elapsedTime = minTime
        currentTimeNumberFormatter.format = "0.0s"
        
        scrubberController.maxValue = maxTime
        scrubberController.minValue = minTime
        scrubberController.curValue = minTime

        state = .beginning
        scene.isPaused = true
        setPlayPauseButton(paused: true)
    }
    
    func cleanup(){
        state = .end
        scene.isPaused = true
        scene.stop()
        if shouldRepeat {
            state = .running
            goToBeginning()
        } else {
            setPlayPauseButton(paused: true)
        }
    }
}

class TZPlaybackControllerView: NSView {
    override var mouseDownCanMoveWindow: Bool { return false }
}

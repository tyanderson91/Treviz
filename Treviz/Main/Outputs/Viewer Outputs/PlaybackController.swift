//
//  PlaybackController.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/9/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//
import Foundation
import SpriteKit

/**
 The PlaybackController is a view controller that also serves as the main way to govern playback of a visualization. This class controls the presentation of the playback controller (except for the docked state, which is handled by parent the VizualizerViewController) and the callbacks associated with the various controls
 */
class TZPlaybackController: NSViewController, VisualizerPlaybackController {
    var scene: TZScene!
    /// Default options for playback speed multipliers
    var speedOptions: [CGFloat] = [0.1, 0.2, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    var curSpeedOption: Int = 3
    var maxTime: TimeInterval = 1
    var minTime: TimeInterval = 0
    var shouldRepeat: Bool = false
    
    /// Current time being simulated
    var elapsedTime: TimeInterval = 0.0 {
        didSet {
            let number = NSNumber(value: elapsedTime)
            currentTimeTextField.stringValue = currentTimeNumberFormatter.string(from: number)!
        }
    }
    /// t0 gets set to the previous system time during scene updates. This is required to calculate the length of the scene motion during scene updates due to the way SpriteKit handles update calls
    var t0: TimeInterval = 0.0
    /// Tells the scene to pause on the next scene update. Required to keep the scrubber and the scene synchronized during pause/resume cycles
    var _shouldPause = false
    /// Current state of playback. Options are beginning, end, running, paused, and scrubbing
    var state: PlaybackState = .beginning
    /// Required to allow the scrubber to persist when held down even if the mouse exits the playback area
    var _mouseInside: Bool = false
    /// Required to change whether the controller should remain visible
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
    /// Custom VC that renders and governs display and feedback from the scrubber
    var scrubberController: CustomPlaybackScrubberController!
    var visualizerController: VisualizerViewController! { return parent as? VisualizerViewController }
    
    // Constraints
    @IBOutlet weak var topStackSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomStackSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomScrubberSpaceConstraint: NSLayoutConstraint!
    private let dockedMargin: CGFloat = 2
    private let cornerRadius: CGFloat = 8
    private let smallMargin: CGFloat = 5
    private let largin: CGFloat = 7 // large margin
    private let floatingOffset: CGFloat = 10
    private let boxLineWidth: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        box.viewDidChangeEffectiveAppearance()
        setControllerLocation()
        let boxTrackingArea = NSTrackingArea(rect: box.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        view.addTrackingArea(boxTrackingArea) // Used to show/hide playback controller box in floating mode
        setSpeedLabel()
        shouldRepeat = setRepeatButton.state == .on ? true : false
        currentTimeTextField.isBezeled = false
        
        speedUpButton.toolTip = "Speed Up"
        slowDownButton.toolTip = "Slow Down"
        playPauseButton.toolTip = "Play"
        goForwardButton.toolTip = "Skip Forward"
        goBackButton.toolTip = "Jump Backward"
        goToBeginningButton.toolTip = "Go to Beginning"
        goToEndButton.toolTip = "Go to End"
        setRepeatButton.toolTip = "Toggle Repeat"
        curSpeedLabel.toolTip = "Speed Multiplier"
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
        showHideBox()
    }
    
    // MARK: Controls
    /**
     Determines what the play/pause button should look like and what action it should take depending on the current playback state
     */
    @IBAction func playPauseButtonToggled(_ sender: Any) {
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
    
    @IBAction func speedChangeButtonClicked(_ sender: NSControl) {
        if sender.identifier?.rawValue == "slowDownButton" { curSpeedOption -= 1 }
        else if sender.identifier?.rawValue == "speedUpButton" { curSpeedOption += 1 }
        scene.speed = playbackSpeed // Automatically set by curSpeedOption
        setSpeedLabel()
    }
    
    @IBAction func repeatToggleClicked(_ sender: Any) {
        shouldRepeat = setRepeatButton.state == .on ? true : false
    }
    
    /**
     Called to reset the playback actions after jumping to a new playback position, either by scrubbing, jumping by a fixed time, or manually setting a new time
     */
    func didChangePosition(){
        scene.stop()
        scrubberController.curValue = elapsedTime
        switch self.state {
        case .running:
            scene.run(at: elapsedTime)
            self.continuePlayback()
        case .paused:
            scene.run(at: elapsedTime)
            t0 = 0
            self.pausePlayback()
        default:
            return
        }
    }
    
    @IBAction func endButtonClicked(_ sender: Any) {
        shouldRepeat = false
        setRepeatButton.state = .off
        goToEnd()
    }
    
    @IBAction func beginningButtonClicked(_ sender: Any) {
        goToBeginning()
    }
    
    @IBAction func timeShiftButtonClicked(_ sender: Any) { // TODO: Actually set to +- 10 seconds
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
    
    @IBAction func newTimeTextboxEntered(_ sender: NSTextField) {
        let dubVal = sender.doubleValue
        goToTime(time: dubVal)
        didChangePosition()
    }
    
    @IBAction func dockButtonClicked(_ sender: Any) {
        visualizerController.dockControls = !visualizerController.dockControls
        UserDefaults.dockVisualizationController = visualizerController.dockControls
        setControllerLocation()
    }
    
    // MARK: Visuals
    /**
     Docks/undocks the playback controller to the bottom of the visualization window
     */
    func setControllerLocation(){
        if !visualizerController.dockControls {
            box.isHidden = true
            visualizerController.controlsEqualWidthConstraint.priority = .defaultLow
            visualizerController.controlsFixedWidthConstraint.priority = .defaultHigh
            visualizerController.controlsBottomOffsetConstraint.constant = floatingOffset
            visualizerController.controlsTopConstraint.priority = .defaultLow
            visualizerController.scene2dBottomConstraint.priority = .defaultHigh
            bottomStackSpaceConstraint.constant = smallMargin
            topStackSpaceConstraint.constant = largin
            bottomScrubberSpaceConstraint.constant = smallMargin
            box.cornerRadius = cornerRadius
            box.borderWidth = boxLineWidth
            shouldDockButton.image = NSImage(systemSymbolName: "arrow.down.backward.square", accessibilityDescription: "")
            view.needsLayout = true
        } else {
            visualizerController.controlsFixedWidthConstraint.priority = .defaultLow
            visualizerController.controlsEqualWidthConstraint.priority = .defaultHigh
            visualizerController.controlsBottomOffsetConstraint.constant = 0
            visualizerController.scene2dBottomConstraint.priority = .defaultLow
            visualizerController.controlsTopConstraint.priority = .defaultHigh
            bottomStackSpaceConstraint.constant = dockedMargin
            topStackSpaceConstraint.constant = dockedMargin
            bottomScrubberSpaceConstraint.constant = dockedMargin
            box.cornerRadius = 0
            box.borderWidth = 0
            shouldDockButton.image = NSImage(systemSymbolName: "arrow.up.forward.square", accessibilityDescription: "")
            view.needsLayout = true
        }
    }
    
    func showHideBox(){
        if _mouseInside || _shouldPersist || visualizerController.dockControls {
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
            playPauseButton.toolTip = "Play"
        } else {
            playPauseButton.state = .on
            playPauseButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "")
            playPauseButton.toolTip = "Pause"
        }
    }
    
    /** This function is run on every loop of the scene animation. This controls the playback when the animation is in motion */
    func updatePlaybackPosition(to time: TimeInterval){
        if t0 == 0 { // First cycle, only set the initial time
        } else {
            let dt = time - t0
            elapsedTime += dt*Double(scene.speed)
            scrubberController.curValue = elapsedTime
        }
    
        // This block is used to pause the scene one cycle after the pause command is sent and re-start the scene one cycle after the unpause command is sent
        // Required because this function cannot run while the scene is actually paused, and we need to keep track of the current system time in order to accurately track the playback progress
        if _shouldPause {
            _shouldPause = false
            scene.isPaused = true
            t0 = 0
        } else {
            t0 = time
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
    
    // Controls changig the scene and the playback controls when a new time is set
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
                t0 = 0
            }
            elapsedTime = newTime
            scene.go(to: elapsedTime)
        }
        scrubberController.curValue = elapsedTime
    }
    
    func goToBeginning(){
        scene.stop()
        scene.go(to: minTime)
        switch state {
        case .running:
            scene.start()
        case .paused:
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
    
    /**
     Resets all playback variables to their original state
     */
    func reset(){
        minTime = scene.minTime
        maxTime = scene.maxTime
        t0 = 0
        elapsedTime = minTime
        currentTimeNumberFormatter.format = "0.0"
        
        scrubberController.maxValue = maxTime
        scrubberController.minValue = minTime
        scrubberController.curValue = minTime

        state = .beginning
        scene.isPaused = true
        setPlayPauseButton(paused: true)
    }
    
    /**Run when the playback has completed*/
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

/// Annoying override required to stop weird behaviour when docked
class TZPlaybackControllerView: NSView {
    override var mouseDownCanMoveWindow: Bool { return false }
}

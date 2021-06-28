//
//  PlaybackControllerHelpers.swift
//  Treviz
//
//  Created by Tyler Anderson on 6/27/21.
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

class CustomPlaybackScrubberController: NSViewController {
    var sview: CustomPlaybackScrubber { return view as! CustomPlaybackScrubber }
    var maxValue: TimeInterval = 13.0 { didSet { sview.maxValue = CGFloat(self.maxValue) }}
    var minValue: TimeInterval = 3.0 { didSet { sview.minValue = CGFloat(self.minValue) }}
    var curValue: TimeInterval = 0.0 { didSet {
        sview.curValue = CGFloat(self.curValue)
        sview.needsDisplay = true
    }}
    var savedState: PlaybackState = .beginning
    var playbackController: TZPlaybackController!
    var scene: TZScene { return playbackController.scene }
    //var sceneIsPaused = false
    
    override func viewDidLoad() {
    }
    override func viewDidLayout() {
        sview.startPoint = CGPoint(x: sview.lineWidth+sview.scrubberSize/2, y: sview.frame.height/2)
        sview.endPoint = CGPoint(x: sview.frame.width-2*sview.lineWidth-sview.scrubberSize/2, y: sview.frame.height/2)
        sview.lineLength = sview.endPoint.x - sview.startPoint.x
        
        let boxTrackingArea = NSTrackingArea(rect: sview.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
        sview.addTrackingArea(boxTrackingArea)
    }
    
    override func mouseDown(with event: NSEvent) {
        sview.showScrubber = true
        startedScrubbing()
        mouseDragged(with: event)
    }
    override func mouseDragged(with event: NSEvent) {
        playbackController._shouldPersist = true
        sview.hoverValue = nil
        curValue = lineValue(froms: event)
        playbackController.elapsedTime = curValue
        scene.go(to: curValue)
        sview.needsDisplay = true
    }
    override func mouseUp(with event: NSEvent) {
        playbackController._shouldPersist = false
        playbackController.state = savedState
        //scene.go(to: curValue)
        sview.showScrubber = false
        sview.needsDisplay = true
        if savedState == .running {
            scene.isPaused = false
            playbackController.scene.run(at: curValue)
            playbackController._didChangePosition = false
            playbackController.continuePlayback()
        }
    }
    override func mouseEntered(with event: NSEvent) {
        mouseMoved(with: event)
    }
    override func mouseExited(with event: NSEvent) {
        sview.hoverValue = nil
        sview.needsDisplay = true
    }
    override func mouseMoved(with event: NSEvent) {
        let dubVal = lineValue(froms: event)
        sview.hoverValue = CGFloat(dubVal)
        sview.needsDisplay = true
    }
    
    func lineValue(froms event: NSEvent)->TimeInterval {
        let loc = event.locationInWindow
        let relLoc = sview.convert(loc, from: nil)
        let dubVal = sview.posToValue(relLoc.x)
        if dubVal < minValue { return minValue }
        else if dubVal > maxValue { return maxValue }
        else { return dubVal }
    }
    
    func startedScrubbing(){
        savedState = playbackController.state
        playbackController.state = .scrubbing
        
        scene.stop()
        scene.isPaused = false
        scene.go(to: curValue)
        playbackController._didChangePosition = true
        playbackController.elapsedTime = curValue
        //playbackController.playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "")
    }
}
class CustomPlaybackScrubber: NSView {
    var curValue: CGFloat = 8.0
    var minValue: CGFloat = 3.0 { didSet { converterScale = (maxValue-minValue)/lineLength } }
    var maxValue: CGFloat = 13.0  { didSet { converterScale = (maxValue-minValue)/lineLength } }
    var hoverValue: CGFloat? = nil
    var showScrubber = false
    
    let scrubberSize: CGFloat = 6.0
    let lineWidth: CGFloat = 4.0
    let lineAlpha: CGFloat = 0.7
    
    var startPoint: CGPoint!
    var endPoint: CGPoint!
    var lineLength: CGFloat = 1 { didSet { converterScale = (maxValue-minValue)/lineLength } }
    var converterScale: CGFloat = 1

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func posToValue(_ pos: CGFloat)->TimeInterval {
        return TimeInterval((pos - startPoint.x)*converterScale + minValue)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let mid = dirtyRect.height/2
        let valuePos = lineLength*(curValue-minValue)/(maxValue-minValue) + startPoint.x
        let color = NSColor.controlAccentColor.withAlphaComponent(lineAlpha)
        let markerColor = color.blended(withFraction: 0.3, of: .black)!.withAlphaComponent(1.0).cgColor
        
        context.setStrokeColor(CGColor(gray: 0.3, alpha: lineAlpha))
        context.setLineCap(.round)
        context.setLineWidth(lineWidth)
        context.move(to: startPoint)
        context.addLine(to: CGPoint(x: startPoint.x+lineLength, y: mid))
        context.drawPath(using: .stroke)
        context.setStrokeColor(color.cgColor)
        context.addLines(between: [startPoint, CGPoint(x: valuePos, y: mid)])
        context.drawPath(using: .stroke)
        if showScrubber {
            let scrubberRect = CGRect(x: valuePos-scrubberSize, y: mid-scrubberSize, width: scrubberSize*2, height: scrubberSize*2)
            context.addEllipse(in: scrubberRect)
            context.setFillColor(markerColor)
            context.drawPath(using: .fill)
        }
        
        if hoverValue != nil {
            let hoverValuePos = lineLength*(hoverValue!-minValue)/(maxValue-minValue) + startPoint.x
            let hoverScrubberRect = CGRect(x: hoverValuePos-scrubberSize, y: mid-scrubberSize, width: scrubberSize*2, height: scrubberSize*2)
            context.addEllipse(in: hoverScrubberRect)
            context.setFillColor(markerColor.copy(alpha: 0.3)!)
            context.drawPath(using: .fill)
        }
    }
}

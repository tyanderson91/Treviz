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
    
    func playPauseButtonToggled(_ sender: Any)
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
    var boxTrackingArea: NSTrackingArea!
    
    override func viewDidLoad() {
    }
    override func viewDidLayout() {
        sview.startPoint = CGPoint(x: sview.lineWidth+sview.scrubberSize/2, y: sview.frame.height/2)
        sview.endPoint = CGPoint(x: sview.frame.width-2*sview.lineWidth-sview.scrubberSize/2, y: sview.frame.height/2)
        sview.lineLength = sview.endPoint.x - sview.startPoint.x
        
        boxTrackingArea = NSTrackingArea(rect: sview.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
        sview.addTrackingArea(boxTrackingArea)
    }
    
    override func mouseDown(with event: NSEvent) {
        sview.showScrubber = true
        savedState = playbackController.state
        playbackController.startedScrubbing()
        mouseDragged(with: event)
    }
    override func mouseDragged(with event: NSEvent) {
        playbackController._shouldPersist = true
        sview.hoverValue = nil
        curValue = lineValue(froms: event)
        playbackController.goToTime(time: curValue)
        sview.needsDisplay = true
    }
    override func mouseUp(with event: NSEvent) {
        playbackController._shouldPersist = false
        if savedState == .end || savedState == .beginning {
            playbackController.state = .paused
        } else {
             playbackController.state = savedState
        }
        playbackController.didChangePosition()
        sview.showScrubber = false
        if sview.mouseInside {
            mouseMoved(with: event)
        }
        sview.needsDisplay = true
    }
    override func mouseEntered(with event: NSEvent) {
        mouseMoved(with: event)
        sview.mouseInside = true
    }
    override func mouseExited(with event: NSEvent) {
        sview.hoverValue = nil
        sview.needsDisplay = true
        sview.mouseInside = false
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
}
class CustomPlaybackScrubber: NSView {
    var curValue: CGFloat = 8.0
    var minValue: CGFloat = 3.0 { didSet { converterScale = (maxValue-minValue)/lineLength } }
    var maxValue: CGFloat = 13.0  { didSet { converterScale = (maxValue-minValue)/lineLength } }
    var hoverValue: CGFloat? = nil
    var showScrubber = false
    var mouseInside = false
    
    let scrubberSize: CGFloat = 6.0
    let lineWidth: CGFloat = 4.0
    
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
        let color = NSColor.controlAccentColor
        let markerColor = color.blended(withFraction: 0.2, of: .black)!.cgColor
        let backgroundColor = NSColor.systemGray.cgColor
        
        let curPoint = CGPoint(x: valuePos, y: mid)
        context.setStrokeColor(backgroundColor)
        context.setLineCap(.round)
        context.setLineWidth(lineWidth)
        context.addLines(between: [curPoint, endPoint])
        context.drawPath(using: .stroke)
        
        context.setStrokeColor(color.cgColor)
        context.addLines(between: [startPoint, curPoint])
        context.drawPath(using: .stroke)
        
        func addDot(centerX: CGFloat, isOutline: Bool) {
            let centerY = mid
            let r = scrubberSize
            let t = lineWidth
            let R = r*4
            let scrubberRect = CGRect(x: centerX-r, y: centerY-r, width: r*2, height: r*2)
            
            if isOutline {
                context.addEllipse(in: scrubberRect)
                context.setFillColor(markerColor.copy(alpha: 0.6)!)
                context.drawPath(using: .fill)
            } else {
                let centerPoint = CGPoint(x: centerX, y: centerY)
                let th = asin((R+t/2)/(R+r))
                let pi = CGFloat(PI)

                let ctr1 = centerPoint.applying(.init(translationX: -cos(th)*(r+R), y: sin(th)*(r+R)))
                let ctr2 = centerPoint.applying(.init(translationX: cos(th)*(r+R), y: sin(th)*(r+R)))
                let ctr3 = centerPoint.applying(.init(translationX: cos(th)*(r+R), y: -sin(th)*(r+R)))
                let ctr4 = centerPoint.applying(.init(translationX: -cos(th)*(r+R), y: -sin(th)*(r+R)))
                
                if valuePos < endPoint.x - R + 1.5*r {
                    context.addArc(center: ctr2, radius: R, startAngle: 3*pi/2, endAngle: pi+th, clockwise: true)
                    context.addArc(center: ctr3, radius: R, startAngle: pi-th, endAngle: pi/2, clockwise: true)
                    context.closePath()
                    context.setFillColor(backgroundColor)
                    context.drawPath(using: .fill)
                }
                
                if valuePos > startPoint.x + R - 1.5*r{
                    context.addArc(center: ctr1, radius: R, startAngle: -pi/2, endAngle: -th, clockwise: false)
                    context.addArc(center: centerPoint, radius: r, startAngle: CGFloat(PI)/2+th, endAngle: -(CGFloat(PI)/2+th), clockwise: true)
                    context.addArc(center: ctr4, radius: R, startAngle: th, endAngle: pi/2, clockwise: false)
                    context.closePath()
                    context.setFillColor(color.cgColor)
                    context.drawPath(using: .fill)
                }
                context.addEllipse(in: scrubberRect)
                context.setFillColor(markerColor)
                context.drawPath(using: .fill)
            }
        }
        
        if showScrubber {
            addDot(centerX: valuePos, isOutline: false)
        }
        if hoverValue != nil {
            let hoverValuePos = lineLength*(hoverValue!-minValue)/(maxValue-minValue) + startPoint.x
            addDot(centerX: hoverValuePos, isOutline: true)
        }
    }
}

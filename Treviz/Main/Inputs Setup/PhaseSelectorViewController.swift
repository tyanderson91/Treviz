//
//  PhaseSelectorViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 8/18/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

struct PhaseSelector {
    let phase: TZPhase
    let lineBox: CGRect
    let node1Box: CGRect
    let node2Box: CGRect
}
class PhaseSelectorViewController: BaseViewController {
    var phases : [TZPhase] = [
        TZPhase(id: "default"),
        TZPhase(id: "phase2")
    ]
    var phaseSelectors: [PhaseSelector] = []
    @IBOutlet weak var phaseSelectorView: PhaseSelectorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phaseSelectorView.viewController = self
    }
    /*
    override func mouseDown(with event: NSEvent) {
        let phase1Selector = phaseSelectors[0]
        let lineTrackingBox = phase1Selector.lineBox
        let eventPoint = view.convert(event.locationInWindow, to: phaseSelectorView)
        if lineTrackingBox.contains(eventPoint) {
            phaseSelectorView.circleColor = NSColor.red
        }
    }*/
}

class PhaseSelectorView: NSView {
        
    var circleColor = NSColor.controlAccentColor //NSColor.gray
    let node1Radius : CGFloat = 7
    let node2Radius : CGFloat = 3.3
    let padding: CGFloat = 20
    let lineWidth: CGFloat = 2
    var viewController: PhaseSelectorViewController?
    var phases : [TZPhase] { return viewController?.phases ?? []}
    
    override func draw(_ dirtyRect: NSRect) {
        super .draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        //let border = CGMutablePath()
        //border.addLines(between: [CGPoint(x: 0, y: dirtyRect.height), CGPoint(x: dirtyRect.width, y: dirtyRect.height)])
        //context.addPath(border)
        //context.drawPath(using: .stroke)
        //context.setStrokeColor(NSColor.gray.cgColor)
        let x1 = padding
        let x2 = padding + (dirtyRect.width-2*padding)/2
        let x3 = dirtyRect.width - padding
        let y1 = dirtyRect.height / 2
        if phases.count > 0 {
            let phase1Selector = drawPhaseLine(context: context, x1: x1, x2: x2, y: y1, phase: phases[0], isInitial: true)
            let phase2Selector = drawPhaseLine(context: context, x1: x2, x2: x3, y: y1, phase: phases[1])
            viewController?.phaseSelectors = []
            viewController?.phaseSelectors.append(phase1Selector)
            viewController?.phaseSelectors.append(phase2Selector)
        }
    }
    
    func drawPhaseLine(context: CGContext, x1: CGFloat, x2: CGFloat, y: CGFloat, phase: TZPhase, isInitial: Bool=false) -> PhaseSelector {
        let node1 = CGMutablePath()
        context.setLineWidth(lineWidth)
        if isInitial {
            context.setFillColor(circleColor.cgColor)
            context.setStrokeColor(circleColor.cgColor)
        } else {
            context.setFillColor(NSColor.disabledControlTextColor.cgColor)
            context.setStrokeColor(NSColor.disabledControlTextColor.cgColor)
        }
        let node1Box = CGRect(x: x1 - node1Radius, y: y - node1Radius, width: 2*node1Radius, height: 2*node1Radius)
        drawInitialNode(context: context, radius: node1Radius, thickness: lineWidth, cutoutWidth: 2.5*lineWidth, center: CGPoint(x: x1, y: y), isInitial: isInitial)
        let node2 = CGMutablePath()
        let node2Origin = CGPoint(x: x2 - node2Radius, y: y-node2Radius)
        let node2Box = CGRect(origin: node2Origin, size: CGSize(width: node2Radius*2, height: node2Radius*2))
        node2.addEllipse(in: node2Box)
        
        let path = CGMutablePath()
        let pathStart = x1 + node1Radius - 0.1
        let pathEnd = x2 - node2Radius + 0.1
        path.addLines(between: [CGPoint(x: pathStart, y: y), CGPoint(x: pathEnd, y: y)])
        
        context.addPath(path)
        context.drawPath(using: .stroke)
        context.addPath(node1)
        context.addPath(node2)
        context.drawPath(using: .fill)
        
        let lineTrackingBox = NSRect(x: x1 + node1Radius, y: -node1Radius, width: pathEnd - pathStart, height: 2*node2Radius)
        // Add tracking areas
        //let phaseTrackingArea = NSTrackingArea(rect: lineTrackingBox, options: .activeInActiveApp, owner: viewController, userInfo: nil)
        //let node1TrackingArea = NSTrackingArea(rect: node1Box, options: .activeInActiveApp, owner: viewController, userInfo: nil)
        //self.addTrackingArea(phaseTrackingArea)
        //self.addTrackingArea(node1TrackingArea)
        return PhaseSelector(phase: phase, lineBox: lineTrackingBox, node1Box: node1Box, node2Box: node2Box)
    }
    
    func drawInitialNode(context: CGContext, radius: CGFloat, thickness: CGFloat, cutoutWidth: CGFloat, center: CGPoint, isInitial: Bool) {
        let innerRadius: CGFloat = radius - thickness
        
        if isInitial {
            context.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2))
            context.addEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius, width: innerRadius*2, height: innerRadius*2))
            context.drawPath(using: .eoFill)
        } else {
            let startAngle = CGFloat(PI) - asin(cutoutWidth/2/radius)
            let innerStartAngle = CGFloat(PI) - asin(cutoutWidth/2/innerRadius)
            let startPoint = CGPoint(x: radius*cos(startAngle) + center.x, y: radius*sin(startAngle) + center.y)
            let point3 = CGPoint(x: innerRadius*cos(innerStartAngle) + center.x, y: -innerRadius*sin(innerStartAngle) + center.y)

            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: -startAngle, clockwise: true)
            context.addLine(to: point3)
            context.addArc(center: center, radius: innerRadius, startAngle: -innerStartAngle, endAngle: innerStartAngle, clockwise: false)
            context.addLine(to: startPoint)
            
            context.drawPath(using: .fill)
        }
    }
}

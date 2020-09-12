//
//  ParameterSelectorButton.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/8/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

@IBDesignable class ParameterSelectorButton: NSButton {

    private func rectInset(in rect: CGRect, by inset: CGFloat)->CGRect {
        let newRect = CGRect(x: rect.minX+inset, y: rect.minY+inset, width: rect.width-2*inset, height: rect.height-2*inset)
        return newRect
    }
    let gradientColors = [NSColor.magenta.cgColor, NSColor.yellow.cgColor, NSColor.green.cgColor, NSColor.cyan.cgColor, NSColor.purple.cgColor]
    
    override func draw(_ dirtyRect: NSRect) {
        //super.draw(dirtyRect)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let height = dirtyRect.height
        let margin = CGFloat(3.0)
        let startX = dirtyRect.width/2-height/2
        let boundaryRect = CGRect(x: startX+margin, y: dirtyRect.minY+margin, width: dirtyRect.height-2*margin, height: height-2*margin)
        let innerRect = rectInset(in: boundaryRect, by: 1.5)
        let innerRect2 = rectInset(in: innerRect, by: 2)
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.1, 0.3, 0.4, 0.6, 0.9]
        guard let gradient = CGGradient(colorsSpace: colorspace, colors: gradientColors as CFArray, locations: colorLocations) else {return}
        
        context.saveGState()
        
        let circleClip = CGMutablePath()
        circleClip.addEllipse(in: boundaryRect)
        circleClip.addEllipse(in: innerRect)

        context.addPath(circleClip)
        let startpoint = CGPoint(x: boundaryRect.minX, y: boundaryRect.minY)
        let endpoint = CGPoint(x: boundaryRect.maxX, y: boundaryRect.maxY)
        context.setLineWidth(0)
        context.clip(using: .evenOdd)
        
        context.drawLinearGradient(gradient, start: startpoint, end: endpoint, options: [])
        context.restoreGState()
        
        context.setFillColor(NSColor.controlColor.cgColor)
        context.setAlpha(0.4)
        context.addEllipse(in: innerRect)
        context.drawPath(using: .fill)
        if self.state == .on {
            context.setFillColor(NSColor.controlAccentColor.cgColor)
            context.setAlpha(1.0)
            context.addEllipse(in: innerRect2)
            context.drawPath(using: .fill)
        }

    }
}

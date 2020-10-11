//
//  ParameterSelectorButton.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/8/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

@IBDesignable
public class ParameterSelectorButton: NSButton {
    /*
    static let labelAttributes: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: NSColor.black.cgColor
            //NSColor.labelColor.cgColor
    ]*/
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.canDrawSubviewsIntoLayer = true
    }
    
    private func rectInset(in rect: CGRect, by inset: CGFloat)->CGRect {
        let newRect = CGRect(x: rect.minX+inset, y: rect.minY+inset, width: rect.width-2*inset, height: rect.height-2*inset)
        return newRect
    }
    let gradientColors = [NSColor.magenta.cgColor, NSColor.yellow.cgColor, NSColor.green.cgColor, NSColor.cyan.cgColor, NSColor.purple.cgColor]
    
    public override func draw(_ dirtyRect: NSRect) {
        // Custom button stuff
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let height = dirtyRect.height
        let margin = CGFloat(3.0)
        var startX = CGFloat(0.0)
        if self.title == "" {
            startX = (dirtyRect.width - height - margin)/2
        }
        
        let boundaryRect = CGRect(x: startX+margin, y: dirtyRect.minY+1*margin, width: dirtyRect.height-2*margin, height: height-2*margin)
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
               
        // Text drawing stuff
        self.isTransparent = false
        self.alphaValue = 1
        
        let textRect = NSRect(x: height + margin, y: 0, width: dirtyRect.width, height: self.frame.height)
        let textTextContent = self.title

        let textFontAttributes : [ NSAttributedString.Key : Any ] = [
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .foregroundColor: NSColor.labelColor
        ]

        //context.addRect(textRect)
        //context.setFillColor(NSColor.blue.cgColor)
        //context.drawPath(using: .fill)
        let textTextHeight: CGFloat = textTextContent.boundingRect(with: NSSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes).height
        let textTextRect: NSRect = NSRect(x: height, y: (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight)
        context.setAlpha(1)
        //NSGraphicsContext.saveGraphicsState()
        textTextContent.draw(in: textTextRect, withAttributes: textFontAttributes)
        //NSGraphicsContext.restoreGraphicsState()
    }
}

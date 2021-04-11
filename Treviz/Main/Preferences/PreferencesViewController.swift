//
//  PreferencesViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/7/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Cocoa

class PreferencesWindowController:
    NSWindowController, NSWindowDelegate {
    var parentItem: NSMenuItem?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
    }

    func windowWillClose(_ notification: Notification) {
        parentItem?.isEnabled = true
    }
}

class PreferencesViewController: NSTabViewController {
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        UserDefaults.standard.setValue(tabViewItem?.identifier, forKey: "selectedPreferencesTab")
    }
    override func viewDidLoad() {
        let selectedTab = UserDefaults.standard.string(forKey: "selectedPreferencesTab")
        super.viewDidLoad()
        if selectedTab != nil {
            tabView.selectTabViewItem(withIdentifier: selectedTab!)
        }
    }
}

class PlotPreferencesViewController: NSViewController {
    
    @IBOutlet weak var axesLineStyleButton: LineStyleButton!
    @IBOutlet weak var majorGridlineStyleButton: LineStyleButton!
    @IBOutlet weak var minorGridlineStyleButton: LineStyleButton!
    @IBOutlet weak var mainLineStyleButton: LineStyleButton!
    
    @IBOutlet weak var backgroundColorWell: NSColorWell!

    @IBOutlet weak var mcOpacitySlider: NSSlider!
    @IBOutlet weak var mcLabel: NSTextField!
    
    @IBOutlet weak var markerStyleButton: NSPopUpButton!
    @IBOutlet weak var markerSetButton: NSButton!
    @IBOutlet var mcOpacityFormatter: NumberFormatter!
    
    override func viewDidLoad() {
        backgroundColorWell.color = NSColor(cgColor: UserDefaults.backgroundColor)!
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSelectColor(_:)), name: NSColorPanel.colorDidChangeNotification, object: nil)
        
        // Connections for line style buttons
        mainLineStyleButton.lineStyle = UserDefaults.mainLineStyle
        mainLineStyleButton.didChangeStyle = { UserDefaults.mainLineStyle = self.mainLineStyleButton.lineStyle }
        
        majorGridlineStyleButton.lineStyle = UserDefaults.majorGridlineStyle
        majorGridlineStyleButton.didChangeStyle = { UserDefaults.majorGridlineStyle = self.majorGridlineStyleButton.lineStyle }
        
        minorGridlineStyleButton.lineStyle = UserDefaults.minorGridlineStyle
        minorGridlineStyleButton.didChangeStyle = { UserDefaults.minorGridlineStyle = self.minorGridlineStyleButton.lineStyle }
        
        axesLineStyleButton.shouldHavePattern = false
        axesLineStyleButton.lineStyle = UserDefaults.axesLineStyle
        axesLineStyleButton.didChangeStyle = { UserDefaults.axesLineStyle = self.axesLineStyleButton.lineStyle }
        
        // Other controls
        mcOpacityFormatter.maximumFractionDigits = 2
        mcOpacityFormatter.maximumSignificantDigits = 2
        let mcOpacity = Double(UserDefaults.mcOpacity)
        mcOpacitySlider.doubleValue = mcOpacity
        mcLabel.stringValue = mcOpacityFormatter.string(from: NSNumber(value: mcOpacity)) ?? ""
        
        // Final setup
        let baseSubViews = self.view.recurseGetSubviews()
        let allButtons = baseSubViews.filter({ $0 is LineStyleButton }) as! [LineStyleButton]
        for thisButton in allButtons {
            thisButton.parentVC = self
        }
        super.viewDidLoad()
    }
    
    @IBAction func didChangeMCOpacity(_ sender: NSSlider) {
        let newOpacity = sender.doubleValue
        UserDefaults.mcOpacity = CGFloat(newOpacity)
        mcLabel.stringValue = mcOpacityFormatter.string(from: NSNumber(value: newOpacity)) ?? ""

    }
    
    @IBAction func didSelectColor(_ sender: Any) {
        let thisColor = backgroundColorWell.color
        UserDefaults.backgroundColor = thisColor.cgColor
    }
}

/**
 This is a pushbutton that opens an editor for line styles when pushed and continuously updates an associated style when edited
 */
class LineStyleButton: NSButton {
    var lineStyle: TZLineStyle!
    var parentVC: NSViewController!
    var shouldHavePattern: Bool = true
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.target = self
        self.action = #selector(self.showLineStyleView)
    }
    @objc func showLineStyleView(){
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        guard let newVC = storyboard.instantiateController(withIdentifier: "lineStyleController") as? LineStyleVC else { return }
        newVC.parentButton = self
        parentVC.present(newVC, asPopoverRelativeTo: self.bounds, of: self, preferredEdge: NSRectEdge.maxX, behavior: NSPopover.Behavior.transient)
    }
    var didChangeStyle: ()->() = {} // Closure for setting line style in the superclass
    
    func changeStyle(){
        didChangeStyle()
        self.needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let margin: CGFloat = 13.0
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        super.draw(dirtyRect)
        
        context.setStrokeColor(lineStyle.color)
        let width = CGFloat(lineStyle.lineWidth)
        context.setLineWidth(width)
        var x1 = dirtyRect.minX + margin
        let x2 = dirtyRect.maxX - margin
        let y = dirtyRect.midY
        var point1: CGPoint
        var point2: CGPoint
        var x = x1
        var pattern = lineStyle.pattern.nums
        context.setLineCap(.capForPattern(lineStyle.pattern))
        if pattern.count > 1 {
            while x<x2 {
                // Find line segment, draw line
                x = x1 + width*pattern[0]
                point1 = CGPoint(x: x1, y: y)
                point2 = CGPoint(x: x, y: y)
                context.addLines(between: [point1, point2])
                pattern.append(pattern[0])
                pattern = Array(pattern.dropFirst())
                
                // Skip ahead by the space
                x = x + width*pattern[0]
                pattern.append(pattern[0])
                pattern = Array(pattern.dropFirst())
                x1 = x
            }
        } else {
            context.addLines(between: [CGPoint(x: x1, y: y), CGPoint(x: x2, y: y)])
        }
        context.drawPath(using: .stroke)
    }
}

/*
 Small popover window that allows setting a line style
 */
class LineStyleVC: NSViewController {
    var parentButton: LineStyleButton!
    var shouldHavePattern: Bool { return parentButton.shouldHavePattern }
    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var colorWell: NSColorWell!
    @IBOutlet weak var widthSelector: NSComboBox!
    @IBOutlet weak var patternSelector: NSPopUpButton!
    
    var lineWidth: Double {
        get { return lineStyle.lineWidth }
        set { lineStyle.lineWidth = newValue
            parentButton.changeStyle()
        }
    }
    var lineColor: CGColor {
        get { return lineStyle.color }
        set { lineStyle.color = newValue
            parentButton.changeStyle()
        }
    }
    var linePattern: TZLinePattern {
        get {
            if shouldHavePattern { return lineStyle.pattern }
            else { return .solid }
        }
        set {
            if shouldHavePattern { lineStyle.pattern = newValue
            parentButton.changeStyle()
            }
        }
    }
    var lineStyle: TZLineStyle! {
        get { return parentButton.lineStyle }
        set { parentButton.lineStyle = newValue
            parentButton.changeStyle()
        }
    }
    
    override func viewDidLoad() {
        if shouldHavePattern {
            let patternNames: [String] = TZLinePattern.allPatterns.map {$0.name}
            patternSelector.addItems(withTitles: patternNames)
            patternSelector.selectItem(withTitle: lineStyle.pattern.name)
        } else {
            gridView.showHide(.hide, .row, index: [2])
        }
        lineStyle = parentButton.lineStyle
        widthSelector.stringValue = lineStyle.lineWidth.valuestr
        colorWell.color = NSColor(cgColor: lineStyle.color) ?? .black
    }
    
    override func viewDidDisappear() {
        parentButton.lineStyle = lineStyle
        parentButton.changeStyle()
    }
    
    @IBAction func didSelectColor(_ sender: NSColorWell) {
        lineColor = sender.color.cgColor
    }
    @IBAction func didSelectWidth(_ sender: NSComboBox) {
        if let newWidth = Double(sender.stringValue){
            lineWidth = newWidth
        }
    }
    @IBAction func didSelectPattern(_ sender: NSPopUpButton) {
        linePattern = TZLinePattern.allPatterns[sender.indexOfSelectedItem]
    }
    
    
}

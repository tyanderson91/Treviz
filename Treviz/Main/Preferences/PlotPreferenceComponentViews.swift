//
//  PlotPreferenceComponentViews.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/11/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

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


extension CGPoint {
    init(point1: CGPoint, point2: CGPoint, pct: CGFloat) {
        let newX: CGFloat = (1.0 - pct) * point1.x + pct * point2.x
        let newY: CGFloat = (1.0 - pct) * point1.y + pct * point2.y
        self.init(x: newX, y: newY)
    }
}

class SymbolStyleButton: NSButton {
    var symbolStyle: TZMarkerStyle!
    var parentVC: NSViewController!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.target = self
        self.action = #selector(self.showSymbolStyleView)
    }
    @objc func showSymbolStyleView(){
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        guard let newVC = storyboard.instantiateController(withIdentifier: "markerStyleController") as? SymbolStyleVC else { return }
        newVC.parentButton = self
        
        parentVC.present(newVC, asPopoverRelativeTo: self.bounds, of: self, preferredEdge: NSRectEdge.maxX, behavior: NSPopover.Behavior.transient)
        newVC.shapeSelector.selectItem(withTitle: symbolStyle.shape.character())
    }
    var didChangeStyle: ()->() = {} // Closure for setting line style in the superclass
    
    func changeStyle(){
        didChangeStyle()
        if self.symbolStyle.shape == .none {
            self.title = "None"
        } else { self.title = ""}
        self.needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let CPTSymbol = CPTPlotSymbol(symbolStyle)
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let center = CGPoint(x: dirtyRect.midX, y: dirtyRect.midY)
        super.draw(dirtyRect)
        
        CPTSymbol.renderAsVector(in: context, at: center, scale: 1.0)
    }
}

/*
 Small popover window that allows setting a symbol style
 */
class SymbolStyleVC: NSViewController {
    var parentButton: SymbolStyleButton!
    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var colorWell: NSColorWell!
    @IBOutlet weak var sizeSelector: NSComboBox!
    @IBOutlet weak var shapeSelector: NSPopUpButton!
    
    var symbolSize: CGFloat {
        get { return symbolStyle.size }
        set { symbolStyle.size = newValue
        }
    }
    var symbolColor: CGColor {
        get { return symbolStyle.color }
        set { symbolStyle.color = newValue
        }
    }
    var symbolShape: TZPlotSymbol {
        get { return symbolStyle.shape }
        set {
            symbolStyle.shape = newValue
            }
    }
    var symbolStyle: TZMarkerStyle! {
        get { return parentButton.symbolStyle }
        set { parentButton.symbolStyle = newValue
              parentButton.changeStyle()
        }
    }
    
    override func viewDidLoad() {
        sizeSelector?.stringValue = String(describing: symbolStyle.size)
        colorWell.color = NSColor(cgColor: symbolStyle.color) ?? .black
        let allSymbols = TZPlotSymbol.allCases.map({$0.character()})
        shapeSelector.addItems(withTitles: allSymbols )
    }
    
    override func viewDidDisappear() {
        parentButton.changeStyle()
    }
    
    @IBAction func didSelectColor(_ sender: NSColorWell) {
        symbolColor = sender.color.cgColor
    }
    
    @IBAction func didSelectSize(_ sender: NSComboBox) {
        if let newWidth = Double(sender.stringValue){
            symbolSize = CGFloat(newWidth)
        }
    }
    
    @IBAction func didSelectShape(_ sender: NSPopUpButton) {
        symbolShape = TZPlotSymbol.allCases[sender.indexOfSelectedItem]
    }
}

// MARK: Colormap selector stuff
class ColormapPopUpButton: NSPopUpButton {
    var colormap: ColorMap! {
        didSet {
            if let cmapCell = self.cell as? ColormapPopupButtonCell {
                cmapCell.colormap = colormap
            }
        }
    }
    var preview: ColormapPreview!
    
    var didChangeMap: ()->() = {} // Closure for setting line style in the superclass
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.target = self
        self.action = #selector(self.didUpdate)
    }

    @objc func didUpdate(){
        let newItem = self.titleOfSelectedItem ?? ""
        guard let newColormap = ColorMap.allMaps.first(where: {$0.name == newItem})
        else { return }
        colormap = newColormap
        preview?.colormap = self.colormap
        preview?.needsDisplay = true
        didChangeMap()
    }
    func updateSelection() {
        self.selectItem(withTitle: colormap.name)
        preview?.colormap = self.colormap
        preview?.needsDisplay = true
    }
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        super.willOpenMenu(menu, with: event)
    }
}

class ColormapPopupButtonCell: NSPopUpButtonCell {
    var colormap: ColorMap! {
        didSet {
            preview?.colormap = colormap
            preview.needsDisplay = true
            preview.setTextMode(on: false)
            preview.previewBox.needsDisplay = true
        }
    }
    var preview: ColormapPreview!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        preview = ColormapPreview.createFromNib()
        //preview.previewBoxSizeConstraint.constant = 15.0
        controlView?.addSubview(preview)
        preview.setTextMode(on: false)
        self.title = ""
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        self.title = ""
        //self.stringValue = ""
        super.draw(withFrame: cellFrame, in: controlView)
        preview.colormap = colormap
        //preview.previewBoxSizeConstraint.constant = 15.0
        //preview.needsLayout = true
        let safeArea = controlView.safeAreaRect.insetBy(dx: 1.0, dy: 1.0)
        //preview.setTextMode(on: false)
        preview.draw(safeArea)
    }
}

class ColormapPreviewCircle: NSView {
    var colormap: ColorMap!
    
    override func draw(_ dirtyRect: NSRect) {
        guard colormap != nil else { return }
        let insetRect = dirtyRect
        let centerCutout: CGFloat = 0.4
        let nWedges = colormap.colors.count
        let wedgeAngle = -CGFloat(2*PI/Double(nWedges))
        let x0 = insetRect.midX
        let y0 = insetRect.midY
        let rad = insetRect.height/2.0
        let center = CGPoint(x: x0, y: y0)
        
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        var angle: CGFloat = CGFloat(PI/2)
        context.move(to: CGPoint(x: x0, y: y0-rad))

        for thisColor in colormap.colors {
            let path = CGMutablePath()
            let point1 = context.currentPointOfPath
            path.addRelativeArc(center: center, radius: rad, startAngle: angle, delta: wedgeAngle)
            let point2 = path.currentPoint
            let point3 = CGPoint(point1: point2, point2: center, pct: (1-centerCutout))
            path.addLine(to: point3)
            path.addRelativeArc(center: center, radius: rad*centerCutout, startAngle: angle+wedgeAngle, delta: -wedgeAngle)
            path.addLine(to: point1)
            context.addPath(path)
            context.setFillColor(thisColor)
            context.drawPath(using: .fill)
            context.move(to: point2)
            angle = angle + wedgeAngle
        }
    }
}

class ColormapPreview: NSView, NibLoadable {
    
    var colormap: ColorMap! {
        didSet { previewBox?.colormap = colormap
            label?.stringValue = colormap.name
        }
    }
    var includeText: Bool = true
    @IBOutlet weak var previewBox: ColormapPreviewCircle!
    @IBOutlet weak var previewBoxSizeConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var previewBoxLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewBoxTrailingConstraint: NSLayoutConstraint!
    let defaultTrailingConstraint: CGFloat = 71.0
    
    
    private var effectView: NSVisualEffectView!
    var menuItem: NSMenuItem? { return enclosingMenuItem }
    var enclosingMenu: NSMenu? { return menuItem?.menu }
    
    override init(frame: NSRect) {
        effectView = NSVisualEffectView()
        effectView.state = .active
        effectView.material = .selection
        effectView.isEmphasized = true
        effectView.blendingMode = .behindWindow

        super.init(frame: frame)
        addSubview(effectView)
        effectView.frame = bounds
    }

    func setTextMode(on: Bool){
        if on {
            label?.stringValue = colormap.name
            previewBoxTrailingConstraint.constant = defaultTrailingConstraint
        } else {
            label.stringValue = ""
            previewBoxTrailingConstraint?.constant = previewBoxLeftConstraint.constant
        }
        self.layout()
        self.needsDisplay = true
    }
    required init?(coder decoder: NSCoder) {
        effectView = NSVisualEffectView()
        effectView.state = .active
        effectView.material = .selection
        effectView.isEmphasized = true
        effectView.blendingMode = .behindWindow

        super.init(coder: decoder)
        addSubview(effectView, positioned: .below, relativeTo: previewBox)
        effectView.frame = bounds
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if effectView != nil {
            effectView.isHidden = !(enclosingMenuItem?.isHighlighted ?? false)
        }
        guard label != nil, previewBox != nil else { return }
    }
    
    override func mouseEntered(with event: NSEvent) {
        guard enclosingMenu != nil else {return}
        enclosingMenu!.items.forEach({$0.state = .off})
    }
    
    override func mouseExited(with event: NSEvent) {
        needsDisplay = true
        enclosingMenuItem?.state = .off
    }

    override func mouseUp(with event: NSEvent) {
        guard enclosingMenu != nil else {return}
        enclosingMenu!.cancelTracking()
        enclosingMenu!.performActionForItem(at: enclosingMenu!.index(of: menuItem!))
        //menu.performActionForItemAtIndex(menu.indexOfItem: self.enclosingmenuItem)
    }
}

class ColorMapMenuItem: NSMenuItem {
    var colormap: ColorMap!
    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
    }
    convenience init(colormap cmapIn: ColorMap) {
        self.init(title: cmapIn.name, action: nil, keyEquivalent: "")
        colormap = cmapIn
        let newView = ColormapPreview.createFromNib()
        newView.colormap = colormap
        newView.label.stringValue = title
        self.view = newView
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// For views that can be loaded from nib file
protocol NibLoadable {
    // Name of the nib file
    static var nibName: String { get }
    static func createFromNib(in bundle: Bundle) -> Self
}

extension NibLoadable where Self: NSView {

    // Default nib name must be same as class name
    static var nibName: String {
        return String(describing: Self.self)
    }

    static func createFromNib(in bundle: Bundle = Bundle.main) -> Self {
        var topLevelArray: NSArray? = nil
        bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
        let views = Array<Any>(topLevelArray!).filter { $0 is Self }
        return views.last as! Self
    }
}

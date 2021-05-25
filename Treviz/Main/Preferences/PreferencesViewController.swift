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

protocol PlotPreferencesControllerDelegate {
    var plotPreferences: PlotPreferences { get set }
}

class GlobalPlotPreferencesViewController: NSViewController, PlotPreferencesControllerDelegate {
    @IBOutlet weak var preferencesView: NSView!
    
    var plotPreferences: PlotPreferences {
        get { return UserDefaults.plotPreferences }
        set { UserDefaults.plotPreferences = newValue
            previewObject.applyPrefs()
        }
    }
    var preferencesVC: PlotPreferencesViewController!
    @IBOutlet weak var plotPreview: CPTGraphHostingView!
    var previewGraph: CPTGraph!
    var previewObject: GlobalPlotPreview!
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard segue.identifier == "preferenceControlSegue" else { return }
        preferencesVC = (segue.destinationController as! PlotPreferencesViewController)
        preferencesVC.delegate = self
        preferencesVC.plotPreviewViewer = previewObject
    }
    
    override func viewDidLoad() {
        previewObject = GlobalPlotPreview()
        previewGraph = previewObject.graph
        plotPreview.hostedGraph = previewGraph
        super.viewDidLoad()
    }
}

class PlotPreferencesViewController: NSViewController {
    
    var delegate: PlotPreferencesControllerDelegate!
    
    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var axesLineStyleButton: LineStyleButton!
    @IBOutlet weak var majorGridlineStyleButton: LineStyleButton!
    @IBOutlet weak var minorGridlineStyleButton: LineStyleButton!
    @IBOutlet weak var mainLineStyleButton: LineStyleButton!
    @IBOutlet weak var lineSetPopupButton: NSPopUpButton!
    var plotPreviewViewer: PlotPreviewDisplay?
    
    @IBOutlet weak var divider1: NSBox!
    @IBOutlet weak var divider2: NSBox!
    let d1row = 8
    let d2row = 11
    
    @IBOutlet weak var backgroundColorWell: NSColorWell!
    @IBOutlet weak var useInteractiveCheckbox: NSButton!
    
    @IBOutlet weak var mcOpacitySlider: NSSlider!
    @IBOutlet weak var mcLabel: NSTextField!
    
    @IBOutlet weak var colormapSelectorPopup: ColormapPopUpButton!
    
    @IBOutlet weak var markerStyleButton: SymbolStyleButton!
    @IBOutlet weak var markerSetButton: NSPopUpButton!
    @IBOutlet var mcOpacityFormatter: NumberFormatter!
    
    override func viewDidLoad() {
        backgroundColorWell.color = NSColor(cgColor: delegate.plotPreferences.backgroundColor)!
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSelectColor(_:)), name: NSColorPanel.colorDidChangeNotification, object: nil)
        
        // Connections for line style buttons
        mainLineStyleButton.lineStyle = delegate.plotPreferences.mainLineStyle
        mainLineStyleButton.didChangeStyle = { self.delegate.plotPreferences.mainLineStyle = self.mainLineStyleButton.lineStyle }
        
        majorGridlineStyleButton.lineStyle = delegate.plotPreferences.majorGridLineStyle
        majorGridlineStyleButton.didChangeStyle = { self.delegate.plotPreferences.majorGridLineStyle = self.majorGridlineStyleButton.lineStyle }
        
        minorGridlineStyleButton.lineStyle = delegate.plotPreferences.minorGridLineStyle
        minorGridlineStyleButton.didChangeStyle = { self.delegate.plotPreferences.minorGridLineStyle = self.minorGridlineStyleButton.lineStyle }
        
        axesLineStyleButton.shouldHavePattern = false
        axesLineStyleButton.lineStyle = delegate.plotPreferences.axesLineStyle
        axesLineStyleButton.didChangeStyle = { self.delegate.plotPreferences.axesLineStyle = self.axesLineStyleButton.lineStyle }
        
        // Other controls
        mcOpacityFormatter.maximumFractionDigits = 2
        let mcOpacity = Double(UserDefaults.mcOpacity)
        mcOpacitySlider.doubleValue = mcOpacity
        mcLabel.stringValue = mcOpacityFormatter.string(from: NSNumber(value: mcOpacity)) ?? ""
        
        for thisMap in ColorMap.allMaps {
            let newItem = ColorMapMenuItem(colormap: thisMap)
            colormapSelectorPopup.menu?.addItem(newItem)
        }
        
        colormapSelectorPopup.colormap = delegate.plotPreferences.colorMap
        colormapSelectorPopup.updateSelection()
        colormapSelectorPopup.didChangeMap = { self.delegate.plotPreferences.colorMap = self.colormapSelectorPopup.colormap }
        
        if self.delegate.plotPreferences.isInteractive {
            useInteractiveCheckbox.state = .on
            useInteractiveCheckbox.stringValue = "On"
        } else {
            useInteractiveCheckbox.state = .off
            useInteractiveCheckbox.stringValue = "Off"
        }
        markerStyleButton.parentVC = self
        markerStyleButton.symbolStyle = delegate.plotPreferences.markerStyle
        markerSetButton.addItems(withTitles: SymbolSet.allSets.map({$0.description}))
        markerStyleButton.didChangeStyle = {
            self.delegate.plotPreferences.markerStyle = self.markerStyleButton.symbolStyle
            self.updateSymbolSetSelections()
        }
        
        markerStyleButton.changeStyle()
        // Section dividers
        gridView.mergeCells(inHorizontalRange: NSRange(location: 0, length: 2), verticalRange: NSRange(location: d1row, length: 1))
        gridView.mergeCells(inHorizontalRange: NSRange(location: 0, length: 2), verticalRange: NSRange(location: d2row, length: 1))
        
        // CUSTOM TEST
        //lineSetPopupButton.addItems(withObjects: [NSString("A"), NSString("B"),NSString("C")])
        
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
        delegate.plotPreferences.mcOpacity = CGFloat(newOpacity)
        mcLabel.stringValue = mcOpacityFormatter.string(from: NSNumber(value: newOpacity)) ?? ""
    }
    
    @IBAction func didSelectColor(_ sender: Any) {
        let thisColor = backgroundColorWell.color
        delegate.plotPreferences.backgroundColor = thisColor.cgColor
    }
    
    @IBAction func didSetInteractive(_ sender: NSButton) {
        if sender.state == .on {
            delegate.plotPreferences.isInteractive = true
        } else {
            delegate.plotPreferences.isInteractive = false
        }
    }
    
    @IBAction func didChangeMarkerSet(_ sender: NSPopUpButton) {
        let selectedSet = SymbolSet.allSets[sender.indexOfSelectedItem]
        delegate.plotPreferences.symbolSet = selectedSet
    }
    
    private func updateSymbolSetSelections() {
        //let selectedItem = markerSetButton.indexOfSelectedItem
        let curSymbol = markerStyleButton.symbolStyle.shape
        SymbolSet.allSets[SymbolSet.allSets.count-1] = [curSymbol]
        markerSetButton.removeAllItems()
        markerSetButton.addItems(withTitles: SymbolSet.allSets.map({$0.description}))
        markerSetButton.selectItem(withTitle: delegate.plotPreferences.symbolSet.description)
    }
    
}

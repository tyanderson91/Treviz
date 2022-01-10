//
//  CustomTabHeaderViewController.swift
//  customTabViewTest
//
//  Created by Tyler Anderson on 1/1/22.
//

import Cocoa

class DynamicTabHeaderViewController: NSViewController {
    var tabViewItem: NSTabViewItem!
    var childVC: NSViewController! {
        didSet { setLabel(self.titleString) }
    }
    var initAction: (()->())?
    var teardownAction: (()->())?
    var isActive: Bool = false { didSet {
        box.isActive = self.isActive
    }
        
    }
    var isPinned = false {
        didSet {
            assert(self.isPinned) // Cannot switch back to false
            self.label.attributedStringValue = titleString
            tabViewController.unpinnedView = nil
            box.menu = nil
        }
    }
    private var _mouseIsInside: Bool = false
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var box: TabHeaderBox!
    @IBOutlet weak var removeTabButton: NSButton!
    
    override var title: String? {
        get { return childVC.title }
        set { childVC.title = newValue }
    }
    var titleString: NSAttributedString {
        let strvalue : String = self.title ?? "UNNAMED"
        if self.isPinned {
            return NSAttributedString.init(string: strvalue)
        } else {
            var attrs = [NSAttributedString.Key:Any]()
            attrs[.obliqueness] = 0.25
            if _mouseIsInside {
                attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
                //attrs[.underlineColor] = NSColor.black
            }
            return NSAttributedString.init(string: strvalue, attributes: attrs)
        }
    }
    
    var tabViewController: DynamicTabViewController! { get { return parent as? DynamicTabViewController } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel(titleString)
        self.isActive = false
        box.borderWidth = 0.5
        let boxTrackingArea = NSTrackingArea(rect: box.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        view.addTrackingArea(boxTrackingArea) // Used to show/hide playback controller box in floating mode
        removeTabButton.isHidden = true
        if let ia = initAction {
            ia()
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func mouseEntered(with event: NSEvent) {
        removeTabButton.isHidden = false
        _mouseIsInside = true
        setLabel(titleString)
        super.mouseEntered(with: event)
    }
    override func mouseExited(with event: NSEvent) {
        removeTabButton.isHidden = true
        _mouseIsInside = false
        setLabel(titleString)
        super.mouseExited(with: event)
    }
    override func mouseDown(with event: NSEvent) {
        makeActive()
    }
    override func mouseUp(with event: NSEvent) {
        if event.clickCount >= 2 {
            self.isPinned = true
        }
    }
    
    func setLabel(_ string: NSAttributedString){
        if label != nil {
            label.attributedStringValue = string
        }
    }
    @IBAction func pinFromMenu(_ sender: Any) {
        self.isPinned = true
    }
    
    init?(coder: NSCoder, parent: DynamicTabViewController, childVC child: NSViewController){
        super.init(coder: coder)
        childVC = child
        self.addChild(childVC)
        tabViewItem = NSTabViewItem(viewController: childVC)
        parent.tabView.addTabViewItem(tabViewItem)
        parent.tabView.selectTabViewItem(tabViewItem)
    }
    
    func makeActive(){
        tabViewController.selectView(tabVC: self)
    }
    
    @IBAction func delete(_ sender: Any){
        tabViewController.deleteView(tabVC: self)
        if let td = teardownAction {
            td()
        }
    }
    
    func swapView(newVC: NSViewController){
        guard !isPinned else { return } // Can't swap out the view of a pinned tab
        let prevItem = tabViewItem
        tabViewItem = NSTabViewItem(viewController: newVC)
        tabViewController.tabView.addTabViewItem(tabViewItem)
        
        tabViewController.tabView.selectTabViewItem(tabViewItem)
        
        childVC.removeFromParent()
        tabViewController.tabView.removeTabViewItem(prevItem!)
        childVC = newVC
        self.addChild(newVC)
    }
}

class TabHeaderBox: NSBox { // Custom box that changes color based on selected tab
    static var activeColor: NSColor { .selectedContentBackgroundColor.blended(withFraction: 0.3, of: .white)!.withAlphaComponent(0.5) }
    static let inactiveColor: NSColor = .clear
    
    var isActive: Bool = false {
        didSet {
            setColor()
        }
    }
    override func viewDidChangeEffectiveAppearance() {
        setColor()
    }
    
    func setColor() {
        if isActive { self.fillColor = TabHeaderBox.activeColor }
        else { self.fillColor = TabHeaderBox.inactiveColor }
    }
}

//
//  CustomTabHeaderViewController.swift
//  customTabViewTest
//
//  Created by Tyler Anderson on 1/1/22.
//

import Cocoa

class DynamicTabHeaderViewController: NSViewController {
    static let activeColor: NSColor = .clear
    static let inactiveColor: NSColor = .unemphasizedSelectedContentBackgroundColor
    
    var tabViewItem: NSTabViewItem!
    var childVC: NSViewController! {
        didSet { setLabel(self.titleString) }
    }
    var isActive: Bool = false { didSet {
        if self.isActive {
            box.fillColor = DynamicTabHeaderViewController.activeColor
        } else {
            box.fillColor = DynamicTabHeaderViewController.inactiveColor
        }
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
    @IBOutlet weak var box: NSBox!
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


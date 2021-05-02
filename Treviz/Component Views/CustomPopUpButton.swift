//
//  CustomPopUpButton.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/20/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

// MARK: Colormap selector stuff
class CustomPopUpButton: NSPopUpButton {
    var representedObject: Any? {
        didSet {
            if let thisCell = self.cell as? CustomPopupButtonCell {
                thisCell.representedObject = representedObject
            }
        }
    }
    var customView: CustomPopUpMenuItemView!

    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        super.willOpenMenu(menu, with: event)
    }
    
    func addItem(withObject object: Any) {
        let newItem = CustomPopUpMenuItem(representedObject: object)
        menu?.addItem(newItem)
    }
    func addItems(withObjects objects: [Any]) {
        objects.forEach {self.addItem(withObject: $0)}
    }
}

class CustomPopupButtonCell: NSPopUpButtonCell {
    override var representedObject: Any? {
        didSet {
            selectedMenuItemView?.representedObject = representedObject
            selectedMenuItemView.needsDisplay = true
            selectedMenuItemView.imageBoxView.needsDisplay = true
        }
    }
    var selectedMenuItemView: CustomPopUpMenuItemView!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        selectedMenuItemView = CustomPopUpMenuItemView.createFromNib()
        selectedMenuItemView.previewBoxSizeConstraint.constant = 30.0
        controlView?.addSubview(selectedMenuItemView)
        self.title = ""
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        self.title = ""
        super.draw(withFrame: cellFrame, in: controlView)
        selectedMenuItemView.representedObject = representedObject
        selectedMenuItemView.previewBoxSizeConstraint.constant = 15.0
        selectedMenuItemView.needsLayout = true
        let safeArea = controlView.safeAreaRect
        selectedMenuItemView.draw(safeArea)
    }
}

class CustomPopUpMenuItemView: NSView, NibLoadable {
    
    var representedObject: Any? /*{
        didSet {
            label?.stringValue = colormap.name
        }
    }*/
    @IBOutlet weak var imageBoxView: NSView!
    @IBOutlet weak var previewBoxSizeConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: NSTextField!
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

    required init?(coder decoder: NSCoder) {
        effectView = NSVisualEffectView()
        effectView.state = .active
        effectView.material = .selection
        effectView.isEmphasized = true
        effectView.blendingMode = .behindWindow

        super.init(coder: decoder)
        addSubview(effectView, positioned: .below, relativeTo: imageBoxView)
        effectView.frame = bounds
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if effectView != nil {
            effectView.isHidden = !(enclosingMenuItem?.isHighlighted ?? false)
        }
        guard label != nil, imageBoxView != nil else { return }
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
    }
}

class CustomPopUpMenuItem: NSMenuItem {
    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
    }
    var titleGetter: ((Any)->String) = {_ in return ""}
    convenience init(representedObject objectIn: Any) {
        self.init(title: "", action: nil, keyEquivalent: "")
        title = titleGetter(objectIn)
        representedObject = objectIn
        let newView = CustomPopUpMenuItemView.createFromNib()
        newView.representedObject = representedObject
        newView.label.stringValue = title
        self.view = newView
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

//
//  InputsTableCellViews.swift
//  Treviz
//
//  Holds the code for initiating table cell views in the inputs view controller
//
//  Created by Tyler Anderson on 4/8/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Foundation
import Cocoa

extension NSUserInterfaceItemIdentifier{
    //Views in init state and param views
    static let nameColumn = NSUserInterfaceItemIdentifier.init("NameColumn")
    static let unitsColumn = NSUserInterfaceItemIdentifier.init("UnitsColumn")
    static let nameCellView = NSUserInterfaceItemIdentifier.init("NameCellView")
    static let unitsCellView = NSUserInterfaceItemIdentifier.init("UnitsCellView")

    //Views in init state view only
    static let initStateParamColumn = NSUserInterfaceItemIdentifier.init("InitStateParameterColumn")
    static let initStateValueColumn = NSUserInterfaceItemIdentifier.init("InitStateValueColumn")
    static let initStateSubHeaderCellView = NSUserInterfaceItemIdentifier.init("initStateSubHeaderCellView")
    static let initStateHeaderCellView = NSUserInterfaceItemIdentifier.init("initStateHeaderCellView")
    static let initStateValueCellView = NSUserInterfaceItemIdentifier.init("initStateValueCellView")
    static let initStateParamCellView = NSUserInterfaceItemIdentifier.init("initStateParamCheckBoxView")
    static let initStateHasParamCellView = NSUserInterfaceItemIdentifier.init("initStateHasParamCellView")
    
    //Views in param view only
    static let paramValueColumn = NSUserInterfaceItemIdentifier.init("ParamValueColumn")
    static let paramValueCellView = NSUserInterfaceItemIdentifier.init("paramValueCellView")
}

extension InputsViewController{ // TODO: I don't like this existing here
    //Views in init state and param views
    static func nameCellView(view: NSTableView, thisInput: InputSetting)->NSTableCellView?{
        let newView = view.makeView(withIdentifier: .nameCellView, owner: self) as? NSTableCellView
        if let textField = newView?.textField{
            textField.stringValue = "\(thisInput.name) (\(thisInput.symbol)₀)"
        }
        return newView
    }
    
    static func unitsCellView(view: NSTableView, thisInput: InputSetting)->NSTableCellView?{
        let newView = view.makeView(withIdentifier: .unitsCellView, owner: self) as? NSTableCellView
        if let textField = newView?.textField{
            let str = thisInput.units
            textField.stringValue = str
        }
        return newView
    }
    
    //Views in init state view only
    static func inputParamCellView(view: NSTableView, thisInput: InputSetting)->NSButton?{
        let newView = view.makeView(withIdentifier: .initStateParamCellView, owner: self) as? NSButton
        newView?.state = thisInput.isParam ? NSControl.StateValue.on : NSControl.StateValue.off
        return newView
    }
    
    static func inputHeaderParamCellView(view: NSTableView, thisInput: InputSetting)->NSTableCellView?{
        let newView = view.makeView(withIdentifier: .initStateHasParamCellView, owner: self) as? NSTableCellView
        if let thisImageView = newView?.imageView {
            thisInput.setParams()
            let curimage = thisInput.isParam ? NSImage(named: NSImage.menuOnStateTemplateName) : nil
            thisImageView.image = curimage
        }
        return newView
    }
    
    static func inputValueCellView(view: NSTableView, thisInput: InputSetting)->NSTableCellView?{
        let newView = view.makeView(withIdentifier: .initStateValueCellView, owner: self) as? NSTableCellView
        if let textField = newView?.textField {
            let dubVal = thisInput.value
            textField.stringValue = (dubVal != nil ? String(format: "%g", dubVal!) : "--")
        }
        return newView
    }
    
    static func subHeaderCellView(view: NSTableView, thisInput: InputSetting)->NSTableCellView?{
        let newView = view.makeView(withIdentifier: .initStateSubHeaderCellView, owner: self) as? NSTableCellView
        if let textField = newView?.textField {
            textField.stringValue = thisInput.name
        }
        return newView
    }

    static func headerCellView(view: NSTableView, thisInput: InputSetting)->NSTableCellView?{
        let newView = view.makeView(withIdentifier: .initStateHeaderCellView, owner: self) as? NSTableCellView
            if let textField = newView?.textField {
                textField.stringValue = thisInput.name
                if let thisImageView = newView?.imageView {
                    thisImageView.image = NSImage.init(named: (thisInput.isValid ? NSImage.statusAvailableName : NSImage.statusUnavailableName))
                }
            }
        return newView
    }
    
    //Views in param view only

    static func paramValueCellView(view: NSTableView, thisInput: InputSetting)->NSTableCellView?{
        let newView = view.makeView(withIdentifier: .paramValueCellView, owner: self) as? NSTableCellView
        if let textField = newView?.textField {
            let dubVal = thisInput.value
            textField.stringValue = (dubVal != nil ? String(format: "%g", dubVal!) : "--")
        }
        return newView
    }
}

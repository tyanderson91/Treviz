//
//  ParamValueView.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/19/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

protocol ParamValueView: NSView {
    var parameter: Parameter! { get set }
    var stringValue: String { get set }
    func update()
}

class ParamValuePopupView: NSPopUpButton, ParamValueView {
    var parameter: Parameter!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override var stringValue: String {
        get { return self.selectedItem!.title }
        set { parameter.setValue(to: newValue) }
    }
    
    func update(){
        if let enumParam = parameter as? EnumGroupParam {
            self.selectItem(withTitle: enumParam.value.valuestr)
        }
    }
}
class ParamValueCheckboxView: NSButton, ParamValueView {
    var parameter: Parameter!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func update(){
        if let boolParam = parameter as? BoolParam {
            if boolParam.value == true {
                self.state = .on
                self.title = "On"
            } else {
                self.state = .off
                self.title = "Off"
            }
        }
        
    }
}
class ParamValueTextView: NSTableCellView, ParamValueView {
    var stringValue: String {
        get { return self.textField!.stringValue }
        set { self.textField!.stringValue = newValue
            parameter.setValue(to: newValue)
        }
    }
    var parameter: Parameter!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func update(){
        if let valParam = parameter as? NumberParam {
            self.textField?.stringValue = valParam.value.valuestr
        } else if let varParam = parameter as? Variable {
            self.textField?.stringValue = varParam.value[0].valuestr
        }
    }
    /*
    override func draw(_ dirtyRect: NSRect) {
        if let valParam = parameter as? NumberParam {
            self.textField?.stringValue = valParam.value.valuestr
        } else if let varParam = parameter as? Variable {
            self.textField?.stringValue = varParam.value[0].valuestr
        }
        super.draw(dirtyRect)
    }*/
}

extension InputsViewController {
    static func paramValueCellView(view: NSTableView, thisInput: Parameter?)->ParamValueTextView?{
        guard thisInput != nil else {return nil}
        let newView = view.makeView(withIdentifier: .paramValueCellView, owner: self) as? ParamValueTextView
        newView?.parameter = thisInput
        var valuestr: String = ""
        if let thisVariable = thisInput as? Variable { valuestr = thisVariable.value[0].valuestr }
        else if let thisVal = thisInput as? NumberParam { valuestr = thisVal.value.valuestr }
        if let textField = newView?.textField {
            textField.stringValue = valuestr
        }
        return newView
    }
    static func paramPopupCellView(view: NSTableView, thisInput: Parameter?)->ParamValuePopupView?{
        guard thisInput != nil else {return nil}
        let newView = view.makeView(withIdentifier: .paramPopupCellView, owner: self) as? ParamValuePopupView
        guard let thisParam = thisInput as? EnumGroupParam else { return nil }
        newView?.removeAllItems()
        newView?.addItems(withTitles: thisParam.options.map({$0.valuestr}))
        newView?.selectItem(withTitle: thisParam.value.valuestr)
        newView?.parameter = thisParam
        return newView
    }
    static func paramCheckboxCellView(view: NSTableView, thisInput: Parameter?)->ParamValueCheckboxView?{
        guard thisInput != nil else {return nil}
        let newView = view.makeView(withIdentifier: .paramCheckboxCellView, owner: self) as? ParamValueCheckboxView
        if let thisInputBool = thisInput as? BoolParam {
            if thisInputBool.value == true {
                newView?.state = .on
                newView?.title = "On"
            } else {
                newView?.state = .off
                newView?.title = "Off"
            }
            newView?.parameter = thisInputBool
            return newView
        }
        else { return nil }
    }

}

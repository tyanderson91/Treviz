//
//  ParamValueView.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/19/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        return first { $0.1 == value }?.0
    }
}

protocol ParamValueView: NSView {
    var parameter: Parameter! { get set }
    var stringValue: String { get set }
    func update()
    var didUpdate: ()->() { get set } // Action to perform after parameter update
}

// MARK: Inputs views
class ParamValueTextField: NSTextField, ParamValueView {
    override var stringValue: String {
        didSet { parameter.setValue(to: super.stringValue) }
    }
    var parameter: Parameter!
    var didUpdate = {}
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func update(){
        if let valParam = parameter as? NumberParam {
            self.stringValue = valParam.value.valuestr
        } else if let varParam = parameter as? Variable {
            self.stringValue = varParam.value[0].valuestr
        }
    }
}

// MARK: RunVariant table views
class ParamValuePopupView: NSPopUpButton, ParamValueView {
    var parameter: Parameter!
    var didUpdate = {}
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     If the view has not already been populated with options, this function will add them automatically based on the EnumGroupParam options. Also selects the currently active option
     */
    func finishSetup(){
        if let enumParam = parameter as? EnumGroupParam {
            if self.numberOfItems <= 1 {
                self.removeAllItems()
                self.addItems(withTitles: enumParam.options.map {$0.valuestr})
            }
            self.selectItem(withTitle: enumParam.stringValue)
        }
    }
    
    override var stringValue: String {
        get { return self.selectedItem!.title }
        set { parameter.setValue(to: newValue) }
    }
    
    func update(){
        if let enumParam = parameter as? EnumGroupParam {
            self.selectItem(withTitle: enumParam.stringValue)
        }
    }
}
class ParamValueCheckboxView: NSButton, ParamValueView {
    var parameter: Parameter!
    var didUpdate = {}
    override var stringValue: String {
        get {
            switch self.state {
            case .on: return "True"
            case .off: return "False"
            default: return "False"
            }
        } set {
            if newValue == "True" { self.state = .on}
            else if newValue == "False" { self.state = .off }
        }
    }
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
    var didUpdate = {}
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
}

//MARK: InputsViewController
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
        newView?.parameter = thisParam
        newView?.removeAllItems()
        newView?.finishSetup()
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

//MARK: Run Variant Trade Groups
extension InputsViewController {
    static func runVariantValueCellView(view: NSTableView, thisVariant: RunVariant?, option: Int)->ParamValueTextView? {
        guard thisVariant != nil else {return nil}
        let newView = view.makeView(withIdentifier: .paramValueCellView, owner: self) as? ParamValueTextView
        guard thisVariant!.tradeValues.count >= option else { return nil }
        let curOption = thisVariant!.tradeValues[option]
        guard let textField = newView?.textField else { return nil }
        if let curVal = curOption?.valuestr {
            textField.stringValue = curVal
        } else {
            textField.stringValue = ""
        }
        return newView
    }
    static func runVariantPopupCellView(view: NSTableView, thisVariant: RunVariant?, option: Int)->ParamValuePopupView? {
        guard thisVariant != nil else {return nil}
        guard thisVariant!.tradeValues.count >= option else { return nil }
        let newView = view.makeView(withIdentifier: .paramPopupCellView, owner: self) as? ParamValuePopupView
        let curOption = thisVariant?.tradeValues[option]
        newView?.removeAllItems()
        newView?.addItems(withTitles: thisVariant!.tradeValues.filter({$0 != nil}).map( {$0!.valuestr }))
        newView?.selectItem(withTitle: curOption!.valuestr)
        return newView
    }
    static func runVariantCheckboxCellView(view: NSTableView, thisVariant: RunVariant?, option: Int)->ParamValueCheckboxView? {
        guard thisVariant != nil else {return nil}
        let newView = view.makeView(withIdentifier: .paramCheckboxCellView, owner: self) as? ParamValueCheckboxView
        if option == 0 {
            newView?.state = .off
            newView?.title = "Off"
        } else if option == 1 {
            newView?.state = .on
            newView?.title = "On"
        } else { return nil }
        return newView
    }
}

class RunVariantTypeView: NSPopUpButton {
    var runVariant: RunVariant!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        for thisType in RunVariantType.allCases {
            self.addItem(withTitle: thisType.rawValue)
        }
    }
    func update(){
        self.selectItem(withTitle: runVariant.variantType.rawValue)
    }
}

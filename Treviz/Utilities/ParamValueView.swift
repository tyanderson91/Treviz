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
    var action: Selector? { get set }
    var target: AnyObject? { get set }
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
        self.refusesFirstResponder = true
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
        self.refusesFirstResponder = true
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
            if newValue == "True" { self.state = .on }
            else if newValue == "False" { self.state = .off }
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.refusesFirstResponder = true
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
    var action: Selector? {
        didSet { textField?.action = self.action }
    }
    var target: AnyObject? {
        didSet { textField?.target = self.target }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.textField?.refusesFirstResponder = true
    }
    func update(){
        if let valParam = parameter as? NumberParam {
            self.textField?.stringValue = valParam.value.valuestr
        } else if let varParam = parameter as? Variable {
            self.textField?.stringValue = varParam.value[0].valuestr
        }
    }
}

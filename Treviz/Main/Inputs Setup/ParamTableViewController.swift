//
//  ParamTableViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/5/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSStoryboardSegue.Identifier{
    static let paramTableViewSegue = "ParamTableViewControllerSegue"
}

class ParamTableViewController: TZViewController , NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    var params : [Parameter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad() // TODO: Figure out which of these I actually need
        NotificationCenter.default.addObserver(self, selector: #selector(self.getAllParams(_:)), name: .didSetParam, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable(_:)), name: .didChangeUnits, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable(_:)), name: .didChangeValue, object: nil)

        // Set parameters
        self.params = self.analysis.parameters
        tableView.reloadData()
    }
    
    @objc func getAllParams(_ notification: Notification){
        // let asys = self.analysis
        self.params = self.analysis.parameters
        tableView.reloadData()
    }

    @objc func updateTable(_ notification: Notification){
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return params.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let thisParam = params[row]
        switch tableColumn?.identifier{
        case NSUserInterfaceItemIdentifier.nameColumn:
            return InputsViewController.nameCellView(view: tableView, thisInput: thisParam)
        case NSUserInterfaceItemIdentifier.paramValueColumn:
            return InputsViewController.paramValueCellView(view: tableView, thisInput: thisParam as? Variable)
        case NSUserInterfaceItemIdentifier.unitsColumn:
            return InputsViewController.unitsCellView(view: tableView, thisInput: thisParam as? Variable)
        default:
            return nil
        }
    }
    
    private func tableView(_ tableView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let thisSetting = item as? Variable{
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn: return thisSetting.name
            case NSUserInterfaceItemIdentifier.paramValueColumn: return thisSetting.value
            case NSUserInterfaceItemIdentifier.unitsColumn: return thisSetting.units
            default: return nil
            }
        }
        if let thisSetting = item as? Parameter{
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn: return thisSetting.name
            default: return nil
            }
        }
        return nil
    }
    
    @IBAction func removeParamPressed(_ sender: Any) {
        let button = sender as! NSView
        let row = tableView.row(for: button)
        var thisParam = params[row]
        thisParam.isParam = false
        tableView.reloadData()
        NotificationCenter.default.post(name: .didSetParam, object: nil)
    }
    
    
    @IBAction func editUnits(_ sender: NSTextField) {
        let curRow = tableView.row(for: sender)
        if var thisParam = analysis.parameters[curRow] as? Variable{
            thisParam.units = sender.stringValue
            NotificationCenter.default.post(name: .didChangeUnits, object: nil)
        }
    }
    
    @IBAction func editValues(_ sender: NSTextField) {
        let curRow = tableView.row(for: sender)
        if var thisParam = analysis.parameters[curRow] as? Variable{
            if let value = VarValue(sender.stringValue) {
                thisParam.value[0] = value}
            NotificationCenter.default.post(name: .didChangeValue, object: nil)
        }
    }
}

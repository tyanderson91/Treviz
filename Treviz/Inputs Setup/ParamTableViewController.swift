//
//  ParamTableViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/5/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class ParamTableViewController: TZViewController , NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    var initStateViewController : InitStateViewController!
    var params : [Parameter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let inputViewController = self.parent as! InputsViewController
        self.initStateViewController = inputViewController.initStateViewController
        NotificationCenter.default.addObserver(self, selector: #selector(self.getAllParams(_:)), name: .didSetParam, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable(_:)), name: .didChangeUnits, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable(_:)), name: .didChangeValue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getAllParams(_:)), name: .didLoadAppDelegate, object: nil)
        
    }
    
    @objc func getAllParams(_ notification: Notification){
        self.params = self.analysis.inputSettings.filter( {$0.isParam} )
        tableView.reloadData()
    }
    
    @objc func paramWasSet(_ notification: Notification){
        //let initStateParams = getParamSettings(from: initStateViewController.inputs)
        //self.params = initStateParams
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
            case NSUserInterfaceItemIdentifier.paramValueColumn: return thisSetting.value//TODO: make logic for inputting various parameter values
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
    
    @IBAction func removeParamPressed(_ sender: Any) {//TODO: move to params table view controller
        let button = sender as! NSView
        let row = tableView.row(for: button)
        var thisParam = params[row]
        thisParam.isParam = false
        tableView.reloadData()
        initStateViewController.outlineView.reloadItem(thisParam)
        NotificationCenter.default.post(name: .didSetParam, object: nil)
    }
}

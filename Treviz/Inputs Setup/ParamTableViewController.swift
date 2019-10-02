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
    var params : [InputSetting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let inputViewController = self.parent as! InputsViewController
        self.initStateViewController = inputViewController.initStateViewController
        NotificationCenter.default.addObserver(self, selector: #selector(self.paramWasSet(_:)), name: .didSetParam, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable(_:)), name: .didChangeUnits, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable(_:)), name: .didChangeValue, object: nil)

        self.loadAllParams()
        tableView.reloadData()
        }
    
    @objc func loadAllParams(){
        let initStateParams = getParamSettings(from: initStateViewController.inputs)
        self.params.append(contentsOf: initStateParams)
    }
    
    @objc func paramWasSet(_ notification: Notification){
        let initStateParams = getParamSettings(from: initStateViewController.inputs)
        self.params = initStateParams
        tableView.reloadData()
    }
    
    @objc func updateTable(_ notification: Notification){
        tableView.reloadData()
    }
    
    func getParamSettings(from settings: [InputSetting], params: [InputSetting] = [])->[InputSetting]{
        var curParam = params
        for thisSetting in settings{
            if thisSetting.itemType != "var"{
                curParam = getParamSettings(from: thisSetting.children, params: curParam)
            }
            else if thisSetting.isParam {
                curParam.append(thisSetting)
            }
        }
        return curParam
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return params.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //initVariables = initState.getVariables()
        let thisVar = params[row]
        
        switch tableColumn?.identifier{
        case NSUserInterfaceItemIdentifier.nameColumn:
            return InputsViewController.nameCellView(view: tableView, thisInput: thisVar)
        case NSUserInterfaceItemIdentifier.paramValueColumn:
            return InputsViewController.paramValueCellView(view: tableView, thisInput: thisVar)
        case NSUserInterfaceItemIdentifier.unitsColumn:
            return InputsViewController.unitsCellView(view: tableView, thisInput: thisVar)
        default:
            return nil
        }
    }
    
    private func tableView(_ tableView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let thisSetting = item as? InputSetting{
            switch tableColumn?.identifier{
            case NSUserInterfaceItemIdentifier.nameColumn: return thisSetting.name
            case NSUserInterfaceItemIdentifier.paramValueColumn: return thisSetting.value//TODO: make logic for inputting various parameter values
            case NSUserInterfaceItemIdentifier.unitsColumn: return thisSetting.units
            default: return nil
            }
        }
        return nil
    }
    
    @IBAction func removeParamPressed(_ sender: Any) {//TODO: move to params table view controller
        let button = sender as! NSView
        let row = tableView.row(for: button)
        let thisInputSetting = params[row]
        thisInputSetting.isParam = false
        tableView.reloadData()
        initStateViewController.outlineView.refreshSetting(thisInputSetting)
        NotificationCenter.default.post(name: .didSetParam, object: thisInputSetting)
    }
}

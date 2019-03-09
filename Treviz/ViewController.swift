//
//  ViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSToolbarDelegate {
    
    var initState = State()

    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var outletLabel1: NSTextField!
    @IBOutlet weak var outletLabel2: NSTextField!
    
    @IBAction func runAnalysisPushed(_ sender: Any) {
        let curAnalysis = Analysis()
        curAnalysis.initialState = initState
        let returnCode = curAnalysis.runAnalysis()
        
        let y_end = curAnalysis.trajectory.last![2]
        let x_end = curAnalysis.trajectory.last![1]
        
    outletLabel1.stringValue = "\(y_end)"
    outletLabel2.stringValue = "\(x_end)"

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let t0 = Variable("t",named: "time",symbol:"t",units:"s",value:0)
        let x0 = Variable("x",named:"X pos",symbol:"x",units:"m",value:0)
        let y0 = Variable("y",named:"Y pos",symbol: "y",units:"m",value:0)
        let dx0 = Variable("dx",named:"X vel",symbol: "ẋ",units:"m/s",value:20)
        let dy0 = Variable("dy",named:"Y vel",symbol: "ẏ",units:"m/s",value:10)
        let m0 = Variable("m",named:"Mass",symbol:"m",units:"kg",value:10)
        
        self.initState.fromVars([t0,x0,y0,dx0,dy0,m0])
        
        //tableView.reloadData()
        }
    
    @IBAction func buttonAddStatePressed(_ sender: Any) {
    }
    @IBAction func buttonRemoveStatePressed(_ sender: Any) {
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return initState.variables.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //initVariables = initState.getVariables()
        let thisVar = initState.variables[row]
        
        if tableColumn?.identifier.rawValue == "nameColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameCell"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = "\(thisVar.name) (\(thisVar.symbol)₀)"
                return thisCell
            }
        }
        else if tableColumn?.identifier.rawValue == "valueColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "valueCell"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = "\(thisVar.value)"
                return thisCell
            }
        }
        else if tableColumn?.identifier.rawValue == "unitsColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "unitsCell"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = thisVar.units
                return thisCell
            }
        }
        return nil
        
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


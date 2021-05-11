//
//  ParamTableViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/5/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

fileprivate extension NSStoryboardSegue.Identifier{
    static let overview = "RunVariantOverviewSegue"
    static let montecarlo = "RunVariantMCSegue"
    static let trades = "RunVariantTradeSegue"
}

extension RunVariant {
    var displayName: String {
        var nameOut = "\(parameter.name)"
        if let thisVar = parameter as? Variable {
            nameOut += " (\(thisVar.symbol!)₀)"
        }
        return nameOut
    }
}

/**
 This is a Tab View Controller that coordinates among the three primary Run Variant Views: Overview, Monte-Carlo, and trades. The functionality for those views are stored in their own View Controllers
 */
class RunVariantViewController: TZViewController {
    
    var params : [Parameter] { return analysis.activeParameters }
    var runVariants: [RunVariant] { return analysis?.runVariants.filter({$0.isActive}) ?? [] }
    var inputsViewController: InputsViewController?
    @IBOutlet weak var numRunsTotalTextField: NSTextField!
    @IBOutlet var numRunsFormatter: NumberFormatter!
    
    var overviewVC: RunVariantOverviewViewController!
    var tradesVC: RunVariantTradesViewController!
    var mcVC: RunVariantMCViewController!
    
    var overviewTableView: NSTableView! { return overviewVC.tableView }
    var tradesTableView: NSTableView! { return tradesVC.groupsDelegate.tableView }
    var mcTableView: NSTableView! { return mcVC.tableView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear() {
        reloadAll()
    }
    
    func reloadAll(){
        overviewTableView.reloadData()
        tradesTableView.reloadData()
        mcTableView.reloadData()
        overviewTableView.sizeToFit()
        mcTableView.sizeToFit()
        tradesTableView.sizeToFit()
        updateNumRuns()
    }
    
    func updateNumRuns(){
        numRunsTotalTextField.stringValue = analysis.numRuns.valuestr
        mcVC.numMCRunsTextField.stringValue = analysis.numMonteCarloRuns.valuestr
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let newVC = segue.destinationController as? TZViewController else { return }
        switch segue.identifier! {
        case .overview:
            overviewVC = (newVC as! RunVariantOverviewViewController)
        case .montecarlo:
            mcVC = (newVC as! RunVariantMCViewController)
        case .trades:
            tradesVC = (newVC as! RunVariantTradesViewController)
        default:
            return
        }
        newVC.analysis = analysis
    }
}

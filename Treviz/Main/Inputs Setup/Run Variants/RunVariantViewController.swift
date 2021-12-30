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

class RunVariantSummaryViewController: NSViewController {
    @IBOutlet var numberFormatter: NumberFormatter!
    @IBOutlet weak var numTextField: NSTextField!
}

/**
 This is a Tab View Controller that coordinates among the three primary Run Variant Views: Overview, Monte-Carlo, and trades. The functionality for those views are stored in their own View Controllers
 */
class RunVariantViewController: CustomSplitViewController {
    var params : [Parameter] { return analysis.activeParameters }
    var runVariants: [RunVariant] { return analysis?.runVariants.filter({$0.isActive}) ?? [] }
    var inputsSplitViewController: InputsSplitViewController?
    var summaryVC: RunVariantSummaryViewController! {
        return splitViewItems.first?.viewController as? RunVariantSummaryViewController
    }
    weak var numRunsTotalTextField: NSTextField! { summaryVC.numTextField }
    var numRunsFormatter: NumberFormatter! { summaryVC.numberFormatter }
    
    var overviewVC: RunVariantOverviewViewController!
    var tradesVC: RunVariantTradesViewController!
    var mcVC: RunVariantMCViewController!
    
    var overviewTableView: NSTableView! { return overviewVC.tableView }
    var tradesTableView: NSTableView! { return tradesVC.groupsDelegate.tableView }
    var mcTableView: NSTableView! { return mcVC.tableView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Load and install all the view controllers from our storyboard in the following order.
        let storyboard = NSStoryboard(name: "RunVariants", bundle: nil)
        
        overviewVC = storyboard.instantiateController(identifier: "overviewVC") { aCoder in
            let ovc = RunVariantOverviewViewController(coder: aCoder, analysis: self.analysis)
            return ovc
        }
        tradesVC = storyboard.instantiateController(identifier: "tradesVC") { aCoder in
            let tvc = RunVariantTradesViewController(coder: aCoder, analysis: self.analysis)
            return tvc!
        }
        mcVC = storyboard.instantiateController(identifier: "montecarloVC") { aCoder in
            let mvc = RunVariantMCViewController(coder: aCoder, analysis: self.analysis)
            return mvc!
        }
        
        self.addViewController(overviewVC)
        self.addViewController(tradesVC)
        self.addViewController(mcVC)
                 
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
}

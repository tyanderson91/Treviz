//
//  SidebarTabViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/5/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation
import AppKit

fileprivate extension NSStoryboardSegue.Identifier {
    static var inputsViewSegue = "inputsViewSegue"
    static var conditionsViewSegue = "conditionsViewSegue"
    static var variantsViewSegue = "variantsViewSegue"
    static var plotSelectorViewSegue = "plotSelectorViewSegue"
}

class SidebarTabViewController: TZViewController {
    @IBOutlet weak var toolbarOffsetConstraint: NSLayoutConstraint!
    var inputsViewController: InputsSplitViewController!
    var plotSelectorViewController: PlotSelectorViewController!
    var outputTabViewController: DynamicTabViewController! {
        didSet {
            self.plotSelectorViewController.tabViewController = self.outputTabViewController
        }
    }
    
    @IBOutlet weak var tabView: NSTabView!
    override func viewDidLoad() {
        //inputsViewController = tabView.tabViewItems.first(where: {$0.viewController is InputsSplitViewController})?.viewController as? InputsSplitViewController
        //self.addChild(inputsViewController)
        //inputsViewController.analysis = self.analysis
        
        super.viewDidLoad()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let newVC = segue.destinationController
        switch segue.identifier! {
        case .inputsViewSegue:
            inputsViewController = newVC as? InputsSplitViewController
            inputsViewController.analysis = self.analysis
        case .conditionsViewSegue:
            let conditionsVC = segue.destinationController as! ConditionsViewController
            conditionsVC.analysis = self.analysis
        case .variantsViewSegue:
            let varVC = segue.destinationController as! RunVariantViewController
            varVC.analysis = self.analysis
        case .plotSelectorViewSegue:
            plotSelectorViewController = segue.destinationController as! PlotSelectorViewController
            plotSelectorViewController.analysis = self.analysis
        default:
            return
        }
    }
}

class SidebarHeaderViewController: NSViewController {
    @IBOutlet var textField: NSTextField!
    var sectionTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.stringValue = sectionTitle
    }
}

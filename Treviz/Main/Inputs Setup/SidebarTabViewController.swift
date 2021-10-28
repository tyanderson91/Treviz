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
}

class SidebarTabViewController: TZViewController {
    @IBOutlet weak var toolbarOffsetConstraint: NSLayoutConstraint!
    var inputsViewController: InputsSplitViewController!
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
        default:
            return
        }
    }
}

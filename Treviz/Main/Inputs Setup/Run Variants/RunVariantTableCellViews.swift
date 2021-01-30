//
//  RunVariantTableCellViews.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/10/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

extension NSUserInterfaceItemIdentifier {
    
    // Basic cell views
    static let rvBasicTextCellView = NSUserInterfaceItemIdentifier.init("basicTextCellView")
    static let rvAddRemoveNameCellView = NSUserInterfaceItemIdentifier.init("addRemoveNameCellView")
    static let rvAddRowButton = NSUserInterfaceItemIdentifier.init("addRowButton")


    // Value cell views
    static let rvTextValueField = NSUserInterfaceItemIdentifier.init("paramValueTextField")
    //static let rvTextValueCellView = NSUserInterfaceItemIdentifier.init("paramValueTextCellView")
    static let rvCheckboxValueCellView = NSUserInterfaceItemIdentifier.init("paramValueCheckboxCellView")
    static let rvPopupValueCellView = NSUserInterfaceItemIdentifier.init("paramValuePopupCellView")

    // Columns
    static let rvNameColumn = NSUserInterfaceItemIdentifier.init("nameColumn")
    static let rvCurValueColumn = NSUserInterfaceItemIdentifier.init("curValueColumn")
    
    static let rvDistributionColumn = NSUserInterfaceItemIdentifier.init("distributionColumn")
    static let rvDistributionParam0Column = NSUserInterfaceItemIdentifier.init("distributionParam0Column")
    static let rvDistributionParam1Column = NSUserInterfaceItemIdentifier.init("distributionParam1Column")
}

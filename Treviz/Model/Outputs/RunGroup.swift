//
//  TradeGroup.swift
//  Treviz
//
//  Created by Tyler Anderson on 12/24/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation
import Cocoa

struct RunGroup {
    var groupDescription: String = ""
    var _didSetDescription: Bool = false
    var runs: [TZRun] = []
    var color: CGColor?
    
    init(){}
    init(name: String) {
        groupDescription = name
    }
    
    
}

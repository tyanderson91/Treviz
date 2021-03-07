//
//  TradeGroup.swift
//  Treviz
//
//  Created by Tyler Anderson on 12/24/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation
import Cocoa

extension CGColor {
    static let teal = CGColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let magenta = CGColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
    static let yellow = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    static let blue = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    static let red = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    static let green = CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
}
class ColorMap {
    var name: String
    var isContinuous: Bool = false
    var colors: [CGColor]
    
    init(name nameIn: String, colors colorsIn: [CGColor]) {
        colors = colorsIn
        name = nameIn
    }
    static var defaultMap = ColorMap(name: "default", colors: [.teal, .magenta, .yellow, .blue, .red, .green])
    static var allMaps: [ColorMap] = [defaultMap]
}

struct RunGroup {
    var groupDescription: String = ""
    var _didSetDescription: Bool = false
    var runs: [TZRun] = []
    var color: CGColor?
}

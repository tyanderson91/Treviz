//
//  CelestialBody.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/27/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation
import Cocoa

/**
 A Celestial body is a planet, moon, asteroid, or some other central body or gravitational source. Anything with a significant gravitational pull, atmosphere, or stable heliocentric orbit could be considered a celestial body
 */
struct CelestialBody: StringValue {
    let name: String
    var icon: NSImage?
    var valuestr: String { return name }
    
    init(name nameIn: String){
        name = nameIn
        if let thisImage = NSImage(named: nameIn.appending("_icon")) { icon = thisImage }
        else { icon = NSImage(named: "Default_cbody_icon") }
    }

    init?(stringLiteral: String) {
        if let match = CelestialBody.allBodies.first(where: {$0.valuestr == stringLiteral}) {
            self = match
        } else { return nil }
    }
    
    static let earth = CelestialBody(name: "Earth")
    static let mars = CelestialBody(name: "Mars")
    static let venus = CelestialBody(name: "Venus")
    static let moon = CelestialBody(name: "Luna")
    static let sun = CelestialBody(name: "Sol")
    static let europa = CelestialBody(name: "Europa")
    
    static let allBodies = [sun, venus, earth, moon, mars, europa]
}

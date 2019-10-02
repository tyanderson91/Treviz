//
//  NotificationCenterSetup.swift
//  Treviz
//
//  Stores setup extensions for Notification Center
//
//  Created by Tyler Anderson on 4/5/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let didSetParam = Notification.Name("didSetParam")
    static let didChangeUnits = Notification.Name("didChangeUnits")
    static let didChangeValue = Notification.Name("didChangeValue")

    static let didAddCondition = Notification.Name("didAddCondition")
    static let didRemoveCondition = Notification.Name("didAddCondition")

    static let didAddPlot = Notification.Name("didAddPlot")
    
    static let didLoadAppDelegate = Notification.Name("didLoadAppDelegate")
}

//
//  MathFuncs.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/6/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

func ** (_ base: Double, _ exp: Double) -> Double {
  return pow(base, exp)
}

func ** (_ base: Float, _ exp: Float) -> Float {
  return pow(base, exp)
}

func ** (_ base: CGFloat, _ exp: Double) -> CGFloat {
  return pow(base, CGFloat(exp))
}

let PI = 3.14159265
func deg2rad(_ deg: VarValue, wrap: Bool = true)->VarValue{
    var radOut = PI/180*deg
    if wrap { radOut = wrapAngle(radOut, isRadian: true) }
    return radOut
}
func rad2deg(_ rad: VarValue, wrap: Bool = true)->VarValue{
    var degOut = 180/PI*rad
    if wrap { degOut = wrapAngle(degOut, isRadian: false) }
    return degOut
}

func wrapAngle(_ angle: VarValue, isRadian: Bool=false)->VarValue{
    var pi: VarValue
    if isRadian { pi = PI }
    else { pi = 180 }
    var angleOut = angle.truncatingRemainder(dividingBy: 2*pi)
    if angleOut > pi { angleOut = angleOut - 2*pi }
    else if angleOut < -pi { angleOut = angleOut + 2*pi }
    return angleOut
}

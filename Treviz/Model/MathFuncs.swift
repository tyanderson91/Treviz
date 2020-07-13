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

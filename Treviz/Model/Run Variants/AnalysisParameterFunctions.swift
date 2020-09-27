//
//  AnalysisParameterFunctions.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/20/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

extension Analysis {
    func enableParam(param: Parameter) {

        if let existingParam = self.runVariants.first(where: {$0.paramID == param.id}) {
            existingParam.isActive = true
        } else {
            if let newRunVariant = type(of: param).paramConstructor(param) {
                self.runVariants.append(newRunVariant)
                newRunVariant.isActive = true
            }
        }
    }
    func disableParam(param: Parameter) {
        if let existingParam = self.runVariants.first(where: {$0.paramID == param.id}) {
            existingParam.isActive = false
        }
    }
}

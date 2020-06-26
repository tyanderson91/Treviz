//
//  OutputDataSet.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/19/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 Structure to contain the number sets that feed into text and plot outputs
 Format varies depending on whether categories and conditions are used
 */
protocol OutputDataSet {
}
struct OutputDataSetLines: OutputDataSet {
    var var1: [VarValue]?
    var var2: [VarValue]?
    var var3: [VarValue]?
    
    subscript(index: Int)->OutputDataSetSingle?{
        let v1 = var1?[index] ?? nil
        let v2 = var2?[index] ?? nil
        let v3 = var3?[index] ?? nil
        return OutputDataSetSingle(var1: v1, var2: v2, var3: v3)
    }
}

struct OutputDataSetSingle: OutputDataSet {
    var var1: VarValue?
    var var2: VarValue?
    var var3: VarValue?
}


/*struct CategoryOutputDataSet: Dictionary<Parameter, OutputDataSet>, OutputDataSet{ //TODO: make Parameter able to be used as a dictionary key. Likely requires PAT: https://www.youtube.com/watch?v=XWoNjiSPqI8&feature=youtu.be
    
}*/

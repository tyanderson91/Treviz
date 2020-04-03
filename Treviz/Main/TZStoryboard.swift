//
//  TZStoryboard.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/2/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSStoryboard {
    func initViewController(identifier: NSStoryboard.SceneIdentifier, with analysis: Analysis)->TZViewController{
        self.instantiateController(identifier: identifier, creator: { aDecoder in
            return TZViewController(coder: aDecoder, analysis: analysis)
        })
    }
}

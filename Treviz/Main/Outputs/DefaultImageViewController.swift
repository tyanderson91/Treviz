//
//  DefaultImageViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 1/1/22.
//  Copyright © 2022 Tyler Anderson. All rights reserved.
//

import Cocoa

class DefaultImageViewController: NSViewController {
    @IBOutlet var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer!.backgroundColor = .black
    }
}

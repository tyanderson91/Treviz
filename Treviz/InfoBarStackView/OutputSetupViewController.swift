/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View Controller controlling the NSStackView.
 */

import Cocoa

extension NSStoryboardSegue.Identifier{
    static let variableSelectorSegue = "variableSelectorSegue"
}

class OutputSetupViewController: ViewController {
    
    @IBOutlet weak var stack: CustomStackView!
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Have the stackView strongly hug the sides of the views it contains.
        stack.parent = self
        stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)

        // Load and install all the view controllers from our storyboard in the following order.
        stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "SingleAxisOutputSetupViewController")
        stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "TwoAxisOutputSetupViewController")
        stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "ThreeAxisOutputSetupViewController")
        stack.addViewController(fromStoryboardId: "OutputSetup", withIdentifier: "MonteCarloOutputSetupViewController")

        
        //addViewController(withIdentifier: "CollectionViewController")
        //addViewController(withIdentifier: "OtherViewController")
    }

}

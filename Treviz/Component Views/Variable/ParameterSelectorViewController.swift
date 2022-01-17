//
//  VariableSelectorViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/23/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 Protocol adopted by view controllers that house a variable selector that must respond to changes
 */
protocol ParamGetter {
    func paramDidChange(_ sender: ParameterSelectorViewController)
}

fileprivate extension Analysis {
    var hasTradeGroup: Bool { self.useGroupedVariants && self.numTradeGroups>1 }
}

class ParameterSelectorViewController: TZViewController {

    @IBOutlet weak var paramSelectorPopup: NSPopUpButton!
    var selectedParameter : Parameter? {
        didSet {
            guard selectedParameter != nil else { return }
            if let thisIndex = paramList?.firstIndex(where: {$0.id == self.selectedParameter!.id }) {
                selectedParameter = paramList?[thisIndex]
                paramSelectorPopup?.selectItem(at: thisIndex+1)
            }
        }
    }
    var onlyVars: Bool = false
    var paramList: [Parameter]! {
        if onlyVars { return analysis.varList }
        else {
            var _paramList = analysis.inputSettings
            if analysis.hasTradeGroup {
                _paramList.append(TradeGroupParam())
            }
            return _paramList
        }
    }
    var paramGetter: ParamGetter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadParams()
        if selectedParameter != nil {
            selectParam(with: selectedParameter!.id)
        } else if analysis.hasTradeGroup {
            paramSelectorPopup.selectItem(withTitle: TradeGroupParam().name)
        }
    }
    
    func loadParams(){
        paramSelectorPopup.addItem(withTitle: "")
        paramSelectorPopup.addItems(withTitles: paramList.compactMap { $0.name } )
        if analysis.hasTradeGroup {
            guard let menu = paramSelectorPopup.menu else { return }
            menu.insertItem(NSMenuItem.separator(), at: menu.items.count-1)
            //let A = paramList
        }
    }
    
    func addParams(_ notification: NSNotification){
        loadParams()
    }
    
    func deselectAll(){
        selectedParameter = nil
        paramSelectorPopup.select(nil)
    }
    
    @IBAction func didSelectParam(_ sender: Any) {
        if let button = sender as? NSPopUpButton {
            let selectedItem = button.titleOfSelectedItem
            if button.indexOfSelectedItem > 0 {
                selectedParameter = paramList.first(where: { $0.name == selectedItem })
            } else {
                selectedParameter = nil
            }
        }
        if paramGetter != nil { paramGetter!.paramDidChange(self) }
        else if let parentGetter = parent as? ParamGetter { parentGetter.paramDidChange(self) }
    }
    
    func selectParam(with id: ParamID?){
        if let thisVarIndex = paramList?.firstIndex(where: {$0.id == id }) {
            selectedParameter = paramList?[thisVarIndex]
        }
    }
}

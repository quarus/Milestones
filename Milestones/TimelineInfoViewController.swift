//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  TimelineInfoViewController.swift
//  Milestones
//
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class TimelineInfoViewController:
    NSViewController,
    NSTextFieldDelegate,
    NSTextViewDelegate,
    StateObserverProtocol
{
    
    @IBOutlet weak var nameTextField: NSTextField?
    @IBOutlet var descriptionTextView: NSTextView?
    @IBOutlet weak var colorWell: NSColorWell?
    
    var currentTimeline :Timeline?
    
    override var representedObject: Any? {
        
        willSet {
            dataModel()?.remove(dataObserver: self)
        }
        
        didSet {
            dataModel()?.add(dataObserver: self)
        }
    }
    
    private func dataModel() -> StateProtocol? {
        
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        let dependencies = representedObject as? AnyObject as? Dependencies
        return dependencies?.stateModel
    }

    private func update() {
        guard let model = dataModel() else {return}
        
        if (model.selectedTimelines.count == 1) {
            enableUIElements()
            currentTimeline = model.selectedTimelines[0]
        } else {
            disableUIElements()
            return
        }
        
        if currentTimeline == nil  {
            
            nameTextField?.stringValue = "Neue Timeline"
            descriptionTextView?.string = " "
            
        } else {
            
            nameTextField?.stringValue = currentTimeline!.name ?? "No Name"
            descriptionTextView?.string = currentTimeline!.info ?? " "
            descriptionTextView?.checkTextInDocument(nil)
            colorWell?.color = currentTimeline!.color ?? NSColor.red
        
        }
    }
    
    func enableUIElements() {
        nameTextField?.isEnabled = true
        descriptionTextView?.isEditable = true
        colorWell?.isEnabled = true
    }
    
    func disableUIElements() {
        nameTextField?.isEnabled = false
        descriptionTextView?.isEditable = false
        colorWell?.isEnabled = false
    }
    
    //MARK: View life cycle
    override func viewWillAppear() {
    }
    
    override func viewDidAppear() {
        update()
    }

    //MARK: DataProtocol
    func didChangeSelectedMilestone(_ milestone: Milestone?) {}
    func didChangeZoomLevel(_ level: ZoomLevel) {}
    func didChangeSelectedGroup(_ group: Group?) {}
    
    func didChangeSelectedTimeline(_ selectedTimelines :[Timeline]) {
        update()
    }
    

    //MARK: NSTextFieldDelegate
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        //Prevent the user from entering an empty name for a timeline
        if control == nameTextField {
            
            if nameTextField?.stringValue.count == 0 {
                return false
            } else {
                currentTimeline?.name = nameTextField?.stringValue
                return true
            }
        }
        
        return true
    }
    
    //MARK: NSTextDelegate (used for NSTextView)
    func textDidEndEditing(_ notification: Notification) {
        currentTimeline?.info = descriptionTextView?.string
    }
    
    //MARK: Color Change Callback
    @IBAction func onColorDidChange(_ sender: Any) {
        currentTimeline?.color = colorWell?.color
    }
    

}


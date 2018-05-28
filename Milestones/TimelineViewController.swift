//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  TimelineViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

protocol TimelineModelProtocol {
    
    var moc :NSManagedObjectContext? {get set}
    var timeline: Timeline? {get set}
    var activeGroup: Group? {get set}
}

class TimelineModel: TimelineModelProtocol {
    
    var moc :NSManagedObjectContext?
    var timeline: Timeline?
    var activeGroup: Group?
}

class TimelineViewController :NSViewController  {
    
    @IBOutlet weak var nameEntry: NSTextField!
    @IBOutlet weak var colorPicker: NSColorWell!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var OKButton: NSButton!
    @IBOutlet weak var infoEntry: NSTextView!
    
    func dataModel() -> TimelineModelProtocol? {
        
        return representedObject as? TimelineModelProtocol
    }
    
    func setup() {
        guard let model = dataModel() else {return}
        let timeline = model.timeline
        
        if timeline == nil  {

            nameEntry.stringValue = "Neue Timeline"
            infoEntry.string = " "
        
        } else {
            
            nameEntry.stringValue = timeline!.name ?? "No Name"
            infoEntry.string = timeline!.info ?? " "
            colorPicker.color = timeline!.color ?? NSColor.red

        }
    }
    
    //MARK: View life cycle
    override func viewWillAppear() {
        setup()
    }
    
    override func viewWillDisappear() {
    }
    
    
    //MARK: UI Callbacks & more
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        
        handleCancel()
        dismiss(self)
    }
    
    @IBAction func onOKButtonClicked(_ sender: Any) {
        
        handleOK()
        dismiss(self)
    }
    
    @IBAction func onColorDidChange(_ sender: Any) {
    }
    
    func handleOK() {
        
        guard let model = dataModel() else {return}
        let timeline = model.timeline

        if timeline == nil {

            guard let moc = model.moc else {return}
            let newTimeline = NSEntityDescription.insertNewObject(forEntityName: "Timeline", into: moc) as! Timeline
            
            newTimeline.name = nameEntry.stringValue
            newTimeline.color = colorPicker.color
            newTimeline.info = infoEntry.string
            
            if let group = model.activeGroup {
                newTimeline.addGroup(aGroup: group)
            }

        } else {
            
            timeline!.name = nameEntry.stringValue
            timeline!.info = infoEntry.string
            timeline!.color = colorPicker.color
        }

        model.moc?.processPendingChanges()
    }
    
    func handleCancel() {
    }
    
    //MARK: NSTextFieldDelegate
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        return true
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        //Prevent the user from entering an empty name for a timeline
        if control == nameEntry {
            
            if nameEntry.stringValue.count == 0 {
                
                return false
            }
        }
        return true
    }
    
    //MARK: NSObject Notifications
    override func controlTextDidBeginEditing(_ obj: Notification) {
        
    }
    override func controlTextDidEndEditing(_ obj: Notification) {
        
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        
        if (obj.object as? NSTextField) === nameEntry {
            
            if nameEntry.stringValue.count == 0 {
                
                OKButton.isEnabled = false
            } else {
                
                OKButton.isEnabled = true
            }
        }
    }
    
}

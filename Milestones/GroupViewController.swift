//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  GroupViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

protocol GroupViewControllerModelProtocol {

    var moc :NSManagedObjectContext? {get set}
    var group :Group? {get set}
}

class GroupViewControllerModel: GroupViewControllerModelProtocol {
    
    var moc: NSManagedObjectContext?
    var group: Group?
}

class GroupViewController: NSViewController {
   
    @IBOutlet weak var nameEntry: NSTextField!
    @IBOutlet weak var infoEntry: NSTextView!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var OKButton: NSButton!
    
    func dataModel() -> GroupViewControllerModelProtocol? {
        
        return representedObject as? GroupViewControllerModelProtocol
    }

    func setup() {
        guard let model = dataModel() else {return}
        let group = model.group
        
        if group == nil  {
            nameEntry.stringValue = "Neue Gruppe"

        } else {
            nameEntry.stringValue = group?.name ?? "No Name"
            infoEntry.string = group?.exportInfo?.info ?? ""
            infoEntry.checkTextInDocument(nil)
        }
    }
    
    //MARK: View life cycle
    override func viewWillAppear() {
        setup()
    }
    
    override func viewWillDisappear() {
        guard let model = dataModel() else {return}
        model.group?.exportInfo?.info = infoEntry.string
        model.group?.name = nameEntry.stringValue
        
    }

    //MARK: UI Callbacks & more

    @IBAction func onOKButtonClicked(_ sender: Any) {
        handleOK()
        dismiss(self)
    }
    
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        dismiss(self)
    }
    
    
    func handleOK() {
        
        guard let model = dataModel() else {return}
        
        if model.group == nil {
        
            guard let moc = model.moc else {return}
            let newGroup = NSEntityDescription.insertNewObject(forEntityName: "Group", into: moc) as! Group
            newGroup.name = nameEntry.stringValue
            
        } else {
        
            model.group!.name = nameEntry.stringValue
        }
        
        model.moc?.processPendingChanges()

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
    
    
    //MARK: NSTextDelegate (used for NSTextView)
    func textDidEndEditing(_ notification: Notification) {
        
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

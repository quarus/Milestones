//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  GroupsmanagementViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa


class GroupsManagementModel :NSObject, GroupsManagementModelProtocol {
    
    @objc dynamic var selectedGroup: Group?
    var selectedTimeline: Timeline?
    var managedObjectContext: NSManagedObjectContext?
}


class GroupsmanagementViewController :NSViewController {

    var originalManagedObjectContext: NSManagedObjectContext?
    
    private var model: GroupsManagementModelProtocol = GroupsManagementModel()
    
    private func newContextInThread() -> NSManagedObjectContext? {
    
        guard let originalMoc = self.originalManagedObjectContext else {return nil}
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = originalMoc
        return moc
        
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    
        guard let segueID = segue.identifier?.rawValue else {return}
        
        switch segueID {
            
        case "GroupsManagementSplitView":
            guard let destinationViewController = segue.destinationController as? SplitViewController else {return}
            
            model.managedObjectContext = newContextInThread()
            model.selectedGroup = nil
            destinationViewController.representedObject = model

            break
        default:
            break
        }
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        //Save the changes to the main context
        model.managedObjectContext?.performAndWait {
            
            do {
                try self.model.managedObjectContext?.save()
            } catch {
                fatalError("Error while saving Managed Object Context")
            }
        }
        self.dismiss(nil)
    }
    
    //MARK: View life cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        //Autosave name apparently needs to be set manually, otherwise it won't work

    }
}

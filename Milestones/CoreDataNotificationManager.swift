//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  ViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

protocol CoreDataNotificationManagerDelegate {
    
    func handleInsertion(ofObjects: NSSet)
    func handleUpdate(ofObjects: NSSet)
    func handleRemoval(ofObjects: NSSet)
}

class CoreDataNotificationManager {
    
    var delegate :CoreDataNotificationManagerDelegate?
    
    private var hasMocNotificationObserving = false
    
    deinit {
        deregisterForMOCNotifications()
    }
    
    //MARK: NSManagedObjectContext Notification Handling
    func registerForNotificationsOn(moc :NSManagedObjectContext?) {
        
        if !hasMocNotificationObserving {
            
            hasMocNotificationObserving = true
            
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleMocNotifications),
                                                   name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                                   object: moc)
        }
    }
    
    func deregisterForMOCNotifications() {
        
        if hasMocNotificationObserving {
            
            hasMocNotificationObserving = false
            
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc private func handleMocNotifications(aNotification :Notification) {

        guard let aDict = aNotification.userInfo else {return}
        
        //Were any objects inserted?
        if let insertedObjects = aDict[NSInsertedObjectsKey] as? NSSet {
            delegate?.handleInsertion(ofObjects: insertedObjects)
        }
        
        if let updatedObjects = aDict[NSUpdatedObjectsKey] as? NSSet {
            delegate?.handleUpdate(ofObjects: updatedObjects)
        }
        
        if let deletedObjects = aDict[NSDeletedObjectsKey] as? NSSet {
            delegate?.handleRemoval(ofObjects:  deletedObjects)
        }
    }
}

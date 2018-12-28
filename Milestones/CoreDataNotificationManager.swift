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
    
    func managedObjectContext(_ moc: NSManagedObjectContext, didInsertObjects objects: NSSet)
    func managedObjectContext(_ moc: NSManagedObjectContext, didUpdateObjects objects: NSSet)
    func managedObjectContext(_ moc: NSManagedObjectContext, didRemoveObjects objects: NSSet)
}

class CoreDataNotificationManager {
    
    var delegate :CoreDataNotificationManagerDelegate?
    
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext moc: NSManagedObjectContext) {
        managedObjectContext = moc
        registerForNotificationsOn(moc: moc)
    }
    
    deinit {
        deregisterForMOCNotifications()
    }
    
    //MARK: NSManagedObjectContext Notification Handling
    private func registerForNotificationsOn(moc :NSManagedObjectContext?) {
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(handleMocNotification),
                                                name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                                object: moc)
    }
    
    private func deregisterForMOCNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleMocNotification(aNotification :Notification) {

        guard let aDict = aNotification.userInfo else {return}
        let moc = aNotification.object as! NSManagedObjectContext
        
        if let insertedObjects = aDict[NSInsertedObjectsKey] as? NSSet {
            delegate?.managedObjectContext(moc, didInsertObjects: insertedObjects)
        }
        if let updatedObjects = aDict[NSUpdatedObjectsKey] as? NSSet {
            delegate?.managedObjectContext(moc, didUpdateObjects: updatedObjects)
        }
        if let deletedObjects = aDict[NSDeletedObjectsKey] as? NSSet {
            delegate?.managedObjectContext(moc, didRemoveObjects: deletedObjects)
        }
    }
}

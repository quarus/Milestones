//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// DataModel.swift
// Milestones
//
// Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class StateModel : StateProtocol {
    
    
    var hasNotificationObserving = false
    
   
    var zoomLevel: ZoomLevel = .week{
        didSet {
            notifyObserversAboutZoomLevelChange()
        }
    }

    var selectedGroup :Group? {
        didSet {
            
            selectedTimelines.removeAll()
            notifyObserversAboutGroupChange()
        }
    }
    
    var selectedTimelines :[Timeline] = [Timeline]() {
        didSet {
            notifyObserversAboutTimelineSelectionChange()
        }
    }

    var selectedMilestone :Milestone? {
        didSet {
            notifyObserversAboutMilestoneSelectionChange()
        }
    }
    var managedObjectContext :NSManagedObjectContext

    
    func documentInfo() -> DocumentInfo? {
        
        var documentInfo: DocumentInfo?
        
        //Check if there is already an DocumentInfo in this object.
        let fetchRequest: NSFetchRequest<DocumentInfo> = DocumentInfo.fetchRequest()
        guard let fetchedDocumentInfo: [DocumentInfo] = try? managedObjectContext.fetch(fetchRequest) else {return documentInfo}
        
        if (fetchedDocumentInfo.count > 0) {
            documentInfo = fetchedDocumentInfo[0]
        } else {
            //there is no Documentinfo Object. We assume that this is because the document has been newly created.
            documentInfo = (NSEntityDescription.insertNewObject(forEntityName: "DocumentInfo", into: managedObjectContext) as! DocumentInfo)
            //Also let's create an initial group in order to let the user create timelines right away
            let initialGroup = NSEntityDescription.insertNewObject(forEntityName: "Group", into: managedObjectContext) as! Group
            initialGroup.name = "Erste Gruppe"            
        }
        
        return documentInfo
    }
    
    private let dataObservers :NSMutableArray = NSMutableArray()
    
    init(moc :NSManagedObjectContext) {
    
        managedObjectContext = moc
        registerNotifications()
    }
    
    deinit {
        deregisterNotifications()
    }
    
    func allGroups() -> [Group]{
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var fetchResult :[Group]?
        do {
        
            fetchResult = try managedObjectContext.fetch(fetchRequest)
            return fetchResult!
        
        } catch {
        }
        
        return [Group]()
    }

    private func resetActiveGroup() {

        var groups = allGroups()
        if (groups.count > 0) {

            selectedGroup = groups[0]
        } else {
            selectedGroup = nil
        }

    }

 /*
    private func allTimelines() -> [CTimeline]{

        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let fetchRequest: NSFetchRequest<CTimeline> = CTimeline.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var fetchResult :[CTimeline]?
        do {
        
            fetchResult = try managedObjectContext.fetch(fetchRequest)
            return fetchResult!
            
        } catch {
        }
        
        return [CTimeline]()
    }*/
/*
    private func allMilestonesFor(timelines :[CTimeline]) -> NSMutableArray {

        let accumulatedMilestones :NSMutableArray = NSMutableArray()

        for aTimeline in timelines {
            
            if let timelineMilestones = aTimeline.milestones?.allObjects as? [Milestone] {
                accumulatedMilestones.addObjects(from: timelineMilestones)
            }
        }
        
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        accumulatedMilestones.sort(using: [sortDescriptor])
        
        return accumulatedMilestones
    }
    */

    //MARK: Notification Handling
    func registerNotifications() {
        
        if !hasNotificationObserving {
            
            hasNotificationObserving = true
            
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleMocNotifications),
                                                   name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                                   object: managedObjectContext)


           NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleMilestoneClickNotification),
                                                   name: Notification.Name(rawValue: MILESTONE_SELECTED_NOTIFICATION),
                                                   object: nil)

        }
    }
    
    func deregisterNotifications() {
        
        if hasNotificationObserving {
            
            hasNotificationObserving = false
            
            NotificationCenter.default.removeObserver(self)
        }
    }

    @objc func handleMilestoneClickNotification(aNotification :Notification) {

        guard let aDict = aNotification.userInfo else {return}
        if let clickedMilestone = aDict[MILESTONE_SELECTED_NOTIFICATION_PAYLOAD_KEY] as? Milestone {

            guard let timeline = clickedMilestone.timeline else {return}
            //only change the selected timeline when it is not already selected
            if (!selectedTimelines.contains(timeline)) {
                selectedTimelines = [timeline]
            } 
            selectedMilestone = clickedMilestone

        }
    }

    @objc func handleMocNotifications(aNotification :Notification) {

        guard let aDict = aNotification.userInfo else {return}

        //Were any objects inserted?
        if let insertedObjects = aDict[NSInsertedObjectsKey] as? NSSet {

            for anObject in insertedObjects{

                if (anObject is Group) {

                    if selectedGroup == nil {

                        resetActiveGroup()
                    }

                } else if (anObject is Milestone) {
                } else if (anObject is Timeline) {
                }
            }
        }

        //Were any objects deleted?
        if let deletedObjects = aDict[NSDeletedObjectsKey] as? NSSet {

            for anObject in deletedObjects {

                if let deletedGroup = anObject as? Group {
                    if deletedGroup == selectedGroup {

                        resetActiveGroup()
                    }

                } else if (anObject is Milestone) {
                } else if (anObject is Timeline) {
                }
            }
        }

        //Were any objects updated?
        if let updatedObjects = aDict[NSUpdatedObjectsKey] as? NSSet{
            for anObject in updatedObjects {

                if (anObject is Group) {
                } else if (anObject is Timeline) {
                } else if (anObject is Milestone) {
                }
            }
        }
    }



    func add(dataObserver :StateObserverProtocol) {
        
        if !dataObservers.contains(dataObserver) {
            dataObservers.add(dataObserver)
        }
    }
    
    func remove(dataObserver :StateObserverProtocol) {
        
        if dataObservers.contains(dataObserver) {
            dataObservers.remove(dataObserver)
        }
    }

    //MARK: Messaging
    
    private func notifyObserversAboutZoomLevelChange() {
        for anObserver in dataObservers {
            if let observer = anObserver as? StateObserverProtocol {
                observer.didChangeZoomLevel(zoomLevel)
            }
        }
    }
    
    private func notifyObserversAboutGroupChange() {
        for anObserver in dataObservers {
            if let observer = anObserver as? StateObserverProtocol {
                observer.didChangeSelectedGroup(selectedGroup)
            }
        }
    }

    private func notifyObserversAboutTimelineSelectionChange() {
        for anObserver in dataObservers {
            if let observer = anObserver as? StateObserverProtocol {
                observer.didChangeSelectedTimeline(selectedTimelines)
            }
        }
    }

    private func notifyObserversAboutMilestoneSelectionChange() {
        for anObserver in dataObservers {
            if let observer = anObserver as? StateObserverProtocol {
                observer.didChangeSelectedMilestone(selectedMilestone)
            }
        }
    }

}

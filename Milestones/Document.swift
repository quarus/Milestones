//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Document.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Cocoa

class Document: NSPersistentDocument {
    
    var dataModel :StateModel?
    var windowController :NSWindowController?
    
    private var MOCHandler = CoreDataNotificationManager()
    
    override init() {
        
        super.init()
        
        let undoManager = self.managedObjectContext?.undoManager
        let persistentStoreCoordinator = self.managedObjectContext?.persistentStoreCoordinator
        
        let newContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        newContext.persistentStoreCoordinator = persistentStoreCoordinator
        newContext.undoManager = undoManager
        
        self.managedObjectContext = newContext
        
        if let moc = managedObjectContext {
            dataModel = StateModel(moc: moc)
            MOCHandler.registerForNotificationsOn(moc: moc)
            
        }
    }
    
    deinit {
        MOCHandler.deregisterForMOCNotifications()
    }
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    
    override func makeWindowControllers() {

        //Prepopulation is called here, because apparently the document is only fully loaded here
        prepopulateDocumentIfNeeded()


        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "MainStoryboard"), bundle: nil)
        windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainWindowController")) as? NSWindowController
        
        //A WindowController only has a valid document after the following call
        addWindowController(windowController!)
        
        //Select the (alphabetically) first group, 
        if let groups = dataModel?.allGroups() {
            if groups.count > 0 {
                dataModel?.selectedGroup = groups[0]
            }
        }
        
        
    }
    //MARK: Helper functions
    func prepopulateDocumentIfNeeded() {
        
        guard let moc = managedObjectContext else {return}
        //Check if there is already an DocumentInfo in this object.
        let fetchRequest: NSFetchRequest<DocumentInfo> = DocumentInfo.fetchRequest()
        var count = 0
        do {
            try count = moc.count(for: fetchRequest)
        } catch {
        }

        if (count == 0) {
        
            //there is no Documentinfo Object. We assume that this is because the document has been newly created.
            let documentInfo = NSEntityDescription.insertNewObject(forEntityName: "DocumentInfo", into: moc) as! DocumentInfo
            //Also let's create an initial group in order to let the user create timelines right away
            let initialGroup = NSEntityDescription.insertNewObject(forEntityName: "Group", into: moc) as! Group
            initialGroup.name = "Erste Gruppe"
        }
    }
    
    //MARK: Managed Object Context Change Handling
    func handleInsertion(ofObjects: NSSet){}
    func handleUpdate(ofObjects: NSSet){}
    func handleRemoval(ofObjects: NSSet){}
    
    
    
}


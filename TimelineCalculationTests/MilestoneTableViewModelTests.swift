//
//  MilestoneTableViewModelTests.swift
//  TimelineCalculationTests
//
//  Created by Altay Cebe on 23.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import XCTest
import CoreData

class DataController: NSObject {
    let persistentContainer: NSPersistentContainer
    
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completionClosure()
        }
    }
}

class MilestoneTableViewModelTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!
    let dataController: DataController = DataController(completionClosure: {
        print("DataController ready")
    })
 
    override func setUp() {
        managedObjectContext =  NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = dataController.persistentContainer.persistentStoreCoordinator
    }

    override func tearDown() {
    }
    
    func testStub() {
        let newTimeline = NSEntityDescription.insertNewObject(forEntityName: "Timeline", into: managedObjectContext)
        let newMilestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone", into: managedObjectContext)
    }
    
    func test2 () {
        
    }
}

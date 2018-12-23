//
//  MilestoneTableViewModelTests.swift
//  TimelineCalculationTests
//
//  Created by Altay Cebe on 23.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import XCTest
import CoreData
@testable import Milestones

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
 
    func prePopulate() {
        let newTimeline = NSEntityDescription.insertNewObject(forEntityName: "Timeline",
                                                              into: managedObjectContext) as! Timeline
        newTimeline.name = "Timeline 1"
        
        let firstMilestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone",
                                                                 into: managedObjectContext) as! Milestone
        firstMilestone.name = "Milestone 1"
        firstMilestone.date = Date().normalized()
        firstMilestone.timeline = newTimeline
        
        let secondMilestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone",
                                                                 into: managedObjectContext) as! Milestone
        secondMilestone.name = "Milestone 2"
        secondMilestone.date = Date().normalized()
        secondMilestone.timeline = newTimeline

        let thirdMilestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone",
                                                                  into: managedObjectContext) as! Milestone
        thirdMilestone.name = "Milestone 3"
        thirdMilestone.date = Date().normalized()
        thirdMilestone.timeline = newTimeline
    }
    
    override func setUp() {
        managedObjectContext =  NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = dataController.persistentContainer.persistentStoreCoordinator
        prePopulate()
    }

    override func tearDown() {
    }
    
    func testStub() {
    }
    
    func test2 () {
        
    }
}

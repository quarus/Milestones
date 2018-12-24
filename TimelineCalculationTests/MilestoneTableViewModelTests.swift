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
//        prePopulate()
    }

    override func tearDown() {
    }
    
    func testMilestoneCellModelCreation() {
        
        let milestoneDate = Date.dateFor(year: 2018, month: 12, day: 24, hour: 14, minute: 23, second: 10)
        
        let milestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone",
                                                                 into: managedObjectContext) as! Milestone
        milestone.name = "Milestone 1"
        milestone.date = milestoneDate
        
        let milestoneCellModel = MilestoneCellModel(milestone :milestone)
        XCTAssertEqual("24.12.2018", milestoneCellModel.dateString)
        XCTAssertEqual("KW 52.1/18", milestoneCellModel.cwString)
        XCTAssertEqual("Milestone 1", milestoneCellModel.nameString)
        XCTAssertEqual("", milestoneCellModel.timeIntervallString)
        XCTAssertEqual(false, milestoneCellModel.needsExpandedCell)
    }
    
    func testMilestoneCellModelCreationWithSuccessor() {
        let firstMilestoneDate = Date.dateFor(year: 2018, month: 6, day: 12, hour: 17, minute: 50, second: 22)
        let closeMilestoneDate =  Date.dateFor(year: 2018, month: 6, day: 13, hour: 12, minute: 22, second: 59)
        let distantMilestoneDate = Date.dateFor(year: 2018, month: 12, day: 24, hour: 14, minute: 23, second: 10)

        let milestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone",
                                                            into: managedObjectContext) as! Milestone
        milestone.date = firstMilestoneDate
        milestone.name = "Erster Meilenstein"
        
        let distantMilestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone",
                                                             into: managedObjectContext) as! Milestone
        distantMilestone.date = distantMilestoneDate
        
        var milestoneCellModel = MilestoneCellModel(milestone: milestone, nextMilestone: distantMilestone)
        XCTAssertEqual("12.06.2018", milestoneCellModel.dateString)
        XCTAssertEqual("KW 24.2/18", milestoneCellModel.cwString)
        XCTAssertEqual("Erster Meilenstein", milestoneCellModel.nameString)
        XCTAssertNotEqual("",milestoneCellModel.timeIntervallString)
        XCTAssertEqual(true, milestoneCellModel.needsExpandedCell)
        
        let closeMilestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone",
                                                                   into: managedObjectContext) as! Milestone
        closeMilestone.date = closeMilestoneDate
        
        milestoneCellModel = MilestoneCellModel(milestone: milestone, nextMilestone: closeMilestone)
        XCTAssertEqual("12.06.2018", milestoneCellModel.dateString)
        XCTAssertEqual("KW 24.2/18", milestoneCellModel.cwString)
        XCTAssertEqual("Erster Meilenstein", milestoneCellModel.nameString)
        XCTAssertEqual("",milestoneCellModel.timeIntervallString)
        XCTAssertEqual(false, milestoneCellModel.needsExpandedCell)
        
    }
}

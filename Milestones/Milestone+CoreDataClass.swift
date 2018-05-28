//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// CMilestone+CoreDataClass.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation
import CoreData


class Milestone: NSManagedObject {

    override func awakeFromInsert() {
        name = "New Milestone"
        info = ""
        date = Date().normalized()
        showAdjustments = NSNumber(value: false)
    }

    func addAdjustment(anAdjustment :Adjustment) {
        self.mutableOrderedSetValue(forKey: "adjustments").add(anAdjustment)
    }

    func removeAdjustment(anAdjustment :Adjustment) {
        self.mutableOrderedSetValue(forKey: "adjustments").remove(anAdjustment)
    }
}

extension Milestone {
    
    func markAdjustment() -> Adjustment? {

        guard let moc = self.managedObjectContext else {return nil}
        
        let newAdjustment = NSEntityDescription.insertNewObject(forEntityName: "Adjustment", into: moc) as! Adjustment
        let newMilestone = NSEntityDescription.insertNewObject(forEntityName: "Milestone", into: moc) as! Milestone
        
        
        newAdjustment.date = date

        newMilestone.name = name
        newMilestone.info = info
        newMilestone.date = Date().normalized()
        newMilestone.type = type
        newAdjustment.trackedMilestone = newMilestone

        addAdjustment(anAdjustment: newAdjustment)
        
        return newAdjustment
    }
    
    
    func timeintervalSinceMilestone(_ milestone: Milestone) -> TimeInterval? {
        guard let ownDate = self.date else {return nil}
        guard let givenDate = milestone.date else {return nil}
        
        return ownDate.timeIntervalSince(givenDate)
    }
}





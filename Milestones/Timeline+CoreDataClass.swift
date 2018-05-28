//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// CTimline+CoreDataClass.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//


import Foundation
import CoreData
import Cocoa

class Timeline: NSManagedObject {



    func removeMilestone(aMilestone :Milestone) {
        self.mutableSetValue(forKey: "milestones").remove(aMilestone)
    }
    
    func addMilestone(aMilestone :Milestone) {
        self.mutableSetValue(forKey: "milestones").add(aMilestone)
    }

    func addGroup(aGroup :Group) {
        self.mutableSetValue(forKey: "groups").add(aGroup)
    }

    func removeGroup(aGroup :Group) {
        self.mutableSetValue(forKey: "groups").remove(aGroup)
    }
    
    override func awakeFromInsert() {
        name = "New Timeline"
        info = " "
    }

    func milestonesOrderedByDate() -> [Milestone]? {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let orderedMilestones = self.milestones?.sortedArray(using: [sortDescriptor])
        return orderedMilestones as? [Milestone]

    }
}



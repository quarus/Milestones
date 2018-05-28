//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// CMilestone+CoreDataProperties.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation
import CoreData

extension Milestone {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Milestone> {
        return NSFetchRequest<Milestone>(entityName: "Milestone");
    }

    @NSManaged var showAdjustments :NSNumber?
    @NSManaged private var colorData: Data?
    @NSManaged var type :NSNumber
    @NSManaged var name: String?
    @NSManaged var info: String?
    @NSManaged var date: Date?
    @NSManaged var timeline: Timeline?
    @NSManaged var adjustments: NSMutableOrderedSet?

}

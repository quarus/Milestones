//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// CGroup+CoreDataProperties.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation
import CoreData

extension Group {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group");
    }

    @NSManaged public var exportInfo: ExportInfo?
    @NSManaged var name: String?
    @NSManaged var timelines: NSMutableOrderedSet?
    

}

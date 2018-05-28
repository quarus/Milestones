//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Adjustment+CoreDataProperties.swift
//  Milestones
//
//  Created by Altay Cebe on 21.12.16.
//  Copyright © 2016 Altay Cebe. All rights reserved.
//

import Foundation
import CoreData


extension Adjustment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Adjustment> {
        return NSFetchRequest<Adjustment>(entityName: "Adjustment");
    }

    @NSManaged var creationDate: Date?
    @NSManaged var date: Date?
    @NSManaged var name: String?
    @NSManaged var reason: String?
    @NSManaged var type: NSDecimalNumber?
    @NSManaged var milestone: Milestone?
    @NSManaged var trackedMilestone: Milestone?
}

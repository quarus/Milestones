//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  ExportInfo+CoreDataProperties.swift
//  Milestones
//
//  Created by Altay Cebe on 19.02.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//
//

import Foundation
import CoreData


extension ExportInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExportInfo> {
        return NSFetchRequest<ExportInfo>(entityName: "ExportInfo")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var author: String?
    @NSManaged public var info: String?
    @NSManaged public var lastExport: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var endDate: NSDate?
    @NSManaged public var group: Group?
    @NSManaged public var startMilestone: Milestone?
    @NSManaged public var endMilestone: Milestone?

}

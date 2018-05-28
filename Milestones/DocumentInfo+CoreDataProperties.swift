//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  DocumentInfo+CoreDataProperties.swift
//  Milestones
//
//  Created by Altay Cebe on 18.03.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//
//

import Foundation
import CoreData


extension DocumentInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentInfo> {
        return NSFetchRequest<DocumentInfo>(entityName: "DocumentInfo")
    }

    @NSManaged public var author: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var modificationDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var version: NSDecimalNumber?
    @NSManaged public var selectedGroup: Group?
}

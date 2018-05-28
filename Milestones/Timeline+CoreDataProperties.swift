//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  CTimline+CoreDataProperties.swift
//  Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation
import CoreData
import Cocoa

extension Timeline {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Timeline> {
        return NSFetchRequest<Timeline>(entityName: "Timeline");
    }


    @NSManaged private var colorData: Data?
    @NSManaged var name: String?
    @NSManaged var info: String?
    @NSManaged var milestones: NSSet?
    @NSManaged var groups: NSSet?
   
    var color :NSColor? {
        get {
            guard let data = colorData else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor
        }

        set {
            colorData = NSKeyedArchiver.archivedData(withRootObject: newValue as Any) 
        }
    }

  }

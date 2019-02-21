//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  CGroup+CoreDataClass.swift
//  Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation
import CoreData


class Group :NSManagedObject {

    func addTimeline(aTimeline :Timeline) {
        self.mutableOrderedSetValue(forKey: "timelines").add(aTimeline)
    }

    func removeTimeline(aTimeline :Timeline) {
        self.mutableOrderedSetValue(forKey: "timelines").remove(aTimeline)
    }
    
    func removeTimelines(timelines :[Timeline]) {
        self.mutableOrderedSetValue(forKey: "timelines").removeObjects(in: timelines)
    }
    
    
    func fetchAllMilestones() -> [Milestone]? {
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let fetchRequest: NSFetchRequest<Milestone> = Milestone.fetchRequest()
        fetchRequest.predicate = NSPredicate(format:"%@ in timeline.groups", self)

        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedMilestones : [Milestone]? = try? managedObjectContext!.fetch(fetchRequest)
        return fetchedMilestones
        
    }
    
    func milestoneAt(indexPath: IndexPath) -> Milestone? {
        if indexPath.count > 1 {
            let timelineIndex = indexPath[0]
            let milestoneIndex = indexPath[1]
            
            guard let timelineArray = timelines?.array as? [Timeline] else {return nil}
            let milestones = timelineArray[timelineIndex].milestonesOrderedByDate()
            return milestones?[milestoneIndex]
        }

        return nil
    }
    
    override func awakeFromInsert() {
        name = "New Group"
        if let moc = self.managedObjectContext{
            self.exportInfo = (NSEntityDescription.insertNewObject(forEntityName: "ExportInfo", into: moc) as! ExportInfo)
        }
    }
}

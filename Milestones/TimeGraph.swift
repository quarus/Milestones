//
//  TimeGraph.swift
//  Milestones
//
//  Created by Altay Cebe on 15.02.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation

protocol TimeGraphModelDelegate {
    func numberOfTimelines() -> Int
    func numberOfMilestonesForTimelineAt(index: Int) -> Int
}

protocol TimeGraphModelDataSource {
    func milestoneAtIndex(index: Int, inTimelineAtIndex msIndex: Int) -> MilestoneProtocol
}

struct TimeGraphModel {
    
    var delegate: TimeGraphModelDelegate?
    var dataSource: TimeGraphModelDataSource?
    
    private(set) var numberOfTimelines: Int = 0

    init() {
        
    }
    
    mutating func reloadData() {
        guard let del = delegate else {return}
        guard let src = dataSource else {return}
        
        numberOfTimelines =  del.numberOfTimelines()
        for timelineIndex in 0..<numberOfTimelines {
            let numberOfMilestones = del.numberOfMilestonesForTimelineAt(index: timelineIndex)
            for milestoneIndex in 0..<numberOfMilestones {
                src.milestoneAtIndex(index: milestoneIndex, inTimelineAtIndex: timelineIndex)
            }
        }
    }
}

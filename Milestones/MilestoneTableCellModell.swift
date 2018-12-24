//
//  MilestoneCellModell.swift
//  Milestones
//
//  Created by Altay Cebe on 24.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

struct MilestoneTableCellModel : MilestoneTableCellDataSourceProtocol {
    
    private let calendarWeekDateFormatter :DateFormatter
    private let dateFormatter :DateFormatter
    
    private(set) var dateString: String = ""
    private(set) var cwString: String = ""
    private(set) var nameString: String = ""
    private(set) var timeIntervallString: String = ""
    private(set) var needsExpandedCell: Bool = false
    private(set) var iconType: IconType
    private(set) var iconColor: NSColor

    
    init(milestone: Milestone, nextMilestone :Milestone? = nil) {
        calendarWeekDateFormatter = DateFormatter()
        calendarWeekDateFormatter.dateFormat = "w.e/yy"
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        if let date = milestone.date {
            dateString = dateFormatter.string(from: date)
            cwString = "KW " + calendarWeekDateFormatter.string(from: date)
        }
        
        nameString = milestone.name ?? ""

        if let milestone2 = nextMilestone {
            if let timeIntervalInSeconds = milestone.timeintervalSinceMilestone(milestone2) {
                
                if fabs(timeIntervalInSeconds) <= (24 * 60*60) {
                    needsExpandedCell = false
                } else {
                    needsExpandedCell = true
                    let timeIntervalInDays = fabs(timeIntervalInSeconds / (24*60*60))
                    timeIntervallString = String(format:"%.1f Days", timeIntervalInDays)
                }
            }
        }
        
        iconType = IconType(rawValue: milestone.type.intValue) ?? .Diamond
        iconColor = milestone.timeline?.color ?? .black
    }
}

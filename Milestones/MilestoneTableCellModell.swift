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
            
            if let date2 = nextMilestone?.date {
                
                if fabs(date.timeIntervalSince(date2)) > (24 * 60 * 60) {
                    needsExpandedCell = true
                    let timeIntervalFormatter = TimeIntervalFormatter(startDate: date, endDate: date2)
                    timeIntervallString = timeIntervalFormatter.intervalString()
                }
            }
        }
        
        nameString = milestone.name ?? ""
        
        iconType = IconType(rawValue: milestone.type.intValue) ?? .Diamond
        iconColor = milestone.timeline?.color ?? .black
    }
}

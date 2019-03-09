//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Config.swift
//  Milestones
//
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class Config {
    
    
    var calendarWeekBackgroundColorEven = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    var calendarWeekBackgroundColorOdd = NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    
    var monthBackgroundColorEven = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
    var monthBackgroundColorOdd = NSColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    
    var quarterBackgroundColorEven = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    var quarterBackgroundColorOdd = NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)

    var yearBackgroundColorEven = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    var yearBackgroundColorOdd = NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)

    
    var timelineBackgroundColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    
    var strokeColor = NSColor(deviceRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    
    var defaultMilestoneColor = NSColor(red: 0.8, green: 0.14, blue: 0.22, alpha: 1.0)
    var defaultTimelineColor = NSColor.gray
    
    static let sharedInstance = Config()
    
    private init() {
    }
    
    func calendarWeekBackgroundColorForCWNumber(_ number: Int) -> NSColor{
        
        if (number % 2) == 0 {
            return calendarWeekBackgroundColorEven
        } else {
            return calendarWeekBackgroundColorOdd
        }
    }
    
    func monthBackgroundColorForMonthNumber(_ number: Int) -> NSColor {
        
        if (number % 2) == 0 {
            return monthBackgroundColorEven
        } else {
            return monthBackgroundColorOdd
        }
    }
    
    func quarterBackgroundColorForQuarterNumber(_ number: Int) -> NSColor {
        
        if (number % 2) == 0 {
            return quarterBackgroundColorEven
        } else {
            return quarterBackgroundColorOdd
        }
    }
    
    func yearBackgroundColorForYear(_ year: Int) -> NSColor {
        
        if (year % 2) == 0 {
            return yearBackgroundColorEven
        } else {
            return yearBackgroundColorOdd
        }
    }

}

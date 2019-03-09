//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  TimelineCalculator.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation


class TimelineCalculator : HorizontalCalculator {

    let calendar :Calendar
    let referenceDate = Date(timeIntervalSince1970: 0)
//     let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
    
    var lengthOfDay :CGFloat = 15.0
    
    var lengthOfWeek :CGFloat {
        get {
            return lengthOfDay * 7
        }
    }
    
    convenience init(lengthOfDay :CGFloat) {
        self.init()
        self.lengthOfDay = lengthOfDay
    }
    
    init() {
        calendar = Calendar.defaultCalendar()
    }
    
    
    //MARK: Horizontal calculations
    func xPositionFor(date: Date) -> CGFloat{
        
        let posititon = lengthBetween(firstDate: referenceDate, secondDate: date)
        return posititon
    }
    
    func centerXPositionFor(date: Date) -> CGFloat {
        
        return xPositionFor(date: date) + lengthOfDay / 2.0
    }
    
    func dateForXPosition(position: CGFloat) -> Date {
        
        let dayInterval :TimeInterval = 24 * 60 * 60
        
        //1. Calculate the number of days since the reference date
        let numberOfDays = Double(floor(fabs(position / lengthOfDay)))
        
        
        //2. create a date by adding the number of days to the reference date
        let newDate = referenceDate.addingTimeInterval(numberOfDays * dayInterval)
        return newDate.normalized()
    }
    
    func lengthBetween(firstDate: Date, secondDate: Date) -> CGFloat{

        //1. Calculate the number of days between the startdate and the given date
        let components :Set<Calendar.Component> = [Calendar.Component.weekOfYear,Calendar.Component.weekday]
        let deltaComponents = calendar.dateComponents(components, from: firstDate, to: secondDate)
        
        guard let deltaCalendarWeeks = deltaComponents.weekOfYear else {
            return 0.0
        }
        
        guard let deltaDays = deltaComponents.weekday else {
            return 0.0
        }
        
        //2. Multiply by the displayed length of a day
        
        let length = CGFloat((deltaCalendarWeeks * 7) + deltaDays)
        return length * lengthOfDay
    }
    
    func lengthOfQuarter(containing date: Date) -> CGFloat {
        
        let dateComponents = Calendar.defaultCalendar().dateComponents([.day,.month,.year,.quarter], from: date)
        let year = dateComponents.year ?? 0
        let quarter = date.numberOfQuarter
        
        return lengthOf(Quarter: quarter, inYear: year)
    }
    
    func lengthOf(Quarter quarter: Int, inYear year: Int) -> CGFloat {
        
        guard let firstDayOfQuarter = Calendar.defaultCalendar().startOfQuarter(withNumber: quarter, ofYear: year) else {return 0}
        
        let lastDayOfQuarter = firstDayOfQuarter.endOfQuarter
        let lengthOfQuarter = xPositionFor(date: lastDayOfQuarter) - xPositionFor(date: firstDayOfQuarter) + lengthOfDay
        
        return lengthOfQuarter
    }
    
    func lengthOfYear(containing date: Date) -> CGFloat {
        guard let interval = Calendar.defaultCalendar().dateInterval(of: .year, for: date) else {return 0.0}
        let numberOfDays = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!

        return CGFloat(numberOfDays) * lengthOfDay
    }
}

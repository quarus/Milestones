//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// DefaultCalendar.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation

public extension Calendar {
    
    static func defaultCalendar() -> Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }
    
    func enumerateFirstMondayOfCalendarWeeksStarting(fromDate startDate: Date, usingHandler dateHandler:(Date, inout Bool) ->()) {
        
        var firstMondayOfCWComponents = DateComponents()
        firstMondayOfCWComponents.weekday = 2 // 2 is a monday
        
        //Enumerate all calendar weeks using the first monday of every week
        self.enumerateDates(startingAfter: startDate, matching: firstMondayOfCWComponents, matchingPolicy: .nextTimePreservingSmallerComponents, repeatedTimePolicy: .first, direction: .forward, using: { (date: Date?, exactMatch :Bool, stop :inout Bool) in
            
            if (date != nil) {
                dateHandler(date!, &stop)
            }
        })

    }

    func enumerateFirstDayOfMonthsStarting(fromDate startDate: Date, usingHandler dateHandler:(Date, inout Bool) ->()) {
       
        var firstDayOfMonthComponents = DateComponents()
        firstDayOfMonthComponents.day = 1
        
        //Enumerate all calendar weeks using the first day of every month
        self.enumerateDates(startingAfter: startDate, matching: firstDayOfMonthComponents, matchingPolicy: .nextTimePreservingSmallerComponents, repeatedTimePolicy: .first, direction: .forward, using: { (date: Date?, exactMatch :Bool, stop :inout Bool) in
            
            if (date != nil) {
                dateHandler(date!, &stop)
                
            }
        })
    }
    
    func enumerateFirstDayOfQuartersStarting(fromDate startDate: Date, usingHandler dateHandler: (Date, inout Bool)->()) {

        let dateComponents = Calendar.defaultCalendar().dateComponents([.day,.month,.year,.quarter], from: startDate)
        
        var year = dateComponents.year ?? 0
        var quarter = startDate.numberOfQuarter
        
        var stop = false
        while (!stop) {
            if let date = Calendar.defaultCalendar().startOfQuarter(withNumber: quarter, ofYear: year) {
            
                dateHandler(date, &stop)
                quarter += 1
                if (quarter > 4) {
                    quarter = 1
                    year += 1
                }
                
            } else {
                stop = true
            }
        }
    }
    
    func ennumerateFirstDayOfYearStarting(fromDate enumerationStartDate: Date,
                                          usingHandler dateHandler: (Date, inout Bool) -> ()) {
        
        
        var stop = false
        guard var startDate = enumerationStartDate.firstDayOfYear() else {return}
        
        while !stop {
            dateHandler(startDate.normalized(), &stop)
            let nextDate = startDate.firstDayOfYear()
            if nextDate == nil {
                return
            } else {
                startDate = Calendar.defaultCalendar().date(byAdding: .year ,
                                                            value: 1,
                                                            to: nextDate!)!
            }
        }
        
    }
    
    
    public func startOfQuarter(ContainingDate date: Date) -> Date? {
        
        let dateComponents = Calendar.defaultCalendar().dateComponents([.day,.month,.year,.quarter], from: date)
        let year = dateComponents.year ?? 0
        let quarter = date.numberOfQuarter

        return startOfQuarter(withNumber: quarter, ofYear: year)
    }
    
    // There is a problem using quarters with datecomponents. This hacky extension is used as a stopgap.
    // https://stackoverflow.com/questions/23682985/getting-the-first-date-of-current-quarter?noredirect=1&lq=1
    public func startOfQuarter(withNumber number :Int, ofYear year: Int) -> Date? {
        
        
        let newMonth :Int
        switch number {
        case 1:
            newMonth = 1
        case 2:
            newMonth = 4
        case 3:
            newMonth = 7
        case 4:
            newMonth = 10
        default:
            newMonth = 1
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = newMonth
        dateComponents.day = 1
        
        let date = Calendar.defaultCalendar().date(from: dateComponents)
        return date
    }

    
}


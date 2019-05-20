//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Date+Extensions.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//


import Foundation

extension Date {
    
    public static func dateFor(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date? {
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.timeZone = TimeZone(identifier: "UTC")
        
        let date = Calendar.defaultCalendar().date(from: dateComponents)?.normalized()
        return date
        
    }

    func firstDayOfMonth() -> Date? {
        let calendar = Calendar.defaultCalendar()
        
        let requestedComponents : Set<Calendar.Component> = [.month, .year, .weekOfMonth, .weekday]
        var dateComponents = calendar.dateComponents(requestedComponents, from: self)
        dateComponents.day = 1
        
        return calendar.date(from: dateComponents)?.normalized()
    }
    
    func lastDayOfMonth() -> Date? {
        let calendar = Calendar.defaultCalendar()

        let requestedComponents : Set<Calendar.Component> = [.month, .year, .weekOfMonth, .weekday]
        var dateComponents = calendar.dateComponents(requestedComponents, from: self)

        guard let month = dateComponents.month else {return nil}
        dateComponents.month = month.advanced(by: 1)
        dateComponents.day = 0

        return calendar.date(from: dateComponents)?.normalized()
    }
    
    func firstDayOfYear() -> Date? {
        let calendar = Calendar.defaultCalendar()
        
        let requestedComponents : Set<Calendar.Component> = [.month, .year, .weekOfMonth, .weekday]
        var dateComponents = calendar.dateComponents(requestedComponents, from: self)
        
        dateComponents.month = 1
        dateComponents.day = 1
        
        return calendar.date(from: dateComponents)?.normalized()
    }
    
    func lastDayOfYear() -> Date? {
        let calendar = Calendar.defaultCalendar()
        let requestedComponents : Set<Calendar.Component> = [.month, .year, .weekOfMonth, .weekday]
        var dateComponents = calendar.dateComponents(requestedComponents, from: self)
        
        dateComponents.month = 12
        dateComponents.day = 31
        
        return calendar.date(from: dateComponents)?.normalized()
    }
    
    func normalized() -> Date {
        
        let normalizedDate = Calendar.defaultCalendar().startOfDay(for: self)
        return normalizedDate
    }
    
    // There is a problem using quarters with datecomponents. This hacky extension is used as a stopgap.
    // https://stackoverflow.com/questions/23682985/getting-the-first-date-of-current-quarter?noredirect=1&lq=1
    public var startOfQuarter: Date {
        
        let startOfMonth = Calendar.defaultCalendar().date(from: Calendar.defaultCalendar().dateComponents([.year, .month], from: Calendar.defaultCalendar().startOfDay(for: self)))!
        
        var components = Calendar.defaultCalendar().dateComponents([.month, .day, .year], from: startOfMonth)
        
        let newMonth: Int
        switch components.month! {
        case 1,2,3: newMonth = 1
        case 4,5,6: newMonth = 4
        case 7,8,9: newMonth = 7
        case 10,11,12: newMonth = 10
        default: newMonth = 1
        }
        components.month = newMonth
        return Calendar.defaultCalendar().date(from: components)!.normalized()
    }
    
    public var endOfQuarter: Date {
        
        let dateComponents = Calendar.defaultCalendar().dateComponents([.year], from: self)
        var year = dateComponents.year ?? 0
        var quarter = self.numberOfQuarter + 1
        
        if (quarter > 4) {
            year += 1
            quarter = 1
        }
        
        let date = Calendar.defaultCalendar().startOfQuarter(withNumber: quarter, ofYear: year)?.normalized() ?? Date()
        return date.normalized()
        
    }
    
    var numberOfCalendarWeek: Int {
        var components = Calendar.defaultCalendar().dateComponents([.weekOfYear], from: self)
        return components.weekOfYear ?? 0
    }
    
    var numberOfMonth: Int {
        var components = Calendar.defaultCalendar().dateComponents([.month], from: self)
        return components.month ?? 0
    }
    
    var numberOfQuarter: Int {
        var components = Calendar.defaultCalendar().dateComponents([.month, .day, .year], from: self)
        
        var number = 0
        switch components.month! {
        case 1,2,3: number = 1
        case 4,5,6: number = 2
        case 7,8,9: number = 3
        case 10,11,12: number = 4
        default: number = 1
            
        }
        return number
    }
        
    var numberOfYear: Int {
        var components = Calendar.defaultCalendar().dateComponents([.year], from: self)
        return components.year ?? 0
    }
 }


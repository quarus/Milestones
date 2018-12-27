//
//  DateInterval+Extensions.swift
//  Milestones
//
//  Created by Altay Cebe on 27.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

extension DateInterval {
    
    func isDurationLongerThanOneDay() -> Bool {
        
        if duration > (24*60*60) {
            return true
        }
        
        return false
    }
    
    private func dateIntervalComponents() -> DateComponents {
        
        let requiredIntervalDateComponents :Set<Calendar.Component> =  [Calendar.Component.day,
                                                                        Calendar.Component.weekOfYear,
                                                                        Calendar.Component.month,
                                                                        Calendar.Component.year]
        
        let dateIntervalComponents = Calendar.defaultCalendar().dateComponents( requiredIntervalDateComponents,
                                                                                from: self.start,
                                                                                to: self.end)
        return dateIntervalComponents
    }
    
    private func stringFor(components: DateComponents) -> String {
        
        var string = ""
        
        func checkAndAdd(singularString: String, pluralString: String, forAmount amount: Int) {
            if amount != 0 {
                if string.count > 0 {
                    string += ", "
                }
                string += "\(amount) "
                if amount == 1 {
                    string += singularString
                } else {
                    string += pluralString
                }
            }
        }
        
        if let years = components.year {
            checkAndAdd(singularString: "Year", pluralString: "Years", forAmount: years)
        }
        
        if let months = components.month {
            checkAndAdd(singularString: "Month", pluralString: "Months", forAmount: months)
        }
        
        if let weeks = components.weekOfYear {
            checkAndAdd(singularString: "Week", pluralString: "Weeks", forAmount: weeks)
        }
        
        if let days = components.day {
            checkAndAdd(singularString: "Day", pluralString: "Days", forAmount: days)
        }
        
        return string
    }
    
    func intervalString() -> String {
        
        let components = dateIntervalComponents()
        
        return stringFor(components: components)
    }
}

//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// TimeIntervalFormatter.swift
// Milestones
//
//  Created by Altay Cebe on 25.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation

struct TimeIntervalFormatter {
 
    let startDate: Date
    let endDate: Date
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    private func dateIntervalComponents() -> DateComponents {
       
        let requiredIntervalDateComponents :Set<Calendar.Component> =  [Calendar.Component.day,
                                                                        Calendar.Component.weekOfYear,
                                                                        Calendar.Component.month,
                                                                        Calendar.Component.year]
        
        let dateIntervalComponents = Calendar.defaultCalendar().dateComponents( requiredIntervalDateComponents,
                                                                                from: startDate,
                                                                                to: endDate)
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

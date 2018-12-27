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
}

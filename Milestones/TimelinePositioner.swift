//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  TimelinePositioner.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation

class TimelinePositioner: VerticalCalculator {
    var heightOfTimeline: CGFloat = 0.0
    
    init(heightOfTimeline height :CGFloat) {
        heightOfTimeline = height
    }
    
    func yPositionForTimelineAt(index: Int) -> CGFloat {
        
        if index < 0 {
            return 0
        }
            
        return CGFloat(index) * heightOfTimeline
    }
}

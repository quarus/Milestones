//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MarkerModel.swift
//  Milestones
//
//  Created by Altay Cebe on 30.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation

struct MarkerModel {
    
    let startDate: Date
    
    var cursorDate: Date? {
        get {
            let absPosition = xCalculator.xPositionFor(date: startDate) + cursorPosition.x
            return xCalculator.dateForXPosition(position: absPosition)
        }
    }
    
    var indexOfCursorTimeline: Int {
        return yCalculator.timelineIndexForYPosition(yPosition: cursorPosition.y)
    }
    
    private var xCalculator: HorizontalCalculator
    private var yCalculator: VerticalCalculator
    
    var cursorPosition: CGPoint {
        didSet {
            let absoluteStartX = xCalculator.xPositionFor(date: startDate)
            let absoluteCursorPosition = absoluteStartX + cursorPosition.x
            let date = xCalculator.dateForXPosition(position: absoluteCursorPosition)
            cursorPosition.x = xCalculator.centerXPositionFor(date: date) - absoluteStartX
            cursorPosition.y = yCalculator.centerYPositionForTimelineAt(index: indexOfCursorTimeline)
        }
    }
    
    init(horizontalCalculator: HorizontalCalculator,
         verticalCalculator: VerticalCalculator,
         startDate: Date) {
        
        xCalculator = horizontalCalculator
        yCalculator = verticalCalculator
        cursorPosition = CGPoint(x: 0, y: 0)
        self.startDate = startDate
    }
}

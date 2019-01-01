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
    //the date currently marked ...
    private(set) var markedDate: Date?
    // ... within the timeline currently marked
    var indexOfMarkedTimeline: Int {
        get {
            return Int(cursorPosition.y / yCalculator.heightOfTimeline)
        }
    }
    
    var cursorDate: Date? {
        get {
            let absPosition = xCalculator.xPositionFor(date: startDate) + cursorPosition.x
            return xCalculator.dateForXPosition(position: absPosition)
        }
    }
    var indexOfCursorTimeline: Int {
        return Int(cursorPosition.y / yCalculator.heightOfTimeline)
    }
    
    private var xCalculator: HorizontalCalculator
    private var yCalculator: VerticalCalculator
    
    var cursorPosition: CGPoint
    
    init(horizontalCalculator: HorizontalCalculator,
         verticalCalculator: VerticalCalculator,
         startDate: Date) {
        
        xCalculator = horizontalCalculator
        yCalculator = verticalCalculator
        cursorPosition = CGPoint(x: 0, y: 0)
        self.startDate = startDate
    }
    
    mutating func markDate() {
        let startDateAbsolutePosition = xCalculator.xPositionFor(date: startDate)
        markedDate = xCalculator.dateForXPosition(position: startDateAbsolutePosition + cursorPosition.x)
    }
}

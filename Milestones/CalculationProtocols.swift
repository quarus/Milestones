//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  CalculationProtocols.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation

protocol HasHorizontalCalculator {
    var horizontalCalculator: HorizontalCalculator { get }
}

protocol HasVerticalCalculator {
    var verticalCalculator: VerticalCalculator { get }
}


protocol HorizontalCalculator {
    
    var lengthOfDay: CGFloat {get set}
    var lengthOfWeek: CGFloat {get}
    
    func dateForXPosition(position: CGFloat) -> Date
    
    func xPositionFor(date: Date) -> CGFloat
    func centerXPositionFor(date :Date) ->CGFloat
    
    func lengthBetween(firstDate: Date, secondDate: Date) -> CGFloat

    func lengthOfQuarter(containing date: Date) -> CGFloat
    func lengthOf(Quarter quarter: Int, inYear year: Int) -> CGFloat

}

protocol VerticalCalculator {
    
    var heightOfTimeline: CGFloat {get set}
    func yPositionForTimelineAt(index :Int) -> CGFloat
    func centerYPositionForTimelineAt(index :Int) -> CGFloat
    func timelineIndexForYPosition(yPosition: CGFloat) -> Int
}

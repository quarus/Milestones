//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MarkModelTests.swift
//  TimelineCalculationTests
//
//  Created by Altay Cebe on 30.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import XCTest
@testable import Milestones

class MarkModelTests: XCTestCase {

    var xCalculator: TimelineCalculator!
    var yCalculator: VerticalCalculator!
    
    override func setUp() {
        xCalculator = TimelineCalculator()
        yCalculator = TimelinePositioner(heightOfTimeline: 30)
    }

    override func tearDown() {
    }
    
    func testXPositioning() {
        let date = Date.dateFor(year: 2011, month: 04, day: 12, hour: 0, minute: 0, second: 1)!
        let lengthFor100Days = xCalculator.lengthOfDay * 100 + 12
        let heightOf3Timelines = yCalculator.heightOfTimeline * 3 + 13
        let date2Position = xCalculator.xPositionFor(date: date) + lengthFor100Days
        let date2 = xCalculator.dateForXPosition(position: date2Position)
        
        var markerModel = MarkerModel(horizontalCalculator: xCalculator,
                                      verticalCalculator: yCalculator,
                                      startDate: date)
        
        markerModel.cursorPosition = CGPoint(x: 0, y: 0)
        XCTAssertEqual(markerModel.cursorDate, date)
        XCTAssertEqual(markerModel.cursorPosition.x, xCalculator.lengthOfDay/2.0)
        XCTAssertEqual(markerModel.cursorPosition.y, yCalculator.heightOfTimeline/2.0)
        
        markerModel.cursorPosition = CGPoint(x: lengthFor100Days, y: heightOf3Timelines)
        XCTAssertEqual(markerModel.cursorDate, date2)
        XCTAssertEqual(markerModel.cursorPosition.y, yCalculator.heightOfTimeline * 3 + (yCalculator.heightOfTimeline/2.0))
    }
}

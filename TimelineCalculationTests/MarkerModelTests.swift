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
    
    func testMarkDate() {
        let date = Date.dateFor(year: 2011, month: 04, day: 12, hour: 0, minute: 0, second: 1)!
        let date2 = xCalculator.dateForXPosition(position: xCalculator.xPositionFor(date: date) + 500)
        
        var markerModel = MarkerModel(horizontalCalculator: xCalculator,
                                      verticalCalculator: yCalculator,
                                      startDate: date)
        
        markerModel.cursorPosition = CGPoint(x: 0, y: 0)
        markerModel.markDate()
        markerModel.cursorPosition = CGPoint(x: 500, y: 0)
        XCTAssertEqual(markerModel.markedDate, date)
        XCTAssertEqual(markerModel.indexOfMarkedTimeline, 0)
        
        markerModel.cursorPosition = CGPoint(x: 500, y: 66)
        markerModel.markDate()
        XCTAssertEqual(markerModel.markedDate, date2)
        XCTAssertEqual(markerModel.indexOfMarkedTimeline, 2)
    }
    
    func testCursorDate() {
        let date = Date.dateFor(year: 2019, month: 03, day: 07, hour: 10, minute: 43, second: 44)!
        let date2 = xCalculator.dateForXPosition(position: xCalculator.xPositionFor(date: date) + 576)
        

        var markerModel = MarkerModel(horizontalCalculator: xCalculator,
                                      verticalCalculator: yCalculator,
                                      startDate: date)

        XCTAssertEqual(markerModel.cursorDate, date)
        XCTAssertEqual(markerModel.indexOfCursorTimeline, 0)

        markerModel.cursorPosition = CGPoint(x: 576, y: 103)
        XCTAssertEqual(markerModel.cursorDate, date2)
        XCTAssertEqual(markerModel.indexOfCursorTimeline, 3)
    }
}

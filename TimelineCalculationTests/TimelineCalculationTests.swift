//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  TimelineCalculationTests.swift
//  TimelineCalculationTests
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import XCTest
@testable import Milestones


class TimelineCalculationTests: XCTestCase {
    
    var timelineCalculator :TimelineCalculator!
    let dayInterval :TimeInterval = 24*60*60

    override func setUp() {
        super.setUp()
        timelineCalculator = TimelineCalculator()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReferenceDate() {
        
        let xPosition = timelineCalculator.xPositionFor(date: timelineCalculator.referenceDate)
        XCTAssertEqual(0.0, xPosition, accuracy: 0.0)
    }
    
    func testLengthOfOneDay() {

        let nextDay = timelineCalculator.referenceDate.addingTimeInterval(dayInterval)

        let referenceXPosition = timelineCalculator.xPositionFor(date: timelineCalculator.referenceDate)
        let xPosition = timelineCalculator.xPositionFor(date: nextDay)
        
        XCTAssertEqual((xPosition - referenceXPosition), timelineCalculator.lengthOfDay, accuracy: 0.0)
    }
    
    func testLengthOfOneWeek() {
        
        let oneWeekLater = timelineCalculator.referenceDate.addingTimeInterval(dayInterval * TimeInterval(7))
        let referenceXPosition = timelineCalculator.xPositionFor(date: timelineCalculator.referenceDate)
        let xPosition = timelineCalculator.xPositionFor(date: oneWeekLater)
        let lengthOfOneWeek = timelineCalculator.lengthOfDay * CGFloat(7)
        
        XCTAssertEqual((xPosition - referenceXPosition), lengthOfOneWeek, accuracy: 0.0)
    }
    
    func testDateToPositionConversions() {

        //One day later
        var date = timelineCalculator.referenceDate.addingTimeInterval(dayInterval * 1)
        var positionForDate = timelineCalculator.xPositionFor(date: date)
        var dateForPosition = timelineCalculator.dateForXPosition(position: positionForDate)
        
        XCTAssertEqual(date, dateForPosition)
        
        //some days later
        date = timelineCalculator.referenceDate.addingTimeInterval(dayInterval * 5)
        positionForDate = timelineCalculator.xPositionFor(date: date)
        dateForPosition = timelineCalculator.dateForXPosition(position: positionForDate)

        // more than a month later
        date = timelineCalculator.referenceDate.addingTimeInterval(dayInterval * 40)
        positionForDate = timelineCalculator.xPositionFor(date: date)
        dateForPosition = timelineCalculator.dateForXPosition(position: positionForDate)
        
        XCTAssertEqual(date, dateForPosition)
        
    }
    
    func testCenterPosition() {
        
        let date = Date()
        let xPos = timelineCalculator.xPositionFor(date: date)
        let centerXPos = timelineCalculator.centerXPositionFor(date: date)
        let delta = centerXPos - xPos
        
        XCTAssertEqual(delta, timelineCalculator.lengthOfDay / 2.0)
        
    }
}

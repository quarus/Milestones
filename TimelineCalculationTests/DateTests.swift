//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  DateTests.swift
//  TimelineCalculationTests
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import XCTest
@testable import Milestones

class DateTests: XCTestCase {
    
    var timelineCalculator :TimelineCalculator!

    override func setUp() {
        super.setUp()
        timelineCalculator = TimelineCalculator()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testDateNormalisation1() {
        
        let date = Date.dateFor(year: 2017, month: 6, day: 12, hour: 17, minute: 10, second: 0); XCTAssertNotNil(date)
        let expectedNormalizedDate = Date.dateFor(year: 2017, month: 6, day: 12, hour: 0, minute: 0, second: 0); XCTAssertNotNil(expectedNormalizedDate)
        
        let normalizedDate = date!.normalized(); XCTAssertNotNil(normalizedDate)
    
        XCTAssertEqual(normalizedDate, expectedNormalizedDate)
        
    }
    
    func testDateNormalisation2() {
        
        let date = Date.dateFor(year: 2011, month: 4, day: 12, hour: 0, minute: 0, second: 1); XCTAssertNotNil(date)
        let expectedNormalizedDate = Date.dateFor(year: 2011, month: 4, day: 12, hour: 0, minute: 0, second: 0); XCTAssertNotNil(expectedNormalizedDate)
        
        let normalizedDate = date!.normalized(); XCTAssertNotNil(normalizedDate)
        
        XCTAssertEqual(normalizedDate, expectedNormalizedDate)
        
    }

    func testFirstDayAndLastDayOfMonthCalculations() {
        
        let date = Date.dateFor(year: 2011, month: 4, day: 12, hour: 0, minute: 0, second: 1); XCTAssertNotNil(date)
        let firstDayOfMonth = Date.dateFor(year: 2011, month: 4, day: 1, hour: 0, minute: 0, second: 0); XCTAssertNotNil(date)
        let lastDayOfMonth = Date.dateFor(year: 2011, month: 4, day: 30, hour: 0, minute: 0, second: 0); XCTAssertNotNil(date)
        
        let calculatedFirstDayOfMonth = date?.firstDayOfMonth(); XCTAssertNotNil(calculatedFirstDayOfMonth)
        XCTAssertEqual(firstDayOfMonth, calculatedFirstDayOfMonth)
        
        let calculatedLastDayOfMonth = date?.lastDayOfMonth(); XCTAssertNotNil(calculatedLastDayOfMonth)
        XCTAssertEqual(lastDayOfMonth, calculatedLastDayOfMonth)

    }
    
    func testFirstDayOfYearCalculations() {

        let date = Date.dateFor(year: 2011, month: 4, day: 12, hour: 0, minute: 0, second: 1); XCTAssertNotNil(date)
        let firstDayOfYear = Date.dateFor(year: 2011, month: 1, day: 1, hour: 0, minute: 0, second: 0); XCTAssertNotNil(date)

        let calculatedFirstDayOfYear = date?.firstDayOfYear(); XCTAssertNotNil(date)
        XCTAssertEqual(calculatedFirstDayOfYear, firstDayOfYear)
        
    }
    
    func lastDayOfYearCalclations() {
        var date = Date.dateFor(year: 2017, month: 6, day: 21, hour: 14, minute: 32, second: 43); XCTAssertNotNil(date)
        var lastDayOfYear = Date.dateFor(year: 2017, month: 12, day: 31, hour: 0, minute: 0, second: 0); XCTAssertNotNil(date)
        var calculatedLastDayOfYear = date!.lastDayOfYear()
        XCTAssertEqual(calculatedLastDayOfYear, lastDayOfYear)
        
        date = Date.dateFor(year: 2016, month: 2, day: 12, hour: 12, minute: 10, second: 12); XCTAssertNotNil(date)
        lastDayOfYear = Date.dateFor(year: 2016, month: 12, day: 31, hour: 0, minute: 0, second: 0); XCTAssertNotNil(date)
        calculatedLastDayOfYear = date!.lastDayOfYear()
        XCTAssertEqual(calculatedLastDayOfYear, lastDayOfYear)
    }
    
    func testCWDateEnumeration() {
        
        var dates = [Date]()
        let enumerationStartDate = Date.dateFor(year: 2011, month: 1, day: 1, hour: 0, minute: 0, second: 0)?.normalized();
        XCTAssertNotNil(enumerationStartDate)

        var expectedDates = [Date]()
        expectedDates.append(Date.dateFor(year: 2011, month: 1, day: 3, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2011, month: 1, day: 10, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2011, month: 1, day: 17, hour: 0, minute: 0, second: 0)!.normalized())

        Calendar.defaultCalendar().enumerateFirstMondayOfCalendarWeeksStarting(fromDate: enumerationStartDate!, usingHandler: {(date :Date, stop: inout Bool) in
          
            dates.append(date.normalized())
            if dates.count == 3 {
                stop = true
            }
        })
        
        XCTAssertEqual(dates, expectedDates)
    }
    
    func testMonthDateEnumeration() {
        
        var dates = [Date]()
        var enumerationStartDate = Date.dateFor(year: 2013, month: 3, day: 1, hour: 0, minute: 0, second: 0)?.normalized();
        enumerationStartDate = enumerationStartDate?.normalized()
        XCTAssertNotNil(enumerationStartDate)
        
        var expectedDates = [Date]()
        expectedDates.append(Date.dateFor(year: 2013, month: 4, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2013, month: 5, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2013, month: 6, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        
        Calendar.defaultCalendar().enumerateFirstDayOfMonthsStarting(fromDate: enumerationStartDate!, usingHandler: {(date :Date, stop: inout Bool) in
            
            dates.append(date.normalized())
            if dates.count == 3 {
                stop = true
            }
        })
        
        XCTAssertEqual(dates, expectedDates)
    }
    
    func testQuarterDateEnumeration() {
        
        var dates = [Date]()
        var enumerationStartDate = Date.dateFor(year: 2013, month: 4, day: 10, hour: 0, minute: 0, second: 0)?.normalized();
        enumerationStartDate = enumerationStartDate?.normalized()
        XCTAssertNotNil(enumerationStartDate)
        
        var expectedDates = [Date]()
        expectedDates.append(Date.dateFor(year: 2013, month: 4, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2013, month: 7, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2013, month: 10, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2014, month: 1, day: 1, hour: 0, minute: 0, second: 0)!.normalized())

        Calendar.defaultCalendar().enumerateFirstDayOfQuartersStarting(fromDate: enumerationStartDate!, usingHandler: {(date :Date, stop: inout Bool) in
            
            dates.append(date.normalized())
            if dates.count == 4 {
                stop = true
            }
        })
        
        XCTAssertEqual(dates, expectedDates)

    }

    func testYearEnumeration() {
        var enumerationStartDate = Date.dateFor(year: 2012, month: 3, day: 13, hour: 0, minute: 0, second: 0)?.normalized();
        
        var dates = [Date]()
        var expectedDates = [Date]()
        expectedDates.append(Date.dateFor(year: 2012, month: 1, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2013, month: 1, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2014, month: 1, day: 1, hour: 0, minute: 0, second: 0)!.normalized())
        expectedDates.append(Date.dateFor(year: 2015, month: 1, day: 1, hour: 0, minute: 0, second: 0)!.normalized())

        Calendar.defaultCalendar().ennumerateFirstDayOfYearStarting(fromDate: enumerationStartDate!,
            usingHandler: {(date: Date, stop: inout Bool) in
            dates.append(date)
                if dates.count == 4 {
                    stop = true
            }
        })
        XCTAssertEqual(dates, expectedDates)
    }
}

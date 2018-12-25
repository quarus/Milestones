//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// TimeIntervalFormatterTest.swift
// Milestones
//
//  Created by Altay Cebe on 25.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import XCTest
@testable import Milestones

class TimeIntervalFormatterTest: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testIntervals() {
        let startDate = Date.dateFor(year: 2014, month: 03, day: 05, hour: 15, minute: 23, second: 20)!
        let firstEndDate = Date.dateFor(year: 2014, month: 03, day: 07, hour: 15, minute: 23, second: 20)!
        let secondEndDate = Date.dateFor(year: 2014, month: 03, day: 14, hour: 15, minute: 23, second: 20)!
        let thirdEndDate = Date.dateFor(year: 2014, month: 04, day: 24, hour: 15, minute: 23, second: 20)!
        let fortnightEndDate = Date.dateFor(year: 2014, month: 03, day: 19, hour: 15, minute: 23, second: 20)!
        
        var timeIntervalFormatter = TimeIntervalFormatter(startDate: startDate, endDate: startDate)
        XCTAssertEqual(timeIntervalFormatter.intervalString(), "")
        
        timeIntervalFormatter = TimeIntervalFormatter(startDate: startDate, endDate: firstEndDate)
        XCTAssertEqual(timeIntervalFormatter.intervalString(), "2 Days")

        timeIntervalFormatter = TimeIntervalFormatter(startDate: startDate, endDate: secondEndDate)
        XCTAssertEqual(timeIntervalFormatter.intervalString(), "1 Week, 2 Days")
        
        timeIntervalFormatter = TimeIntervalFormatter(startDate: startDate, endDate: fortnightEndDate)
        XCTAssertEqual(timeIntervalFormatter.intervalString(), "2 Weeks")
        
        timeIntervalFormatter = TimeIntervalFormatter(startDate: startDate, endDate: thirdEndDate)
        XCTAssertEqual(timeIntervalFormatter.intervalString(), "1 Month, 2 Weeks, 5 Days")
        
    }
    


}

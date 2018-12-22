//
//  ScrollViewModel.swift
//  Milestones
//
//  Created by Altay Cebe on 09.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import XCTest
@testable import Milestones

class PageModelTests: XCTestCase {

    
    let xCalculator :TimelineCalculator = TimelineCalculator(lengthOfDay: 30)
    let calendar = Calendar.defaultCalendar()
    
    
    private func dateFor(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date? {
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.timeZone = TimeZone(identifier: "UTC")
        
        let date = xCalculator.calendar.date(from: dateComponents)
        return date
        
    }

    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitializationWithDates() {
        let startDate = dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = dateFor(year: 2018, month: 08, day: 11, hour: 12, minute: 00, second: 00)!
        let lengthDelta = xCalculator.xPositionFor(date: endDate) - xCalculator.xPositionFor(date: startDate)
        
        let pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: endDate,
                                             clipViewLength: 100)
        
        XCTAssertEqual(pageModel.absoluteStartPosition, xCalculator.xPositionFor(date: startDate))
        XCTAssertEqual(pageModel.length, lengthDelta)
        XCTAssertEqual(pageModel.clipViewLength, 100)
    }
    
    func testInitializationWithLength() {
        let startDate = dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        let pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             length: 5000,
                                             clipViewLength: 100)

        let endDate = xCalculator.dateForXPosition(position: pageModel.absoluteStartPosition + 5000).normalized()
        XCTAssertEqual(pageModel.endDate, endDate)
        XCTAssertEqual(pageModel.clipViewLength, 100)
    }
    
    func testLengthForEqualStartAndEndDate() {
        let startDate = dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        
        let pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: startDate,
                                             clipViewLength: 100)
        XCTAssertEqual(pageModel.length, 0.0)
    }
    
    func testDateExistence() {
        let startDate = dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = dateFor(year: 2018, month: 11, day: 21, hour: 12, minute: 00, second: 00)!
        
        let pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: endDate,
                                             clipViewLength: 100)
        
        var testDate = dateFor(year: 2018, month: 7, day: 10, hour: 14, minute: 56, second: 3)!
        XCTAssertEqual(pageModel.contains(date: testDate), true)
        
        testDate = dateFor(year: 2019, month: 7, day: 10, hour: 14, minute: 56, second: 3)!
        XCTAssertEqual(pageModel.contains(date: testDate), false)
    }
    
    func testClipViewPositioningWithinBounds() {
        let startDate = dateFor(year: 2018, month: 02, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = dateFor(year: 2018, month: 10, day: 11, hour: 12, minute: 00, second: 00)!
      
        var pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: endDate,
                                             clipViewLength: 100.0)

        pageModel.clipViewRelativeX = 0
        XCTAssertEqual(pageModel.clipViewAbsoluteX, pageModel.absoluteStartPosition)
        
        pageModel.clipViewRelativeX = 100
        XCTAssertEqual(pageModel.clipViewAbsoluteX, pageModel.absoluteStartPosition + 100)
    }
    
    func testClipViewDatesWithinBounds(){
        let startDate = dateFor(year: 2018, month: 02, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = dateFor(year: 2018, month: 10, day: 11, hour: 12, minute: 00, second: 00)!
        
        var pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: endDate,
                                             clipViewLength: 100.0)
        
        pageModel.clipViewRelativeX = 0
        XCTAssertEqual(pageModel.clipViewStartDate.normalized(), pageModel.startDate)

        pageModel.clipViewRelativeX = pageModel.length
        XCTAssertEqual(pageModel.clipViewStartDate.normalized(), pageModel.endDate)
    }
  
    func testClipViewRecenteringOutOfBounds(){
        let startDate = dateFor(year: 2018, month: 02, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = dateFor(year: 2018, month: 10, day: 11, hour: 12, minute: 00, second: 00)!
        
        var pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: endDate,
                                             clipViewLength: 200)

        //pageModel.clipViewAbsoluteX = pageModel.absoluteStartPosition /*- pageModel.clipViewLength */+ 50000
        pageModel.clipViewRelativeX = 50000
    
        let oldClipViewStartDate = pageModel.clipViewStartDate
        let model = pageModel.makePageModelCenteredAroundClipView()
        
        XCTAssertEqual(model.clipViewStartDate, oldClipViewStartDate)
    }
  
    func testClipViewRecenteringWithinBounds(){
        let startDate = dateFor(year: 2018, month: 02, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = dateFor(year: 2018, month: 10, day: 11, hour: 12, minute: 00, second: 00)!
        
        var pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: endDate,
                                             clipViewLength: 300.0)
        pageModel.clipViewRelativeX = 500
        
        let oldClipViewStartDate = pageModel.clipViewStartDate
        let model = pageModel.makePageModelCenteredAroundClipView()
        
        XCTAssertEqual(model.clipViewStartDate, oldClipViewStartDate)
    }
    
    func testClipViewCenteringAroundADate() {
        
        let centerDate = dateFor(year: 2012, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        let expectedStartDate =  xCalculator.dateForXPosition(position:(xCalculator.xPositionFor(date: centerDate) - 2500))
        
        var pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             centerDate: centerDate,
                                             length: 5000,
                                             clipViewLength: 300.0)
        pageModel.clipViewRelativeX = 500
        
        
        XCTAssertEqual(expectedStartDate, pageModel.startDate)
    }
    
    func testCenterDate() {

         let startDate = dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        
        var pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             length: 5000,
                                             clipViewLength: 1000)
        pageModel.clipViewRelativeX = 2346
        let absoluteStartPosition = xCalculator.xPositionFor(date: startDate)
        let centerDate = xCalculator.dateForXPosition(position: absoluteStartPosition + 2346 + 500).normalized()
        
        print("centerDatePosition \(xCalculator.xPositionFor(date:centerDate))")
        let centeredPageModel = PageModel(horizontalCalculator: xCalculator,
                                          centerDate: centerDate,
                                          length: 5000,
                                          clipViewLength: pageModel.clipViewLength)
        
        XCTAssertEqual(centerDate, centeredPageModel.clipViewCenterDate)

    }
}


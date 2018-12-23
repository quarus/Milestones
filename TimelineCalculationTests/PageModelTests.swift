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
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitializationWithDates() {
        let startDate = Date.dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = Date.dateFor(year: 2018, month: 08, day: 11, hour: 12, minute: 00, second: 00)!
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
        let startDate = Date.dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        let pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             length: 5000,
                                             clipViewLength: 100)

        let endDate = xCalculator.dateForXPosition(position: pageModel.absoluteStartPosition + 5000)
        XCTAssertEqual(pageModel.endDate, endDate)
        XCTAssertEqual(pageModel.clipViewLength, 100)
    }
    
    func testLengthForEqualStartAndEndDate() {
        let startDate = Date.dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        
        let pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: startDate,
                                             clipViewLength: 100)
        XCTAssertEqual(pageModel.length, 0.0)
    }
    
    func testDateExistence() {
        let startDate = Date.dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = Date.dateFor(year: 2018, month: 11, day: 21, hour: 12, minute: 00, second: 00)!
        
        let pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             endDate: endDate,
                                             clipViewLength: 100)
        
        var testDate = Date.dateFor(year: 2018, month: 7, day: 10, hour: 14, minute: 56, second: 3)!
        XCTAssertEqual(pageModel.contains(date: testDate), true)
        
        testDate = Date.dateFor(year: 2019, month: 7, day: 10, hour: 14, minute: 56, second: 3)!
        XCTAssertEqual(pageModel.contains(date: testDate), false)
    }
    
    func testClipViewPositioningWithinBounds() {
        let startDate = Date.dateFor(year: 2018, month: 02, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = Date.dateFor(year: 2018, month: 10, day: 11, hour: 12, minute: 00, second: 00)!
      
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
        let startDate = Date.dateFor(year: 2018, month: 02, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = Date.dateFor(year: 2018, month: 10, day: 11, hour: 12, minute: 00, second: 00)!
        
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
        let startDate = Date.dateFor(year: 2018, month: 02, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = Date.dateFor(year: 2018, month: 10, day: 11, hour: 12, minute: 00, second: 00)!
        
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
        let startDate = Date.dateFor(year: 2018, month: 02, day: 10, hour: 12, minute: 00, second: 00)!
        let endDate = Date.dateFor(year: 2018, month: 10, day: 11, hour: 12, minute: 00, second: 00)!
        
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
        
        let centerDate = Date.dateFor(year: 2012, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        let expectedStartDate =  xCalculator.dateForXPosition(position:(xCalculator.xPositionFor(date: centerDate) - 2500))
        
        var pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             centerDate: centerDate,
                                             length: 5000,
                                             clipViewLength: 300.0)
        pageModel.clipViewRelativeX = 500
        
        
        XCTAssertEqual(expectedStartDate, pageModel.startDate)
    }
    
    func testClipViewDateVisibility() {
        let startDate = Date.dateFor(year: 2022, month: 02, day: 17, hour: 8, minute: 32, second: 00)!
        let expectedStartDate =  xCalculator.dateForXPosition(position:(xCalculator.xPositionFor(date: startDate)))
        
        let pagelModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                              startDate: startDate,
                                              length: 5000,
                                              clipViewLength: 700)
        
        var testDate = xCalculator.dateForXPosition(position: pagelModel.clipViewLength + 100)
        XCTAssertFalse(pagelModel.clipViewContains(date: testDate))

        testDate = xCalculator.dateForXPosition(position: pagelModel.clipViewLength - 200)
        XCTAssertTrue(pagelModel.clipViewContains(date: testDate))

    }
    
    func testCenterDate() {

         let startDate = Date.dateFor(year: 2018, month: 04, day: 10, hour: 12, minute: 00, second: 00)!
        
        var pageModel: PageModel = PageModel(horizontalCalculator: xCalculator,
                                             startDate: startDate,
                                             length: 5000,
                                             clipViewLength: 1000)
        pageModel.clipViewRelativeX = 2346
        let absoluteStartPosition = xCalculator.xPositionFor(date: startDate)
        let centerDate = xCalculator.dateForXPosition(position: absoluteStartPosition + 2346 + 500)
        
        print("centerDatePosition \(xCalculator.xPositionFor(date:centerDate))")
        let centeredPageModel = PageModel(horizontalCalculator: xCalculator,
                                          centerDate: centerDate,
                                          length: 5000,
                                          clipViewLength: pageModel.clipViewLength)
        
        XCTAssertEqual(centerDate, centeredPageModel.clipViewCenterDate)

    }
}


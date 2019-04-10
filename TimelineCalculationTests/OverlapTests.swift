//
//  OverlapTests.swift
//  TimelineCalculationTests
//
//  Created by Altay Cebe on 17.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import XCTest
@testable import Milestones

fileprivate class TestRect: Overlappable {
    var rect: NSRect = NSZeroRect
    init(_ aRect: NSRect) {
        rect = aRect
    }
}

class OverlapTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTwoRectsWithOverlap() {
        let overlapCorrector = OverlapCorrector()
        let rect1: TestRect = TestRect(NSRect(x: 0, y: 0, width: 100, height: 30))
        let rect2: TestRect = TestRect(NSRect(x: 50, y: 0, width: 100, height: 30))
        //averaged center = 75 -> startX = -25
        var testRects: [Overlappable] = [rect1, rect2]
        overlapCorrector.horizontallyCorrectOverlapFor(&testRects)
        
        XCTAssertEqual(rect1.rect.origin.x + rect1.rect.size.width, rect2.rect.origin.x)
        XCTAssertEqual(rect1.rect.origin.x, -25.0)
        XCTAssertEqual(rect2.rect.origin.x, 75.0)
    }
    
    func testTwoRectsWithoutOverlap() {
        let overlapCorrector = OverlapCorrector()
        let rect1: TestRect = TestRect(NSRect(x: 0, y: 0, width: 100, height: 30))
        let rect2: TestRect = TestRect(NSRect(x: 130, y: 0, width: 40, height: 30))
        var testRects: [Overlappable] = [rect1, rect2]
        overlapCorrector.horizontallyCorrectOverlapFor(&testRects)
        
        XCTAssertEqual(rect1.rect.origin.x, 0)
        XCTAssertEqual(rect2.rect.origin.x, 130)
    }
   
    func testThreeRectsWithOverlap() {
        let overlapCorrector = OverlapCorrector()
        let rect1: TestRect = TestRect(NSRect(x: 0, y: 0, width: 100, height: 30))
        let rect2: TestRect = TestRect(NSRect(x: 50, y: 0, width: 80, height: 30))
        let rect3: TestRect = TestRect(NSRect(x: 110, y: 0, width: 100, height: 30))
        
        var testRects: [Overlappable] = [rect1, rect2, rect3]
        overlapCorrector.horizontallyCorrectOverlapFor(&testRects)
        
        XCTAssertFalse(NSIntersectsRect(rect1.rect, rect2.rect))
        XCTAssertFalse(NSIntersectsRect(rect2.rect, rect3.rect))
        XCTAssertFalse(NSIntersectsRect(rect1.rect, rect3.rect))
    }
    
    func testThreeRectsWithOverlapCheckingPosition() {
        let overlapCorrector = OverlapCorrector()
        /*
                 40
                  |-|-|-|-|–|-|-|-|-|–|-| (rect1)
         |-|-|-|-|–| (rect2)
         0     /-/-/-/-/ (rect3)
              30
         */
        let rect1: TestRect = TestRect(NSRect(x: 0, y: 0, width: 50, height: 30))
        let rect2: TestRect = TestRect(NSRect(x: 30, y: 0, width: 40, height: 30))
        let rect3: TestRect = TestRect(NSRect(x: 40, y: 0, width: 100, height: 30))
        
        var testRects: [Overlappable] = [rect1, rect2, rect3]
        overlapCorrector.horizontallyCorrectOverlapFor(&testRects)
        
        XCTAssertFalse(NSIntersectsRect(rect2.rect, rect3.rect))
        XCTAssertFalse(NSIntersectsRect(rect1.rect, rect3.rect))
        XCTAssertFalse(NSIntersectsRect(rect1.rect, rect2.rect))

    }

}

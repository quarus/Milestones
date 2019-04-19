//
//  LineGeneratorTests.swift
//  TimelineCalculationTests
//
//  Created by Altay Cebe on 19.04.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import XCTest
@testable import Milestones


fileprivate struct TestStruct: LineGeneratorProtocol {
    var position: CGPoint = NSZeroPoint
    init(_ aPosition: CGPoint) {
        position = aPosition
    }
}



class LineGeneratorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDifferentNumberOfPoints() {
        let startPoints = [TestStruct(CGPoint(x: 10, y: 0)), TestStruct(CGPoint(x: 20, y: 0))]
        let endPoints = [TestStruct(CGPoint(x: 0, y: 30)), TestStruct(CGPoint(x: 10, y: 30)), TestStruct(CGPoint(x: 20, y: 30))]
        
        let lineGenerator = LineGenerator()
        let graphics = lineGenerator.graphicsForStartPoints(startPoints, endPoints: endPoints)
        
        XCTAssertNil(graphics)

    }
    
    func testEqualNumberOfPoints() {
        
        let startPoints = [TestStruct(CGPoint(x: 0, y: 0)),
                           TestStruct(CGPoint(x: 10, y: 0)),
                           TestStruct(CGPoint(x: 20, y: 0))]
        let endPoints = [TestStruct(CGPoint(x: 0, y: 30)),
                         TestStruct(CGPoint(x: 10, y: 30)),
                         TestStruct(CGPoint(x: 20, y: 30))]
        
        let lineGenerator = LineGenerator()
        let graphics = lineGenerator.graphicsForStartPoints(startPoints, endPoints: endPoints)
        
        XCTAssertNotNil(graphics)
        XCTAssertEqual(graphics!.count, 3)
    }
}

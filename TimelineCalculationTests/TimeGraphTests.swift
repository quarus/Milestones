//
//  TimeGraphTests.swift
//  TimelineCalculationTests
//
//  Created by Altay Cebe on 15.02.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import XCTest
@testable import Milestones


var timelineCount: Int = 0
var numberOfTimelinesCall: String = ""
var numberOfMilestonesCall: String = ""
var numberOfMilestonesInfoCall = ""


class TimeGraphTests: XCTestCase {

    
    var timeGraphModel = TimeGraphModel()
    
    override func setUp() {
        numberOfTimelinesCall = ""
        numberOfMilestonesCall = ""
        numberOfMilestonesInfoCall = ""
        timelineCount = 0
        
        timeGraphModel = TimeGraphModel()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNoTimelinesNoMilestone() {

        var delegate = TimelineCountTestingDelegate()
        delegate.timelineCount = 0
        
        timeGraphModel.delegate = delegate
        timeGraphModel.dataSource = delegate

        timelineCount = 0
        timeGraphModel.reloadData()
        
        XCTAssertEqual(numberOfTimelinesCall, "*")
        XCTAssertEqual(numberOfMilestonesCall, "")
        XCTAssertEqual(numberOfMilestonesInfoCall,"")
    }
    
    func testTwoTimelinesNoMilestone() {
        
        var delegate = TimelineCountTestingDelegate()
        delegate.timelineCount = 2
        
        timeGraphModel.delegate = delegate
        timeGraphModel.dataSource = delegate
        
        timeGraphModel.reloadData()
        
        XCTAssertEqual(numberOfTimelinesCall, "*")
        XCTAssertEqual(numberOfMilestonesCall, "**")
        XCTAssertEqual(numberOfMilestonesInfoCall,"********")

    }
}

//MARK: -
struct TimelineCountTestingDelegate: TimeGraphModelDelegate, TimeGraphModelDataSource {
    
    var timelineCount: Int = 0
    var milestoneCount: Int = 4
    
    //TimeGraphModelDelegate
    func numberOfTimelines() -> Int {
        numberOfTimelinesCall += "*"
        return timelineCount
    }
    
    func numberOfMilestonesForTimelineAt(index: Int) -> Int {
        numberOfMilestonesCall += "*"
        return milestoneCount
    }
    
    //TimeGraphModelDataSource
    func milestoneAtIndex(index: Int, inTimelineAtIndex msIndex: Int) -> MilestoneProtocol {
        numberOfMilestonesInfoCall += "*"
        return MilestoneInfo()
        
    }
}


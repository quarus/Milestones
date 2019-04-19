//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Protocols.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa


typealias Dependencies = HasStateModel & HasCalculators

protocol MilestoneTableCellDataSourceProtocol {
    
    var dateString: String {get}
    var cwString: String {get}
    var nameString: String {get}
    var timeIntervallString: String {get}
    var needsExpandedCell: Bool {get}
    var iconGraphic: IconGraphic {get}
}

enum IconType: Int {
    case Diamond = 0
    case Circle = 1
    case Square = 2
    case TriangleUp = 3
    
}


protocol GroupsManagementModelProtocol {
    
    var selectedGroup: Group? {get set}
    var selectedTimeline: Timeline? {get set}
    var managedObjectContext: NSManagedObjectContext? {get set}
}


protocol StateProtocol: class {

    var zoomLevel: ZoomLevel {get set}

    var selectedGroup: Group? {get set}
    var selectedTimelines: [Timeline] {get set}
    var selectedMilestone: Milestone? {get set}

    var markedTimeline: Timeline? {get set}
    var markedDate: Date? {get set}
    
    var managedObjectContext: NSManagedObjectContext {get set}

    func add(dataObserver: StateObserverProtocol)
    func remove(dataObserver: StateObserverProtocol)
    
    func allGroups() -> [Group]

}

protocol StateObserverProtocol {

    func didChangeZoomLevel(_ level: ZoomLevel)
    func didChangeSelectedGroup(_ group: Group?)
    func didChangeSelectedTimeline(_ selectedTimelines: [Timeline])
    func didChangeSelectedMilestone(_ milestone: Milestone?)
    func didChangeMarkedTimeline(_ markedTimeline: Timeline?)
    func didChangeMarkedDate(_ markedDate: Date?)
}

protocol HasStateModel {
    var stateModel:  StateProtocol {get}
}

protocol HasCalculators {
    var xCalculator: HorizontalCalculator {get set}
    var yCalculator: VerticalCalculator {get set}
}

//MARK: - Zooming
enum ZoomType {
    case MonthAndWeeks
    case QuarterAndMonths
}

struct Zoom {
    
    
    func zoomTypeForLenghtOfDay(length: CGFloat) -> ZoomType{
        if length < 25 {
            return .QuarterAndMonths
        } else {
            return .MonthAndWeeks
        }
    }
}

public enum ZoomLevel: Int{
    //Values decribe the length of a day in pixels for each zoomlevel
    case week = 30
    case month = 15
    case quarter = 10
    case year = 1
}


//MARK:- Calculations
protocol HasHorizontalCalculator {
    var horizontalCalculator: HorizontalCalculator { get }
}

protocol HasVerticalCalculator {
    var verticalCalculator: VerticalCalculator { get }
}

protocol HorizontalCalculator {
    
    var lengthOfDay: CGFloat {get set}
    var lengthOfWeek: CGFloat {get}
    
    func dateForXPosition(position: CGFloat) -> Date
    
    func xPositionFor(date: Date) -> CGFloat
    func centerXPositionFor(date :Date) ->CGFloat
    
    func lengthBetween(firstDate: Date, secondDate: Date) -> CGFloat
    
    func lengthOfQuarter(containing date: Date) -> CGFloat
    func lengthOfYear(containing date: Date) -> CGFloat
    func lengthOf(Quarter quarter: Int, inYear year: Int) -> CGFloat
}

protocol VerticalCalculator {
    
    var heightOfTimeline: CGFloat {get set}
    func yPositionForTimelineAt(index :Int) -> CGFloat
    func centerYPositionForTimelineAt(index :Int) -> CGFloat
    func timelineIndexForYPosition(yPosition: CGFloat) -> Int
}


//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  RulerView.swift
//  Milestones
//
// Copyright (c) 2016 Altay Cebe
//
 

import Foundation
import Cocoa

class RulerView: GraphicView {

    var timelineCalculator :HorizontalCalculator
    private var startDate: Date = Date()
    private var dateLabel: LabelGraphic
    private var dateFormatter: DateFormatter


    init(withLength length: CGFloat, height: CGFloat, horizontalCalculator :HorizontalCalculator){
    
        dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.defaultCalendar()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        timelineCalculator = horizontalCalculator
        dateLabel = LabelGraphic()
        dateLabel.bounds.size.width = 100
        dateLabel.textAlignment = .center

        super.init(frame: NSRect(x: 0, y: 0, width: length, height: height))
        
        backgroundColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateForStartDate(date :Date) {
        
        startDate = date
        
        graphics.removeAll()
        let rulerGraphics = generateGraphics()
        graphics.append(contentsOf: rulerGraphics)
        graphics.append(dateLabel)
        setNeedsDisplay(bounds)
    }
    
    func displayMarkerAtDate(date: Date) {

        if isDateVisible(date: date) {
            let absoluteStartDateX = timelineCalculator.xPositionFor(date: startDate)
            let centerDateX = timelineCalculator.centerXPositionFor(date: date)
            let relativPositionX = centerDateX - absoluteStartDateX

            setNeedsDisplay(dateLabel.bounds)
            dateLabel.text = dateFormatter.string(from: date)
            dateLabel.bounds.origin.x = relativPositionX - (dateLabel.bounds.size.width / 2.0)
            dateLabel.bounds.origin.y = bounds.size.height * 0.75
            setNeedsDisplay(dateLabel.bounds)

        } else {
            dateLabel.text = ""
            setNeedsDisplay(dateLabel.bounds)
        }
    }
    
    private func isDateVisible(date: Date) -> Bool {
        let absoluteStartDateX = timelineCalculator.xPositionFor(date: startDate)
        let centerDateX = timelineCalculator.centerXPositionFor(date: date)

        if centerDateX >= absoluteStartDateX && centerDateX <= absoluteStartDateX + frame.size.width {
            return true
        }
        
        return false
    }
    
    private func generateGraphics() -> [Graphic] {
 
        let graphicsGenerator = RulerGraphicsGenerator(startDate: startDate,
                                                       length: frame.size.width,
                                                       height: frame.size.height)
        
        let graphics = graphicsGenerator.graphicsFor(zoomLevel: .MonthAndWeeks,
                                                     usingCalculator: timelineCalculator)
        return graphics
    }
}


struct RulerGraphicsGenerator {
    
    private(set) var length: CGFloat = 0.0
    private(set) var height: CGFloat = 0.0
    private(set) var startDate: Date = Date()
    private let oneHourInterval :TimeInterval = 60 * 60
    private let calendar = Calendar.defaultCalendar()

    
    init(startDate: Date, length: CGFloat, height: CGFloat) {
        self.length = length
        self.height = height
        self.startDate = startDate
    }
    
    func graphicsFor(zoomLevel: ZoomType,
                     usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        
        switch zoomLevel {
        case .MonthAndWeeks:
            let monthAndCWGraphics = monthGraphicsFor(length: length,
                                                      height: height,
                                                      usingCalculator: timelineCalculator)
            graphics.append(contentsOf: monthAndCWGraphics)
        default:
            break
            
        }
        return graphics
    }
    
    private func quarterGraphicsFor(length: CGFloat, height: CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        
        let xOffset = timelineCalculator.xPositionFor(date: startDate)
        let maxXPosition = timelineCalculator.xPositionFor(date: startDate) + length
        
        //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        let quarterAndYearDateFormatter = DateFormatter()
        quarterAndYearDateFormatter.dateFormat = "qqq/yyyy"
        
        calendar.enumerateFirstDayOfQuartersStarting(fromDate: startDate, usingHandler: {(date: Date?, stop: inout Bool) in
            
            stop = true
            
            if let firstDayOfQuarter = date?.normalized() {
                if timelineCalculator.xPositionFor(date: firstDayOfQuarter) < maxXPosition {
                    
                    stop = false
                    
                    let lengthOfQuarter = timelineCalculator.lengthOfQuarter(containing: firstDayOfQuarter)
                    let xPos = timelineCalculator.xPositionFor(date: firstDayOfQuarter) - xOffset
                    
                    let lineGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: xPos, y: 0),
                                                                  endPoint: CGPoint(x: xPos, y: height),
                                                                  thickness: 1.0)
                    lineGraphic.strokeColor = NSColor.black
                    graphics.append(lineGraphic)
                    
                    let labelGraphic = LabelGraphic()
                    labelGraphic.text = quarterAndYearDateFormatter.string(from: firstDayOfQuarter)
                    labelGraphic.bounds = NSMakeRect(xPos, 0, lengthOfQuarter, height)
                    labelGraphic.fillColor = Config.sharedInstance.quarterBackgroundColorForQuarterNumber(firstDayOfQuarter.numberOfQuarter)
                    labelGraphic.isDrawingFill = true
                    graphics.append(labelGraphic)
                    
                    
                }
                
            }
        })
        
        return graphics
    }
    
    private func monthGraphicsFor(length: CGFloat, height: CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        let xOffset = timelineCalculator.xPositionFor(date: startDate)
        
        
        //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        let monthAndYearDateFormatter = DateFormatter()
        monthAndYearDateFormatter.dateFormat = "LLL'.' YYYY"
        
        //Get the first day of the given dates month
        guard let firstDayOfMonth = startDate.firstDayOfMonth() else {return [Graphic]()}
        var firstDayOfMonthComponents = DateComponents()
        firstDayOfMonthComponents.day = 1
        
        let maxXPosition = length
        
        calendar.enumerateFirstDayOfMonthsStarting(fromDate: firstDayOfMonth.addingTimeInterval(-1 * oneHourInterval), usingHandler: {
            (date: Date?, stop: inout Bool) in
            
            stop = true
            
            if let firstDayOfMonth = date?.normalized(), let endOfMonth = date?.lastDayOfMonth()  {
                
                let xPosition = timelineCalculator.xPositionFor(date: firstDayOfMonth) - xOffset
                if xPosition < maxXPosition {
                    
                    stop = false
                    
                    let lengthOfMonth = timelineCalculator.lengthBetween(firstDate: firstDayOfMonth, secondDate: endOfMonth) + timelineCalculator.lengthOfDay
                    let lineGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: xPosition, y: 0), endPoint: CGPoint(x: xPosition, y: height), thickness: 1.0)
                    
                    let labelGraphic = LabelGraphic()
                    labelGraphic.text = monthAndYearDateFormatter.string(from: date!)
                    labelGraphic.bounds = NSMakeRect(xPosition, 0, lengthOfMonth, height)
                    labelGraphic.fillColor = Config.sharedInstance.monthBackgroundColorForMonthNumber(firstDayOfMonth.numberOfMonth)
                    labelGraphic.isDrawingFill = true
                    
                    graphics.append(lineGraphic)
                    graphics.append(labelGraphic)
                }
            }
            
        })
        
        return graphics
    }
    
    private func calendarWeekGraphicsFor(length: CGFloat, height: CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        
        let xOffset = timelineCalculator.xPositionFor(date: startDate)
        let maxXPosition = timelineCalculator.xPositionFor(date: startDate) + length
        
        //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        let calendarWeekAndYearDateFormatter = DateFormatter()
        calendarWeekAndYearDateFormatter.dateFormat = "'KW' w"
        
        var firstMondayOfCWComponents = DateComponents()
        firstMondayOfCWComponents.weekday = 2 // 2 is a monday
        
        calendar.enumerateFirstMondayOfCalendarWeeksStarting(fromDate: startDate.addingTimeInterval(-1 * oneHourInterval), usingHandler: {(date: Date?, stop: inout Bool) in
            
            stop = true
            
            if let firstDayOfCalendarWeek = date?.normalized() {
                if timelineCalculator.xPositionFor(date: firstDayOfCalendarWeek) < maxXPosition {
                    stop = false
                    
                    let xPos = timelineCalculator.xPositionFor(date: firstDayOfCalendarWeek) - xOffset
                    
                    let lineGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: xPos, y: 0),
                                                                  endPoint: CGPoint(x: xPos, y: height),
                                                                  thickness: 1.0)
                    lineGraphic.strokeColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
                    graphics.append(lineGraphic)
                    
                    let labelGraphic = LabelGraphic()
                    labelGraphic.text = calendarWeekAndYearDateFormatter.string(from: firstDayOfCalendarWeek)
                    labelGraphic.bounds = NSMakeRect(xPos, 0, timelineCalculator.lengthOfWeek, height)
                    labelGraphic.fillColor = Config.sharedInstance.calendarWeekBackgroundColorForCWNumber(firstDayOfCalendarWeek.numberOfCalendarWeek)
                    labelGraphic.isDrawingFill = true
                    graphics.append(labelGraphic)
                }
            }
        })
        
        return graphics
    }
    
}

//
//  MonthAndCalendarGraphicSource.swift
//  Milestones
//
//  Created by Altay Cebe on 03.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

struct MonthAndCalendarGraphicsSource: RulerViewGraphicsSource {

    fileprivate let oneHourInterval :TimeInterval = 60 * 60
    fileprivate let calendar = Calendar.defaultCalendar()

    func rulerView(rulerview: RulerView,
                   graphicsForLength length: CGFloat,
                   height: CGFloat,
                   withStartDate date: Date,
                   using calculator: HorizontalCalculator) -> [Graphic] {
     
        let monthGraphics = monthGraphicsFor(length: length,
                                             height: height,
                                             withStartDate: date,
                                             usingCalculator: calculator)
        
        let weeksGraphic = calendarWeekGraphicsFor(length: length,
                                                   height: height,
                                                   withStartDate: date,
                                                   usingCalculator: calculator)
        
        Graphic.translate(graphics: weeksGraphic, byX: 0, byY: height/2.0)
        var rulerGraphics = [Graphic]()
        rulerGraphics.append(contentsOf: monthGraphics)
        rulerGraphics.append(contentsOf: weeksGraphic)
        return rulerGraphics
    }
    
    private func monthGraphicsFor(length: CGFloat,
                                  height: CGFloat,
                                  withStartDate date: Date,
                                  usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        let xOffset = timelineCalculator.xPositionFor(date: date)
        
        
        //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        let monthAndYearDateFormatter = DateFormatter()
        monthAndYearDateFormatter.dateFormat = "LLL'.' YYYY"
        
        //Get the first day of the given dates month
        guard let firstDayOfMonth = date.firstDayOfMonth() else {return [Graphic]()}
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
    
    
    private func calendarWeekGraphicsFor(length: CGFloat,
                                         height: CGFloat,
                                         withStartDate date: Date,
                                         usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        
        let xOffset = timelineCalculator.xPositionFor(date: date)
        let maxXPosition = timelineCalculator.xPositionFor(date: date) + length
        
        //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        let calendarWeekAndYearDateFormatter = DateFormatter()
        calendarWeekAndYearDateFormatter.dateFormat = "'KW' w"
        
        var firstMondayOfCWComponents = DateComponents()
        firstMondayOfCWComponents.weekday = 2 // 2 is a monday
        
        calendar.enumerateFirstMondayOfCalendarWeeksStarting(fromDate: date.addingTimeInterval(-1 * oneHourInterval), usingHandler: {(date: Date?, stop: inout Bool) in
            
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

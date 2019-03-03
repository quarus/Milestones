//
//  YearAndQuarterDataSource.swift
//  Milestones
//
//  Created by Altay Cebe on 03.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

struct QuarterAndMonthGraphicsSource: RulerViewGraphicsSource {
    
    fileprivate let oneHourInterval :TimeInterval = 60 * 60
    fileprivate let calendar = Calendar.defaultCalendar()

    func rulerView(rulerview: RulerView, graphicsForLength length: CGFloat,
                   height: CGFloat,
                   withStartDate date: Date,
                   using calculator: HorizontalCalculator) -> [Graphic] {
        
        let quarterGraphics = quarterGraphicsFor(length: length,
                                                height: height/2.0,
                                                withStartDate: date,
                                                usingCalculator: calculator)
        
        let monthGraphics = monthGraphicsFor(length: length,
                                            height: height/2.0,
                                            withStartDate: date,
                                            usingCalculator: calculator)
        
        Graphic.translate(graphics: monthGraphics,
                          byX: 0,
                          byY: height/2.0)
        
        var graphics = [Graphic]()
        graphics.append(contentsOf: quarterGraphics)
        graphics.append(contentsOf: monthGraphics)
        return graphics
    }
    
    private func quarterGraphicsFor(length: CGFloat,
                                    height: CGFloat,
                                    withStartDate date: Date,
                                    usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        
        let xOffset = timelineCalculator.xPositionFor(date: date)
        let maxXPosition = timelineCalculator.xPositionFor(date: date) + length
        
        //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        let quarterAndYearDateFormatter = DateFormatter()
        quarterAndYearDateFormatter.dateFormat = "qqq/yyyy"
        
        calendar.enumerateFirstDayOfQuartersStarting(fromDate: date, usingHandler: {(date: Date?, stop: inout Bool) in
            
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
}

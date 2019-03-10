//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  YearAndQuarterGraphicsSource.swift
//  Milestones
//
//  Created by Altay Cebe on 09.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

struct YearAndQuarterGraphicsSource: RulerViewGraphicsSource {
    
    private let calendar = Calendar.defaultCalendar()
    
    func rulerView(rulerview: RulerView, graphicsForLength length: CGFloat, height: CGFloat, withStartDate date: Date, using calculator: HorizontalCalculator) -> [Graphic] {
        var graphics: [Graphic] = [Graphic]()
        
        let quarterGraphics = quarterGraphicsFor(length: length,
                                                 height: height / 2.0,
                                                 withStartDate: date,
                                                 usingCalculator: calculator)
        
        let yearGraphics = yearGraphicsFor(length: length,
                                           height: height/2.0,
                                           withStartDate: date,
                                           usingCalculator: calculator)
        
        Graphic.translate(graphics: quarterGraphics, byX: 0.0, byY: height/2.0)
        
        graphics.append(contentsOf: yearGraphics)
        graphics.append(contentsOf: quarterGraphics)
        
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
        quarterAndYearDateFormatter.dateFormat = "qqq"
        
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
    
    private func yearGraphicsFor(length: CGFloat,
                                    height: CGFloat,
                                    withStartDate date: Date,
                                    usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        
        let xOffset = timelineCalculator.xPositionFor(date: date)
        let maxXPosition = timelineCalculator.xPositionFor(date: date) + length
        
        //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        let yearDateFormatter = DateFormatter()
        yearDateFormatter.dateFormat = "yyyy"
        
        calendar.ennumerateFirstDayOfYearStarting(fromDate: date, usingHandler: {(date: Date?, stop: inout Bool) in
            
            stop = true
            
            if let firstDayOfYear = date?.normalized() {
                if timelineCalculator.xPositionFor(date: firstDayOfYear) < maxXPosition {
                    
                    stop = false
                    
                    let lengthOfYear = timelineCalculator.lengthOfYear(containing: firstDayOfYear)
                    let xPos = timelineCalculator.xPositionFor(date: firstDayOfYear) - xOffset
                    
                    let lineGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: xPos, y: 0),
                                                                  endPoint: CGPoint(x: xPos, y: height),
                                                                  thickness: 1.0)
                    lineGraphic.strokeColor = NSColor.black
                    graphics.append(lineGraphic)
                    
                    let labelGraphic = LabelGraphic()
                    labelGraphic.text = yearDateFormatter.string(from: firstDayOfYear)
                    labelGraphic.bounds = NSMakeRect(xPos, 0, lengthOfYear, height)
                    labelGraphic.fillColor = Config.sharedInstance.yearBackgroundColorForYear(firstDayOfYear.numberOfYear)
                    labelGraphic.isDrawingFill = true
                    graphics.append(labelGraphic)
                    
                    
                }
                
            }
        })
        
        return graphics
    }
}

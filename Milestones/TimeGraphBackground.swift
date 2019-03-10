//
//  TimeGraphBackground.swift
//  Milestones
//
//  Created by Altay Cebe on 10.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa
import GLKit

struct TimeGraphBackground: TimeGraphGraphicsSource {

    func timeGraph(graph: TimeGraph,
                   backgroundGraphicsStartingAt date: Date,
                   forSize size: CGSize,
                   numberOfTimeline timelinesCount: Int,
                   usingHorizontalCalculator horizCalculator: HorizontalCalculator,
                   verticalCalculator vertCalculator: VerticalCalculator) -> [Graphic] {
        
        
        var graphics = [Graphic]()
        let horizontalGraphics = horizontalGraphicsStartingAt(startDate: date,
                                                         height: size.height,
                                                         length: size.width,
                                                         usingCalculator: horizCalculator)
        
        let verticalGraphics  = verticalGraphicsStartingAt(startDate: date,
                                                           height: size.height,
                                                           length: size.width,
                                                           numberOfTimelines: timelinesCount,
                                                           usingCalculator: vertCalculator)
        graphics.append(contentsOf: horizontalGraphics)
        graphics.append(contentsOf: verticalGraphics)
        
        return graphics
    }

    func timeGraph(graph: TimeGraph, adjustmentGraphicsFor milestone: MilestoneProtocol, adjustments: [AdjustmentProtocol], startDate date: Date, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics: [Graphic] = [Graphic]()
        var sourceDate: Date?
        var destinationDate: Date?
        
        let startDatePosition = timelineCalculator.xPositionFor(date: date)
        
        //Loop through all adjustments and figure out what to draw
        for index in 0..<adjustments.count{
            
            //is this the last index?
            if ((index + 1) == adjustments.count) {
                sourceDate = adjustments[index].date
                destinationDate = milestone.date
            } else {
                sourceDate = adjustments[index].date
                destinationDate = adjustments[index+1].date
            }
            
            //draw a line from the adjustment to the milestone, but only if those dates are not equal!
            if (sourceDate != nil) && (destinationDate != nil) && (sourceDate != destinationDate) {
                let sourceXPosition = timelineCalculator.centerXPositionFor(date: sourceDate!)
                let destinationXPosition = timelineCalculator.centerXPositionFor(date: destinationDate!)
                
                let relativeSourceXPosition = sourceXPosition - startDatePosition
                let relativeDestinationXPosition = destinationXPosition - startDatePosition
                
                //Create the icon graphic ...
                let iconGraphic = IconGraphic(type: milestone.type)
                iconGraphic.bounds = NSRect(x: relativeSourceXPosition, y: 0, width: 20, height: 20)
                iconGraphic.bounds = iconGraphic.bounds.centeredHorizontally()
                iconGraphic.strokeColor = NSColor.gray
                iconGraphic.isDrawingStroke = true
                iconGraphic.isDrawingFill = false
                graphics.append(iconGraphic)
                
                // ... then its line
                let offset: CGFloat = iconGraphic.bounds.size.width
                let start = GLKVector2Make(Float(relativeSourceXPosition + offset), 10.0)
                let end = GLKVector2Make(Float(relativeDestinationXPosition), 10.0)
                let direction = GLKVector2Normalize(GLKVector2Subtract(end, start))
                let length = GLKVector2Length(GLKVector2Subtract(end, start)) - Float(offset)
                
                let lineGraphicController = LineGraphicController.lineGraphicControllerWithLineFrom(StartPoint: start, inDirection: direction, withLength: length)
                lineGraphicController.lineGraphic.isDrawingLineDash = true
                lineGraphicController.lineGraphic.lineDash = [2.0, 3.0]
                lineGraphicController.lineGraphic.lineDashCount = 2
                lineGraphicController.lineGraphic.lineDashPhase = 0
                lineGraphicController.drawsArrowHead = true
                
                graphics.append(contentsOf: lineGraphicController.graphics)
            }
        }
        return graphics
    }
    
    private func horizontalGraphicsStartingAt(startDate: Date, height: CGFloat, length: CGFloat, usingCalculator calculator: HorizontalCalculator) -> [Graphic] {
        
        let oneHourInterval :TimeInterval = 60 * 60
        let calendar = Calendar.defaultCalendar()
        var graphics :[Graphic] = [Graphic]()
        let xOffset = calculator.xPositionFor(date: startDate)
        
        calendar.enumerateFirstMondayOfCalendarWeeksStarting(fromDate: startDate.addingTimeInterval(-1 * oneHourInterval), usingHandler:  {(date: Date?, stop: inout Bool) in
            
            if let date = date?.normalized() {
                let xPos = calculator.xPositionFor(date: date) - xOffset
                
                let lineGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: xPos, y: 0), endPoint: CGPoint(x: xPos, y: height), thickness: 1.0)
                lineGraphic.strokeColor = Config.sharedInstance.strokeColor
                graphics.append(lineGraphic)
                
                if xPos > length {
                    stop = true
                }
            }
        })
        return graphics
    }
    
    private func verticalGraphicsStartingAt (startDate: Date,
                                               height: CGFloat,
                                               length: CGFloat,
                                               numberOfTimelines timelineCount: Int,
                                               usingCalculator calculator: VerticalCalculator) -> [Graphic] {
       var graphics = [Graphic]()
        
        for idx in 0..<timelineCount {
            let yPosition = calculator.yPositionForTimelineAt(index: idx)
            let separatorGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: 0, y: yPosition),
                                                               endPoint: CGPoint(x: length, y: yPosition),
                                                               thickness: 1.0)
            
            separatorGraphic.strokeColor = Config.sharedInstance.strokeColor
            graphics.append(separatorGraphic)
        }
        return graphics
    }
}

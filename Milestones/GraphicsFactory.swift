//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  GraphicsFactory.swift
//  Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation
import Cocoa
import GLKit

class GraphicsFactory {

    static let sharedInstance = GraphicsFactory()
    let oneHourInterval :TimeInterval = 60 * 60
    let calendar = Calendar.defaultCalendar()

    private init() {
    }

    
    func graphicsForVerticalCalendarWeeksLinesStartingAt(startDate: Date, height: CGFloat, length: CGFloat, usingCalculator calculator: HorizontalCalculator) -> [Graphic] {

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

    //MARK: Functions for rulers
    func graphicsForVerticalRulerWith(timelines :[Timeline], width :CGFloat, usingCalculator calculator :VerticalCalculator)  -> [Graphic]{
        
        var graphics :[Graphic] = [Graphic]()

        let height = calculator.heightOfTimeline
        
        for index in 0..<timelines.count {
            
            let aTimeline = timelines[index]
            
            if let timelineName = aTimeline.name {
                
                let labelGraphic = LabelGraphic()
                labelGraphic.text = timelineName
                labelGraphic.isDrawingFill = false
                
                let yPos = calculator.yPositionForTimelineAt(index: index)
                labelGraphic.bounds = NSMakeRect(0, yPos , width, height)
                graphics.append(labelGraphic)
            }
        }
        
        return graphics
    }
    
    //MARK: adjustments
    func adjustmentGraphicsFor(milestone: MilestoneProtocol,
                               adjustments: [AdjustmentProtocol],
                               forStartDate date: Date,
                               usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
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
    
    func adjustmentGraphicsFor(milestone :Milestone, length :CGFloat,  startDate :Date, usingCalculator timelineCalculator: HorizontalCalculator) -> ([Graphic]) {
    
        
        guard let adjustments = milestone.adjustments?.array as? [Adjustment] else {return [Graphic]()}
        
        let startDatePosition = timelineCalculator.xPositionFor(date: startDate)

        var graphics: [Graphic] = [Graphic]()
        
        var sourceDate: Date?
        var destinationDate: Date?
        
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
                let iconGraphic = IconGraphic(type: IconType(rawValue: milestone.type.intValue) ?? .Diamond)
                iconGraphic.bounds = NSRect(x: relativeSourceXPosition, y: 0, width: 20, height: 20)
                iconGraphic.bounds = iconGraphic.bounds.centeredHorizontally()
                iconGraphic.strokeColor = NSColor.gray
                iconGraphic.isDrawingStroke = true
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
    
    func timelineGraphicsFor(timeline :Timeline, length :CGFloat, startDate :Date, usingCalculator timelineCalculator: HorizontalCalculator) -> (allGraphics: [Graphic], milestoneGraphicControllers: [MilestoneGraphicController]) {
        
        var milestoneIconGraphics: [[Graphic]] = [[Graphic]]()
        var milestoneLabelGraphics: [[Graphic]] = [[Graphic]]()
        var milestoneGraphicControllers: [MilestoneGraphicController] = [MilestoneGraphicController]()
        var graphics: [Graphic] = [Graphic]()
        
        let overlapCorrector = OverlapCorrector()
        
        let calendarWeekAndDayFormatter = DateFormatter()
        calendarWeekAndDayFormatter.dateFormat = "w.e"
        
        let startDatePosition = timelineCalculator.xPositionFor(date: startDate)
        
        //Draw the horizontal line for that timeline
        
        let separatorGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: length, y: 0), thickness: 1.0)
        separatorGraphic.strokeColor = Config.sharedInstance.strokeColor
        graphics.append(separatorGraphic)
        
        //Draw all milestones on that timeline, but order all milestones by date first. This is needed to ensure proper overlap correction
        if let milestones = timeline.milestonesOrderedByDate() {
            for aMilestone in milestones {

                let showAdjustment = aMilestone.showAdjustments?.boolValue ?? false
                if showAdjustment {
                    let adjustmentGraphics = adjustmentGraphicsFor(milestone: aMilestone, length: length, startDate: startDate, usingCalculator: timelineCalculator)
                    graphics.append(contentsOf: adjustmentGraphics)
                }
                
                if let aDate = aMilestone.date{
                    
                    let positionForMilestoneDate = timelineCalculator.xPositionFor(date: aDate)
                    if (positionForMilestoneDate > startDatePosition) && (positionForMilestoneDate <= startDatePosition + length) {
                                        
                        let xPos = timelineCalculator.centerXPositionFor(date: aDate) - startDatePosition
                        let milestoneGraphicController = GraphicsFactory.sharedInstance.graphicsFor(milestone: aMilestone, withColor: timeline.color ?? Config.sharedInstance.defaultMilestoneColor)
                        
                        milestoneGraphicController.position = CGPoint(x: xPos, y: 0)

                        milestoneIconGraphics.append([milestoneGraphicController.iconGraphic])
                        milestoneLabelGraphics.append([milestoneGraphicController.nameLabel])
                        graphics.append(contentsOf: milestoneGraphicController.graphics)

                        milestoneGraphicControllers.append(milestoneGraphicController)
                        
                        //Add graphics to both array. Call an recursive align method on them
                        overlapCorrector.correctForOverlap(milestoneLabelGraphics: milestoneLabelGraphics,
                                                           milestoneIconGraphics: milestoneIconGraphics)
                        
                    }
                }
            }//For
            
            graphics.insert(contentsOf: overlapCorrector.lineGraphics, at: 0)
            
        }//if
        
        return (graphics, milestoneGraphicControllers)
    }

    //MARK: Indictator lines

    private func lineGraphicWith(height :CGFloat, color :NSColor) -> LineGraphic{

        let line = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: height), thickness: 2.0)
        line.isDrawingLineDash = true
        /*A C-style array of floating point values that contains the lengths (measured in points) of the line segments and gaps in the pattern. The values in the array alternate, starting with the first line segment length, followed by the first gap length, followed by the second line segment length, and so on
         */
        line.lineDash = [2.0, 3.0]

        //The number of values in pattern.
        line.lineDashCount = 2
        line.lineDashPhase = 0
        line.strokeColor = color

        return line
    }

    func graphicsForTodayIndicatorLine(height :CGFloat) -> [Graphic]{

        var graphics :[Graphic] = [Graphic]()
        let lineGraphic = lineGraphicWith(height: height, color: NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        graphics.append(lineGraphic)

        return graphics
    }


    func graphicsForDateIndicatorLine(height :CGFloat) -> [Graphic]{

        var graphics :[Graphic] = [Graphic]()
        let lineGraphic = lineGraphicWith(height: height, color: NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0))
        graphics.append(lineGraphic)

        return graphics
    }


    //MARK:
    func graphicsFor(milestone :Milestone, withColor color:NSColor = Config.sharedInstance.defaultMilestoneColor) -> MilestoneGraphicController{

        let milestoneGraphicController = MilestoneGraphicController(milestone)
        milestoneGraphicController.color = color
        return milestoneGraphicController
 
    }

    //MARK: Export
    func graphicsForExportLabelWith(title :String?, description :String?) -> [Graphic]{

        var graphics :[Graphic] = [Graphic]()

        var heightOfTitleNameLabel :CGFloat = 0
        var heightOfDescriptionLabel :CGFloat = 0
        let heightOfSpacing :CGFloat = 10

        if (title != nil) {
            let nameLabel = LabelGraphic()
            nameLabel.font = NSFont(name: "Helvetica", size: 20)!
            nameLabel.text = title!
            nameLabel.textAlignment = .left
            nameLabel.bounds = NSMakeRect(0, 0, 400, 0)
            nameLabel.sizeToFit()
            heightOfTitleNameLabel = nameLabel.bounds.height + heightOfSpacing

            graphics.append(nameLabel)
        }


        if (description?.count ?? 0 > 0 ){
            let infoLabel = LabelGraphic()
            infoLabel.font = NSFont(name: "Helvetica", size: 14)!
            infoLabel.text = description!
            infoLabel.bounds = NSMakeRect(0, 0, 500, 0)
            infoLabel.textAlignment = .left
            infoLabel.sizeToFit()
            heightOfDescriptionLabel = infoLabel.bounds.height + heightOfSpacing
            Graphic.translate(graphics: [infoLabel], byX: 0.0, byY: heightOfTitleNameLabel)
            graphics.append(infoLabel)
        }

        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let dateLabel = LabelGraphic()
        dateLabel.font = NSFont(name: "Helvetica", size: 12)!
        dateLabel.bounds = NSMakeRect(0, 0, 200, 30)
        dateLabel.text = dateFormatter.string(from: currentDate)
        dateLabel.textAlignment = .left
        dateLabel.sizeToFit()
        Graphic.translate(graphics: [dateLabel], byX: 0.0, byY: heightOfTitleNameLabel + heightOfDescriptionLabel)
        graphics.append(dateLabel)

        return graphics
        
    }
    
    //MARK: New methods
    func monthAndCalendarWeekGraphicsStartingAt(date: Date, totalLength: CGFloat,  height :CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()

        let heightOfYearAndQuarterBar :CGFloat = height / 2.0
        let heightOfCWAndMonthBar :CGFloat =  height / 2.0
        
        let monthGraphics = GraphicsFactory.sharedInstance.monthGraphicsStartingAt(date: date, totalLength: totalLength, height: heightOfYearAndQuarterBar, usingCalculator: timelineCalculator)
        let cwGraphics = GraphicsFactory.sharedInstance.calendarWeekGraphicsStartingAt(date: date, totalLength: totalLength, height: heightOfCWAndMonthBar, usingCalculator: timelineCalculator)

        
        let lineGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x:0, y:0),
                                                      endPoint: CGPoint(x:0, y:totalLength),
                                                      thickness: 1)
    
        Graphic.translate(graphics: cwGraphics, byX: 0, byY: heightOfYearAndQuarterBar)

        
        graphics.append(contentsOf: monthGraphics)
        graphics.append(contentsOf: cwGraphics)
        graphics.append(lineGraphic)
        
        return graphics
    }
    
    func quarterAndYearGraphicsStartingAt(date: Date, totalLength: CGFloat,  height :CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        
        let heightOfYearAndQuarterBar :CGFloat = height / 2.0
        let heightOfCWAndMonthBar :CGFloat =  height / 2.0
        
        let quarterGraphics = GraphicsFactory.sharedInstance.quarterGraphicsStartingAt(date: date, totalLength: totalLength, height: heightOfYearAndQuarterBar, usingCalculator: timelineCalculator)
        let monthGraphics = GraphicsFactory.sharedInstance.monthGraphicsStartingAt(date: date, totalLength: totalLength, height: heightOfCWAndMonthBar, usingCalculator: timelineCalculator)
        
        
        let lineGraphic = LineGraphic.lineGraphicWith(startPoint: CGPoint(x:0, y:0),
                                                      endPoint: CGPoint(x:0, y:totalLength),
                                                      thickness: 1)
        
        Graphic.translate(graphics: monthGraphics, byX: 0, byY: heightOfYearAndQuarterBar)
        
        
        graphics.append(contentsOf: monthGraphics)
        graphics.append(contentsOf: quarterGraphics)
        graphics.append(lineGraphic)
        
        return graphics
    }
    
    private func monthGraphicsStartingAt(date: Date, totalLength: CGFloat, height: CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        let xOffset = timelineCalculator.xPositionFor(date: date)
        
        
        //http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        let monthAndYearDateFormatter = DateFormatter()
        monthAndYearDateFormatter.dateFormat = "LLL'.' YYYY"
        
        //Get the first day of the given dates month
        guard let firstDayOfMonth = date.firstDayOfMonth() else {return [Graphic]()}
        var firstDayOfMonthComponents = DateComponents()
        firstDayOfMonthComponents.day = 1
        
        let maxXPosition = totalLength
        
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
    
    private func calendarWeekGraphicsStartingAt(date: Date, totalLength: CGFloat, height: CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {

        var graphics = [Graphic]()

        let xOffset = timelineCalculator.xPositionFor(date: date)
        let maxXPosition = timelineCalculator.xPositionFor(date: date) + totalLength

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
    
    private func quarterGraphicsStartingAt(date: Date, totalLength: CGFloat, height: CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        var graphics = [Graphic]()
        
        let xOffset = timelineCalculator.xPositionFor(date: date)
        let maxXPosition = timelineCalculator.xPositionFor(date: date) + totalLength
        
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
    
}

extension GraphicsFactory {
    
    func horizonatlRulerGraphicsStartingAt(date: Date, totalLength: CGFloat, height: CGFloat, usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic] {
        
        var graphics = [Graphic]()
        
        let zoom = Zoom()
        let type = zoom.zoomTypeForLenghtOfDay(length: timelineCalculator.lengthOfDay)
        
        switch type {
        case .MonthAndWeeks:
            let monthAndCWGraphics = monthAndCalendarWeekGraphicsStartingAt(date: date,
                                                                            totalLength: totalLength,
                                                                            height: height,
                                                                            usingCalculator: timelineCalculator)
            graphics.append(contentsOf: monthAndCWGraphics)
            
        case .QuarterAndMonths:
            let quarterAndYear = quarterAndYearGraphicsStartingAt(date: date,
                                                                  totalLength: totalLength,
                                                                  height: height,
                                                                  usingCalculator: timelineCalculator)
            graphics.append(contentsOf: quarterAndYear)
            
        }
        return graphics
    }
}



//
//  TimeGraphBackground.swift
//  Milestones
//
//  Created by Altay Cebe on 10.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation

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

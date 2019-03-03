//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Exporter.swift
//  Milestones
//
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class Exporter {

    let dependencies: HasCalculators
    var title: String?
    var description: String?
    
    init(dependencies: HasCalculators) {
        self.dependencies = dependencies
    }

    func exportGroup(group: Group, asType type: ZoomType, fromDate startDate: Date, toDate endDate: Date, toFileAtURL url: URL) {

        var modifiedStartDate: Date?
        var modifiedEndDate: Date?
        
        switch type {
        case .MonthAndWeeks:
            modifiedStartDate = startDate.firstDayOfMonth()
            modifiedEndDate = endDate.lastDayOfMonth()
        case .QuarterAndMonths:
            modifiedStartDate = startDate.startOfQuarter
            modifiedEndDate = endDate.endOfQuarter
            
        }
        guard let mStartDate = modifiedStartDate else {return}
        guard let mEndDate = modifiedEndDate else {return}
        
        self.title = group.exportInfo?.title
        self.description = group.exportInfo?.info
        let graphics = graphicsForGroup(group: group, startDate: mStartDate, endDate: mEndDate)

        let frame = Graphic.boundsOf(graphics: graphics)

        let exportView = GraphicView(frame: frame)
        exportView.graphics = graphics
        

        let pdfData = exportView.dataWithPDF(inside: exportView.frame)
        do {
          try pdfData.write(to: url)
        } catch {
            print("Error while creating file at URL \(url.absoluteString)")
        }
        
    }
    
    private func graphicsForGroup(group :Group, startDate: Date, endDate: Date) -> [Graphic] {

        var graphics: [Graphic] = [Graphic]()
/*
        guard let allTimelines = group.timelines?.array as? [Timeline] else {return graphics}
        
        
        let widthOfVerticalRuler: CGFloat = 120.0
        let heightOfHorizontalRuler: CGFloat = 100.0
        let length = dependencies.xCalculator.xPositionFor(date: endDate) - dependencies.xCalculator.xPositionFor(date: startDate)
  
        let horizontalRulerGraphics = GraphicsFactory.sharedInstance.horizonatlRulerGraphicsStartingAt(date: startDate,
                                                                                                       totalLength: length,
                                                                                                       height: heightOfHorizontalRuler,
                                                                                                       usingCalculator: dependencies.xCalculator)
        
        var verticalRulerGraphics = GraphicsFactory.sharedInstance.graphicsForVerticalRulerWith(timelines: allTimelines,
                                                                                                width: widthOfVerticalRuler,
                                                                                                usingCalculator: dependencies.yCalculator)
        
        var bounds = Graphic.boundsOf(graphics: verticalRulerGraphics)
        bounds.size.height += heightOfHorizontalRuler
        let backgroundRect = RectangleGraphic()
        backgroundRect.bounds = bounds
        backgroundRect.fillColor = Config.sharedInstance.timelineBackgroundColor
        backgroundRect.isDrawingFill = true


        Graphic.translate(graphics: verticalRulerGraphics, byX: 0, byY: heightOfHorizontalRuler)
        verticalRulerGraphics.insert(backgroundRect, at: 0)

        Graphic.translate(graphics: horizontalRulerGraphics, byX: widthOfVerticalRuler, byY: 0)
        
        graphics.append(contentsOf: horizontalRulerGraphics)
        graphics.append(contentsOf: verticalRulerGraphics)
        
        var idx = 0
        var yPos: CGFloat = 0
        for aTimeline in allTimelines {

            yPos = dependencies.yCalculator.yPositionForTimelineAt(index: idx)
            let timelineGraphics = GraphicsFactory.sharedInstance.timelineGraphicsFor(timeline: aTimeline,
                                                                                      length: length,
                                                                                      startDate: startDate,
                                                                                      usingCalculator: dependencies.xCalculator)
            Graphic.translate(graphics: timelineGraphics.allGraphics, byX: widthOfVerticalRuler, byY: yPos + heightOfHorizontalRuler)
            graphics.append(contentsOf: timelineGraphics.allGraphics)

            idx += 1
        }
        
        
        let yOffset = Graphic.boundsOf(graphics: graphics).size.height
        
        if let exportTitle = title, let exportInfo = description {
            let groupInfoLabel = GraphicsFactory.sharedInstance.graphicsForExportLabelWith(title: exportTitle, description: exportInfo)
            Graphic.translate(graphics: groupInfoLabel, byX: widthOfVerticalRuler, byY: yOffset)
            graphics.append(contentsOf: groupInfoLabel)
        }
*/
        return graphics
    }
}

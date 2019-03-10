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
}




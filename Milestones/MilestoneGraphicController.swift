//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MilestoneGraphicController.swift
//  Milestones
//
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class MilestoneGraphicController{
    
    weak var milestone: Milestone?
    var color: NSColor = NSColor.red
    var iconHeight: CGFloat = 20

    private(set) var iconGraphic: IconGraphic = IconGraphic()
    private(set) var dateLabel: LabelGraphic = LabelGraphic()
    private(set) var nameLabel: LabelGraphic = LabelGraphic()
    
    var allGraphics: [Graphic] {
        var graphics: [Graphic] = [Graphic]()
        
        graphics.append(iconGraphic)
        graphics.append(dateLabel)
        graphics.append(nameLabel)
        
        return graphics
    }
    
    var position: CGPoint = CGPoint() {
        didSet {
            iconGraphic.bounds.origin = position
            iconGraphic.bounds = iconGraphic.bounds.centeredHorizontally()
            
            dateLabel.bounds.origin = CGPoint(x: position.x, y: position.y + iconHeight)
            dateLabel.bounds = dateLabel.bounds.centeredHorizontally()
            
            nameLabel.bounds.origin = CGPoint(x: position.x, y: dateLabel.bounds.origin.y + dateLabel.bounds.size.height)
            nameLabel.bounds = nameLabel.bounds.centeredHorizontally()
        }
    }
    
    init(_ milestone: Milestone?) {
        
        
        self.milestone = milestone
        
        let calendarWeekAndDayFormatter = DateFormatter()
        calendarWeekAndDayFormatter.dateFormat = "w.e"

        iconGraphic.fillColor = self.milestone?.timeline?.color ?? NSColor.red
        iconGraphic.isDrawingFill = true
        iconGraphic.userInfo = self

        let milestoneGraphicBounds = NSMakeRect(0, 0, iconHeight, iconHeight)
        iconGraphic.bounds = milestoneGraphicBounds.centeredHorizontally()
        
        if let date = milestone?.date {
            dateLabel.text = calendarWeekAndDayFormatter.string(from: date)
            dateLabel.bounds = NSMakeRect(0, 0, 100, 0).centeredHorizontally()
            dateLabel.isDrawingFill = false
            dateLabel.fillColor = NSColor.white
            dateLabel.sizeToFit()
            dateLabel.userInfo = self
        }
        
        if let name = milestone?.name {
            nameLabel.text = name
            nameLabel.bounds = NSMakeRect(0, 0, 100, 0)
            nameLabel.isDrawingFill = true
            nameLabel.fillColor = NSColor.white
            nameLabel.sizeToFit()
            nameLabel.userInfo = self
        }
        
        self.position = CGPoint(x: 0, y: 0)
    }
    
}

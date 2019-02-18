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

class MilestoneGraphicController: NSObject, GraphicController {

    var userInfo: AnyObject?
        
    var color: NSColor = NSColor.red
    var iconHeight: CGFloat = 20

    private(set) var iconGraphic: IconGraphic = IconGraphic()
    private(set) var dateLabel: LabelGraphic = LabelGraphic()
    private(set) var nameLabel: LabelGraphic = LabelGraphic()
    
    var graphics: [Graphic] {
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
        
        super.init()
        let fillColor = milestone?.timeline?.color ?? NSColor.red
        setupIconFor(color: fillColor)

        iconGraphic.bounds = NSMakeRect(0, 0, iconHeight, iconHeight)
        if let date = milestone?.date {
            setupDateLabelFor(date: date)
        }
        
        if let name = milestone?.name {
            setupNameLabelFor(name: name)
        }
    }
    
    init(_ milestone: MilestoneProtocol) {
        super.init()

        setupIconFor(color: milestone.color)
        setupDateLabelFor(date: milestone.date)
        setupNameLabelFor(name: milestone.name)
    }
    
    private func setupIconFor(color: NSColor) {
        iconGraphic.userInfo = self
        iconGraphic.fillColor = color
        iconGraphic.bounds = NSMakeRect(0, 0, iconHeight, iconHeight)
    }
    
    private func setupDateLabelFor(date: Date) {
        let calendarWeekAndDayFormatter = DateFormatter()
        calendarWeekAndDayFormatter.dateFormat = "w.e"

        dateLabel.text = calendarWeekAndDayFormatter.string(from: date)
        dateLabel.bounds = NSMakeRect(0, 0, 100, 0).centeredHorizontally()
        dateLabel.isDrawingFill = false
        dateLabel.fillColor = NSColor.white
        dateLabel.sizeToFit()
        dateLabel.userInfo = self
    }
    
    private func setupNameLabelFor(name: String) {
        nameLabel.text = name
        nameLabel.bounds = NSMakeRect(0, 0, 100, 0)
        nameLabel.isDrawingFill = true
        nameLabel.fillColor = NSColor.white
        nameLabel.sizeToFit()
        nameLabel.userInfo = self
    }
}



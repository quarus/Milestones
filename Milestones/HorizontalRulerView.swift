//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  RulerView.swift
//  Milestones
//
// Copyright (c) 2016 Altay Cebe
//
 

import Foundation
import Cocoa

class HorizontalRulerView :GraphicView {

    var timelineCalculator :HorizontalCalculator
    private var startDate: Date?
    private var dateLabel: LabelGraphic
    private var dateFormatter: DateFormatter

    
    init(withLength length: CGFloat, height: CGFloat, horizontalCalculator :HorizontalCalculator){
    
        dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.defaultCalendar()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        timelineCalculator = horizontalCalculator
        dateLabel = LabelGraphic()
        dateLabel.bounds.size.width = 100
        dateLabel.textAlignment = .center

        super.init(frame: NSRect(x: 0, y: 0, width: length, height: height))
        
        backgroundColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateForStartDate(date :Date) {
        
        startDate = date
        
        let length = self.frame.size.width
        let height = self.frame.size.height
        let rulerGraphics = GraphicsFactory.sharedInstance.horizonatlRulerGraphicsStartingAt(date: date,
                                                                              totalLength: length,
                                                                              height: height * 0.75,
                                                                              usingCalculator: timelineCalculator)
        graphics.removeAll()
        graphics.append(contentsOf: rulerGraphics)
        graphics.append(dateLabel)
        setNeedsDisplay(bounds)
    }
    
    func displayMarkerAtDate(date: Date) {
        guard let firstDate = startDate else {return}
        let absoluteStartDateX = timelineCalculator.xPositionFor(date: firstDate)
        let centerDateX = timelineCalculator.centerXPositionFor(date: date)
        let relativPositionX = centerDateX - absoluteStartDateX

        setNeedsDisplay(dateLabel.bounds)
        dateLabel.text = dateFormatter.string(from: date)
        dateLabel.bounds.origin.x = relativPositionX - (dateLabel.bounds.size.width / 2.0)
        dateLabel.bounds.origin.y = bounds.size.height * 0.75
        setNeedsDisplay(dateLabel.bounds)
    }
}

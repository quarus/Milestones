//
//  MilestoneView.swift
//  Milestones
//
//  Created by Altay Cebe on 10.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class MilestoneView: GraphicView {
    
    private let iconSize: CGFloat = 20.0
    private let length: CGFloat = 100.0
    private(set) var iconGraphic: IconGraphic = IconGraphic()
    private(set) var dateLabel: LabelGraphic = LabelGraphic()
    
    var isSelected: Bool = false {
        didSet {
            iconGraphic.isSelected = isSelected
            self.needsDisplay = true
        }
    }
    
    init(milestone: MilestoneProtocol) {
        super.init(frame: NSMakeRect(0, 0, length, 50))
        backgroundColor = .clear
        
        let iconView = GraphicView(frame: NSMakeRect(length/2.0 - iconSize/2.0, 0, iconSize, iconSize))
        setupIconFor(color: milestone.color)
        iconView.backgroundColor = .clear
        iconView.graphics.append(iconGraphic)
        
        setupDateLabelFor(date: Date())
        let labelView = GraphicView(frame: NSMakeRect(length/2.0 - dateLabel.bounds.size.width/2.0,
                                                      iconSize,
                                                      dateLabel.bounds.size.width,
                                                      dateLabel.bounds.size.height))
        labelView.backgroundColor = .clear
        labelView.graphics.append(dateLabel)
        
        addSubview(labelView)
        addSubview(iconView)
        
        frame = NSMakeRect(frame.origin.x,
                           frame.origin.y,
                           frame.size.width,
                           iconSize + dateLabel.bounds.size.height)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIconFor(color: NSColor) {
        iconGraphic.userInfo = self
        iconGraphic.fillColor = color
        iconGraphic.bounds = NSMakeRect(0, 0, iconSize, iconSize)
    }
    
    private func setupDateLabelFor(date: Date) {
        let calendarWeekAndDayFormatter = DateFormatter()
        calendarWeekAndDayFormatter.dateFormat = "w.e"
        
        dateLabel.text = calendarWeekAndDayFormatter.string(from: date)

        dateLabel.bounds = NSMakeRect(0, 0, 100, 0)
        dateLabel.isDrawingFill = false
        dateLabel.strokeColor = .black
        dateLabel.fillColor = NSColor.clear
        dateLabel.sizeToFit()
        dateLabel.userInfo = self
    }
}

extension MilestoneView: LineGeneratorProtocol {    
    var position: CGPoint {            
        return CGPoint(x: frame.origin.x + frame.size.width / 2.0,
                        y: frame.origin.y + frame.size.height / 2.0)
    }
}

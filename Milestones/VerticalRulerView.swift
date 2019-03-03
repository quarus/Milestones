//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  VerticalRulerView.swift
//  Milestones
//
// Copyright (c) 2016 Altay Cebe
//


import Foundation
import Cocoa

class VerticalRulerview :GraphicView{

    let totalWidthOfBar :CGFloat
    var yOffset :CGFloat = 100
    var yPositionCalculator :VerticalCalculator
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(withLength length: CGFloat, positionCalculator :VerticalCalculator) {
        totalWidthOfBar = length
        yPositionCalculator = positionCalculator
        super.init(frame: NSZeroRect)
        backgroundColor = Config.sharedInstance.timelineBackgroundColor

    }

    func updateFor(timelines :[Timeline]) {
        
        graphics.removeAll()
        graphics = graphicsForTimelines(timelines: timelines,
                                        width: totalWidthOfBar,
                                        usingCalculator: yPositionCalculator)
        
        let totalHeightOfGraphics = Graphic.boundsOf(graphics: graphics).size.height + yPositionCalculator.heightOfTimeline + yOffset
        let currentOrigin = self.frame.origin
        self.frame = NSRect(x: currentOrigin.x, y: currentOrigin.y, width: totalWidthOfBar, height: totalHeightOfGraphics)
        self.setNeedsDisplay(self.bounds)

    }
    
    private func graphicsForTimelines(timelines :[Timeline],
                                                 width :CGFloat,
                                                 usingCalculator calculator :VerticalCalculator)  -> [Graphic] {
        
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
}

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
    
    init(withLength length: CGFloat, height: CGFloat, horizontalCalculator :HorizontalCalculator){
    
        timelineCalculator = horizontalCalculator
        super.init(frame: NSRect(x: 0, y: 0, width: length, height: height))
        
        backgroundColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateForStartDate(date :Date) {
        
        
        let length = self.frame.size.width
        let height = self.frame.size.height
        let rulerGraphics = GraphicsFactory.sharedInstance.horizonatlRulerGraphicsStartingAt(date: date,
                                                                              totalLength: length,
                                                                              height: height,
                                                                              usingCalculator: timelineCalculator)
        graphics.removeAll()
        graphics.append(contentsOf: rulerGraphics)
        setNeedsDisplay(bounds)
            
    }
    
}

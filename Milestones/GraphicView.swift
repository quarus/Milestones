//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  GraphicView.swift
//  Milestones
//
// Copyright (c) 2016 Altay Cebe
//


import Foundation
import Cocoa

class GraphicView :NSView {
    
    
    var backgroundColor :NSColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    override var isOpaque: Bool {
        get {
            return true
        }
    }
    
    //Place the origin at the upper left corner, with positive y going down and positive x going right
    override var isFlipped:Bool {
        get {
            return true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }

    //the graphics to be drawn
    var graphics = [Graphic]()
    
    //TODO: Only make the grid objects draw once
    override func draw(_ dirtyRect: NSRect) {
        
        backgroundColor.set()
        dirtyRect.fill()
        
        //Fetch the current drawing context
        let currentContext = NSGraphicsContext.current
        
        //Loop through all graphics and draw them
        for aGraphic in graphics {
            
            let graphicsDrawingBounds = aGraphic.drawingBounds()
            if (NSIntersectsRect(dirtyRect, graphicsDrawingBounds)) {
                currentContext?.saveGraphicsState()
                aGraphic.drawContentsInView(self)
                currentContext?.restoreGraphicsState()
            }
        }
    }
    
}

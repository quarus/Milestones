//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// MilestoneGraphic.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//



import Foundation
import Cocoa

class IconGraphic: Graphic {

    var type :IconType = .Diamond
    var isSelected: Bool = false
    
    init(type: IconType = .Diamond) {

        self.type = type
    }

    override func bezierPathForDrawing() -> NSBezierPath? {

        var returnPath :NSBezierPath?

        switch type {
        case .Diamond:
            returnPath = bezierPathForDiamondShape()
        case .Circle:
            returnPath = bezierPathForCircleShape()
        case .Square:
            returnPath = bezierPathForSquareShape()
        case .TriangleUp:
            returnPath = bezierPathForTriangleUpShape()
        }

        return returnPath
    }
    
    override func drawContentsInView(_ aView :NSView) {
        
        guard let bezierPath = bezierPathForDrawing() else {
            return
        }
        
        if (isDrawingLineDash){
            if let dash = lineDash {
                bezierPath.setLineDash(dash, count: lineDashCount, phase: lineDashPhase)
            }
        }
        
        if (isDrawingFill){
            fillColor.set()
            bezierPath.fill()
        }
        
        if (isDrawingStroke) {
            strokeColor.set()
            bezierPath.stroke()
        }
        
        if (isSelected) {
            NSColor.blue.set()
            bezierPath.lineWidth = strokeWidth * 1.5
            bezierPath.stroke()
        }
    }


    //MARK: Bezierpaths for different Shapes
    private func bezierPathForDiamondShape() -> NSBezierPath? {

        let aPath = NSBezierPath()
        aPath.lineWidth = strokeWidth
        aPath.move(to: NSPoint(x: bounds.origin.x, y: bounds.origin.y))
        aPath.relativeMove(to: NSPoint(x: bounds.size.width / 2, y: 0))
        aPath.relativeLine(to: NSPoint(x: bounds.size.width / 2, y: bounds.size.height / 2))
        aPath.relativeLine(to: NSPoint(x: -bounds.size.width / 2, y: bounds.size.height / 2))
        aPath.relativeLine(to: NSPoint(x: -bounds.size.width / 2, y: -bounds.size.height / 2))
        aPath.relativeLine(to: NSPoint(x: bounds.size.width / 2, y: -bounds.size.height / 2))
        return aPath
    }

    private func bezierPathForSquareShape() -> NSBezierPath? {

        let aPath = NSBezierPath()
        aPath.lineWidth = strokeWidth
        aPath.move(to: NSPoint(x: bounds.origin.x, y: bounds.origin.y))
        aPath.relativeLine(to: NSPoint(x: bounds.size.width, y: 0))
        aPath.relativeLine(to: NSPoint(x: 0, y: bounds.size.height))
        aPath.relativeLine(to: NSPoint(x: -bounds.size.width, y: 0))
        aPath.relativeLine(to: NSPoint(x: 0, y: -bounds.size.height))
        return aPath
    }


    private func bezierPathForCircleShape() -> NSBezierPath? {

        let aPath = NSBezierPath(ovalIn: bounds)
        aPath.lineWidth = strokeWidth

        return aPath
    }

    private func bezierPathForTriangleUpShape() -> NSBezierPath? {
        let aPath = NSBezierPath()
        aPath.move(to: NSPoint(x: bounds.origin.x + bounds.size.width/2.0 , y: bounds.origin.y))
        aPath.relativeLine(to: NSPoint(x: -bounds.size.width/2.0, y: bounds.size.height))
        aPath.relativeLine(to: NSPoint(x: bounds.size.width, y: 0))
        aPath.relativeLine(to: NSPoint(x: -bounds.size.width/2.0, y: -bounds.size.height))
        return aPath
    }

}

//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Line.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//


import Foundation
import Cocoa

class LineGraphic :Graphic {

    var pointsRight :Bool = false
    var pointsDown :Bool = false

    var beginPoint :CGPoint{
        get {
            var beginPoint = CGPoint(x:0, y:0)
            beginPoint.x = pointsRight ? NSMinX(bounds) : NSMaxX(bounds)
            beginPoint.y = pointsDown ? NSMinY(bounds) : NSMaxY(bounds)
            return beginPoint

        }

        set {
            bounds = boundsWith(beginPoint: newValue, endPoint: endPoint, pointsRight:&pointsRight, pointsDown: &pointsDown)
        }
    }

    var endPoint :CGPoint{
        get {
            var endPoint =  CGPoint(x:0, y:0)
            endPoint.x = pointsRight ? NSMaxX(bounds) : NSMinX(bounds)
            endPoint.y = pointsDown ? NSMaxY(bounds) : NSMinY(bounds)
            return endPoint;

        }

        set {
            bounds = boundsWith(beginPoint: beginPoint, endPoint: newValue, pointsRight:&pointsRight, pointsDown: &pointsDown)
        }

    }

    class func lineGraphicWith(startPoint :CGPoint, endPoint :CGPoint, thickness :CGFloat) -> LineGraphic {

        let lineGraphic = LineGraphic()
        lineGraphic.beginPoint = startPoint
        lineGraphic.endPoint = endPoint
        lineGraphic.isDrawingStroke = true
        lineGraphic.strokeWidth = thickness
        lineGraphic.strokeColor = NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)

        return lineGraphic
    }

    override init (){
        
        super.init()
        
        beginPoint = CGPoint.zero
        endPoint = CGPoint.zero
        isDrawingStroke = true
        strokeWidth = 1.0
        strokeColor = NSColor.black
    }
    
    func boundsWith(beginPoint :CGPoint, endPoint :CGPoint, pointsRight : inout Bool, pointsDown : inout Bool) -> NSRect {

        pointsRight = (beginPoint.x<endPoint.x)
        pointsDown = (beginPoint.y<endPoint.y)
        let xPosition = pointsRight ? beginPoint.x : endPoint.x
        let yPosition = pointsDown ? beginPoint.y : endPoint.y
        let width = fabs(endPoint.x - beginPoint.x)
        let height = fabs(endPoint.y - beginPoint.y)

        return NSMakeRect(xPosition, yPosition, width, height)
    }


    override func bezierPathForDrawing() -> NSBezierPath? {

        let aPath = NSBezierPath()
        aPath.lineWidth = strokeWidth
        aPath.move(to: beginPoint)
        aPath.line(to: endPoint)
        return aPath

    }

}

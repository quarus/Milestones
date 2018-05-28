//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Graphic.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//


import Foundation
import Cocoa

class Graphic :NSObject {


    var userInfo :AnyObject?

    @objc dynamic var bounds :NSRect = NSZeroRect
    var fillColor :NSColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var strokeColor :NSColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var strokeWidth :CGFloat = 2.0

    var lineDash: [CGFloat]?
    var lineDashCount :Int = 0
    var lineDashPhase :CGFloat = 0

    var isDrawingStroke :Bool = false
    var isDrawingLineDash :Bool = false
    var isDrawingFill :Bool = false


    class func translate(graphics:[Graphic], byX deltaX:CGFloat, byY deltaY:CGFloat){

        for aGraphic in graphics{
            aGraphic.bounds = NSOffsetRect(aGraphic.bounds, deltaX, deltaY)
        }
    }

    class func boundsOf(graphics :[Graphic]) -> NSRect{

        // The bounds of an array of graphics is the union of all of their bounds.
        var bounds = NSZeroRect;
        for aGraphic in graphics{
            bounds = NSUnionRect(bounds, aGraphic.bounds)
        }
        return bounds
    }

    class func drawingBoundsOf(graphics :[Graphic]) -> NSRect{
        // The drawing bounds of an array of graphics is the union of all of their drawing bounds.
        var drawingBounds = NSZeroRect
        for aGraphic in graphics{
            drawingBounds = NSUnionRect(drawingBounds, aGraphic.drawingBounds())
        }
        return drawingBounds
    }

    override init(){
        super.init()
    }

    //TODO: init function mit stroke, fill color & bounds?

    func drawingBounds() ->NSRect{

        var strokeOutset :CGFloat = 0.0
        if (isDrawingStroke) {
            strokeOutset = strokeWidth / 2.0;
        }

        let inset = 0.0 - strokeOutset
        let drawingBounds = NSInsetRect(bounds, inset, inset)
        return drawingBounds
    }

    func drawContentsInView(_ aView :NSView) {

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
    }

    func bezierPathForDrawing() -> NSBezierPath? {
        //Override me
        return nil
    }

    func isContentUnderPoint(_ aPoint :NSPoint) -> Bool {
        return NSPointInRect(aPoint, bounds)
    }

    //MARK: KVO
    class func keyPathsForValuesAffectingDrawingBounds() -> NSSet{
        let setOfKeyPaths = NSSet(array: ["bounds"])
        return setOfKeyPaths
    }
}

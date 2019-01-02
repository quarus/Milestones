//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  LineGraphicController.swift
//  Milestones
//
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa
import GLKit

class LineGraphicController: GraphicController {

    var userInfo :AnyObject?

    var drawsArrowHead = false {
        didSet {
            update()
        }
    }
    
    var startPoint: CGPoint = CGPoint.zero {
        didSet {
            update()
        }
    }
    var endPoint: CGPoint = CGPoint.zero {
        didSet {
            update()
        }
    }
    
    var graphics: [Graphic] {
        var graphics: [Graphic] = [Graphic]()
        
        graphics.append(lineGraphic)
        graphics.append(arrowHeadGraphic)
        
        return graphics
    }
    
    private(set) var lineGraphic = LineGraphic()
    private(set) var arrowHeadGraphic = ArrowHeadGraphic()
    
    class func lineGraphicControllerWithLineFrom(StartPoint start: GLKVector2,
                                                 inDirection direction: GLKVector2,
                                                 withLength length: Float) ->
        LineGraphicController {
        
        let lineGraphicController = LineGraphicController()
        var endPoint = GLKVector2Add(start, GLKVector2MultiplyScalar(direction, length))
            
        lineGraphicController.startPoint = CGPoint(x: CGFloat(start.x), y: CGFloat(start.y))
        lineGraphicController.endPoint = CGPoint(x: CGFloat(endPoint.x), y: CGFloat(endPoint.y))
            
        return lineGraphicController
    }
    
    init() {
        lineGraphic.userInfo = self
        arrowHeadGraphic.userInfo = self
        
        arrowHeadGraphic.bounds = NSRect(x: endPoint.x, y: 0, width: 20, height: 20)
        arrowHeadGraphic.isDrawingFill = true
        arrowHeadGraphic.fillColor = lineGraphic.strokeColor
    }
    
    private func update() {
        
        //Reposition the line
        lineGraphic.beginPoint = startPoint
        lineGraphic.endPoint = endPoint
        
        //Reposition the arrow head
        if (drawsArrowHead) {
            let yAxisVector = GLKVector2Normalize(GLKVector2Make(0, 1))
            let startVector = GLKVector2Make(Float(startPoint.x), Float(startPoint.y))
            let endVector = GLKVector2Make(Float(endPoint.x), Float(endPoint.y))
    
            let directionalVector = GLKVector2Normalize(GLKVector2Subtract(endVector, startVector))
            let angleInRadians = atan2(yAxisVector.y, yAxisVector.x) - atan2(directionalVector.y, directionalVector.x)
            let angleInDegrees = GLKMathRadiansToDegrees(angleInRadians)
    
            arrowHeadGraphic.angleInDegree = CGFloat(angleInDegrees)
            arrowHeadGraphic.bounds = NSRect(x: endPoint.x, y: endPoint.y, width: 5, height: 10)
        }
    }
}

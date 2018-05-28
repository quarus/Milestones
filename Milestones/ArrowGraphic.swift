//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// ArrowGraphic.swift
// Milestones
//
// Created by Altay Cebe on 14.04.18.
// Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class ArrowHeadGraphic: Graphic {

    var angleInDegree: CGFloat = 0
    
    private func pathForArrowHead() -> NSBezierPath {

        let arrowHeadPath = NSBezierPath()
        let height = bounds.size.height
        let width   = bounds.size.width

        //Draw an arrow head with its tip at (0,0)
        arrowHeadPath.move(to: CGPoint(x: -(width/2.0), y: (height/2)))
        arrowHeadPath.line(to: CGPoint(x: 0, y: 0))
        arrowHeadPath.line(to: CGPoint(x: (width/2.0), y: (height/2)))
 

        return arrowHeadPath
    }
    
    override init() {
        
        super.init()
    }
    
    override func bezierPathForDrawing() -> NSBezierPath? {

        //1. get the default path for an arrow head
        let arrowHeadPath = pathForArrowHead()
        
        //2. rotate the the paths according to the given angle around (0,0)
        var rotateTransform: AffineTransform = AffineTransform()
        rotateTransform.rotate(byDegrees: angleInDegree)
        arrowHeadPath.transform(using: rotateTransform)
        
        //3. translate it to the proper position
        var translateTransform: AffineTransform = AffineTransform()
        translateTransform.translate(x: bounds.origin.x, y: bounds.origin.y)
        arrowHeadPath.transform(using: translateTransform)
        
        return arrowHeadPath
        
    }
}

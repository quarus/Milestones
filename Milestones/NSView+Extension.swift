//
//  NSView+Extension.swift
//  Milestones
//
//  Created by Altay Cebe on 10.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

extension NSView {
    
    func centerHorizontally() {
        frame = NSMakeRect(frame.origin.x - frame.size.width/2.0,
                           frame.origin.y,
                           frame.size.width,
                           frame.size.height)
    }
    
    func centerVertically() {
        frame = NSMakeRect(frame.origin.x,
                           frame.origin.y - frame.size.height/2.0,
                           frame.size.width,
                           frame.size.height)
    }
    
    func center() -> CGPoint {
        let x = (frame.size.width / 2.0) + frame.origin.x
        let y = (frame.size.height / 2.0) + frame.origin.y
        
        return CGPoint(x: x, y: y)
    }
    
    class func boundsOf(views :[NSView]) -> NSRect{
        
        var bounds = NSZeroRect;
        for aView in views{
            bounds = NSUnionRect(bounds, aView.frame)
        }
        return bounds
    }
    
    func removeAllSubViews() {
        subviews.forEach({$0.removeFromSuperview()})
    }
}

//
//  DateIndicatorGraphicController.swift
//  Milestones
//
//  Created by Altay Cebe on 02.01.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import GLKit

class DateIndicatorController: GraphicController {
    var userInfo: AnyObject?
    var graphics: [Graphic] {
        var allGraphics = [Graphic]()
        allGraphics.append(contentsOf: datelineGraphicController.graphics)
        allGraphics.append(milestoneGraphic)
        return allGraphics
    }
    
    var xPosition: CGFloat = 0.0 {
        didSet {
            update()
        }
    }
    
    var yPosition: CGFloat = 0.0 {
        didSet {
            update()
        }
    }

    private(set) var datelineGraphicController: LineGraphicController
    private let milestoneGraphic: IconGraphic
    private let iconSize: CGFloat = 20.0
    
    init(height: CGFloat, xPosition: CGFloat = 0.0) {

        datelineGraphicController = LineGraphicController.lineGraphicControllerWithLineFrom(StartPoint: GLKVector2Make(0, 0),
                                                                                  inDirection: GLKVector2Make(0, 1),
                                                                                  withLength: Float(height))
        self.xPosition = xPosition
        
        milestoneGraphic = IconGraphic(type: .Diamond)
        milestoneGraphic.strokeColor = NSColor.gray
        milestoneGraphic.fillColor = NSColor.white
        milestoneGraphic.isDrawingStroke = true
        milestoneGraphic.isDrawingFill = true
        milestoneGraphic.bounds = NSMakeRect(0, 0, iconSize, iconSize)
        update()
    }
    
    private func update() {
        datelineGraphicController.startPoint.x = xPosition
        datelineGraphicController.endPoint.x = datelineGraphicController.startPoint.x
        milestoneGraphic.bounds.origin = CGPoint(x: datelineGraphicController.startPoint.x - (iconSize/2.0),
                                                 y: yPosition)
    }
}

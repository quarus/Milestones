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
        return allGraphics
    }
    
    var xPosition: CGFloat = 0.0 {
        didSet {
            update()
        }
    }

    private(set) var datelineGraphicController: LineGraphicController
    
    
    init(height: CGFloat, xPosition: CGFloat = 0.0) {

        datelineGraphicController = LineGraphicController.lineGraphicControllerWithLineFrom(StartPoint: GLKVector2Make(0, 0),
                                                                                  inDirection: GLKVector2Make(0, 1),
                                                                                  withLength: Float(height))
        self.xPosition = xPosition
        update()
    }
    
    private func update() {
        datelineGraphicController.startPoint.x = xPosition
        datelineGraphicController.endPoint.x = xPosition
    }

    
}

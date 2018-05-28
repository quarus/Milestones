//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  RectGraphic.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class RectangleGraphic: Graphic {
    
    override func bezierPathForDrawing() -> NSBezierPath? {
        let bezierBath = NSBezierPath(rect: bounds)
        return bezierBath
    }
}

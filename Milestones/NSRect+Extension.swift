//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// NSRect+Extension.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//


import Foundation

extension NSRect {

    func centeredRectAround(point :NSPoint) -> NSRect{

        let newX = origin.x - size.width / 2
        let newY = origin.y - size.height / 2
        let centeredRect = NSMakeRect(newX, newY, size.width, size.height)
        return centeredRect
    }

    func centeredHorizontally() -> NSRect {
        let newX = origin.x - size.width / 2
        let centeredRect = NSMakeRect(newX, origin.y, size.width, size.height)
        return centeredRect
    }

    func center() -> CGPoint {
        let centerX = (size.width / 2) + origin.x
        let centerY = (size.height / 2) + origin.y

        return CGPoint(x: centerX, y: centerY)
    }
}

//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Zoom.swift
//  Milestones
//
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

enum ZoomType {
    case MonthAndWeeks
    case QuarterAndMonths
}

struct Zoom {
    
    
    func zoomTypeForLenghtOfDay(length: CGFloat) -> ZoomType{
        if length < 25 {
            return .QuarterAndMonths
        } else {
            return .MonthAndWeeks
        }
    }
}

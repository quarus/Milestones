//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MilestoneProtocol.swift
//  Milestones
//
//  Created by Altay Cebe on 15.02.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

protocol MilestoneProtocol {

    var type: IconType {get set}
    var color: NSColor {get set}
    var name: String {get set}
    var info: String? {get set}
    var date: Date {get set}

}

struct MilestoneInfo: MilestoneProtocol {
    
    var type: IconType
    var color: NSColor
    var name: String
    var info: String?
    var date: Date
    
    init () {
        type = .Diamond
        color = .red
        name = ""
        date = Date()
    }
    
    init(_ milestone: Milestone) {
        type = IconType(rawValue: milestone.type.intValue) ?? .Diamond
        color = milestone.timeline?.color ?? .red
        name = milestone.name ?? ""
        info = milestone.info 
        date = milestone.date ?? Date(timeIntervalSince1970: 0)
    }
}

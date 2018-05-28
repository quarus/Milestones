//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MilestoneTableViewCell.swift
//  Milestones
//
//  Copyright © 2016 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class MilestoneTableCellView :NSTableCellView {

    @IBOutlet weak var iconView: GraphicView!
    @IBOutlet weak var calendarWeekTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var intervalView: GraphicView?
    @IBOutlet weak var intervalTextField: NSTextField?
}

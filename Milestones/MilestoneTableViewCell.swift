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

protocol MilestoneTableCellDataSourceProtocol {

    var dateString: String {get}
    var cwString: String {get}
    var nameString: String {get}
    var timeIntervallString: String {get}
    var needsExpandedCell: Bool {get}
    var iconType: IconType {get}
    var iconColor: NSColor {get}
}

class MilestoneTableCellView :NSTableCellView {

    @IBOutlet weak var iconView: GraphicView!
    @IBOutlet weak var calendarWeekTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var intervalView: GraphicView?
    @IBOutlet weak var intervalTextField: NSTextField?
    
    func configureUsing(dataSource :MilestoneTableCellDataSourceProtocol) {
        
        nameTextField?.stringValue = dataSource.nameString
        calendarWeekTextField?.stringValue = dataSource.cwString
        dateTextField?.stringValue = dataSource.dateString
        intervalTextField?.stringValue = dataSource.timeIntervallString
        
        let iconGraphic = IconGraphic(type: .Diamond)
        iconGraphic.bounds.size = CGSize(width: 30, height: 30)
        iconGraphic.isDrawingFill = true
        iconGraphic.fillColor = dataSource.iconColor
        
        iconView.graphics.removeAll()
        iconView.graphics.append(iconGraphic)
        iconView.setNeedsDisplay(iconGraphic.bounds)

        intervalView?.graphics.removeAll()
        if dataSource.needsExpandedCell {
            let lineGraphic =  LineGraphic.lineGraphicWith(startPoint: CGPoint(x:15,y:0), endPoint: CGPoint(x:15,y:60), thickness: 2)
            lineGraphic.fillColor = NSColor.red
            lineGraphic.strokeColor = NSColor.black
        
            intervalView?.graphics.append(lineGraphic)
            intervalView?.setNeedsDisplay(lineGraphic.bounds)
        }        
    }
}


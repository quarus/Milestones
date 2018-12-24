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
    @IBOutlet weak var lineView: GraphicView?

    @IBOutlet weak var calendarWeekTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var intervalTextField: NSTextField?
    
    func configureUsing(dataSource :MilestoneTableCellDataSourceProtocol) {
        
        nameTextField?.stringValue = dataSource.nameString
        calendarWeekTextField?.stringValue = dataSource.cwString
        dateTextField?.stringValue = dataSource.dateString
        intervalTextField?.stringValue = dataSource.timeIntervallString
        
        iconView.backgroundColor = NSColor.clear
        let iconGraphic = IconGraphic(type: .Diamond)
        iconGraphic.bounds.size = iconView.bounds.size
        iconGraphic.isDrawingFill = true
        iconGraphic.fillColor = dataSource.iconColor
        
        
        iconView.graphics.removeAll()
        iconView.graphics.append(iconGraphic)
        iconView.setNeedsDisplay(iconGraphic.bounds)

        lineView?.backgroundColor = NSColor.clear
        lineView?.graphics.removeAll()
        if dataSource.needsExpandedCell {
            let lineViewBounds = lineView?.bounds.size ?? CGSize(width: 0, height: 0)
            let startPoint = CGPoint(x: lineViewBounds.width/2.0, y: 0)
            let endPoint = CGPoint(x: lineViewBounds.width/2.0, y: lineViewBounds.height)
            
            let lineGraphic =  LineGraphic.lineGraphicWith(startPoint: startPoint,
                                                           endPoint: endPoint,
                                                           thickness: 0.5)
            lineGraphic.fillColor = NSColor.red
            lineGraphic.strokeColor = NSColor.black
        
            lineView?.graphics.append(lineGraphic)
            lineView?.setNeedsDisplay(lineGraphic.bounds)
        }        
    }
}


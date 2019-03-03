//
//  DateMarkerView.swift
//  Milestones
//
//  Created by Altay Cebe on 25.02.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class DateMarkerView: GraphicView {
    
    private var iconGraphic: IconGraphic = IconGraphic(type: .Diamond)
    private var lineGraphic: LineGraphic = LineGraphic()
    
    
    var iconYPosition: CGFloat? {
        didSet {
            iconGraphic.bounds.origin = CGPoint(x: iconGraphic.bounds.origin.x,
                                                y: iconYPosition!)
            self.setNeedsDisplay(bounds)
        }
    }
    
    private var width: CGFloat = 20
    private var height: CGFloat = 100
    
    var color: NSColor = .red{
        didSet {
            iconGraphic.fillColor = color
        }
    }

    init(withHeight height: CGFloat) {
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: height))
        self.height = height
        setup()

    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()

    }
        
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        iconGraphic = IconGraphic(type: .Diamond)
        iconGraphic.strokeColor = Config.sharedInstance.strokeColor
        iconGraphic.isDrawingStroke = true
        iconGraphic.isDrawingFill = true
        iconGraphic.fillColor = .white
        iconGraphic.bounds.size = CGSize(width: width, height: width)
        
        lineGraphic = LineGraphic()
        lineGraphic.strokeColor = Config.sharedInstance.strokeColor
        lineGraphic.bounds.size = CGSize(width: width, height: height)
        lineGraphic.beginPoint = CGPoint(x: width/2.0, y: 0)
        lineGraphic.endPoint = CGPoint(x: width/2.0, y: height)
        
        graphics.append(lineGraphic)
        graphics.append(iconGraphic)

        backgroundColor = .clear
    }
}



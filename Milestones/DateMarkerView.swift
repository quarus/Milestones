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
    
    var width: CGFloat = 20
    var length: CGFloat = 100
    
    var color: NSColor = .red{
        didSet {
            iconGraphic.fillColor = color
        }
    }

    init(withLength length: CGFloat) {
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: length))
        self.length = length
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
        iconGraphic.fillColor = color
        iconGraphic.isDrawingFill = true
        iconGraphic.bounds.size = CGSize(width: width, height: width)
        
        lineGraphic = LineGraphic()
        lineGraphic.fillColor = .gray
        lineGraphic.bounds.size = CGSize(width: width, height: length)
        lineGraphic.beginPoint = CGPoint(x: width/2.0, y: 0)
        lineGraphic.endPoint = CGPoint(x: width/2.0, y: length)
        
        graphics.append(lineGraphic)
        graphics.append(iconGraphic)

        backgroundColor = .clear
    }
}



//
//  TodayIndicatorView.swift
//  Milestones
//
//  Created by Altay Cebe on 03.03.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class TodayIndicatorView: GraphicView {

    private var width: CGFloat = 20
    private var height: CGFloat = 100
    
    init(withHeight height: CGFloat) {
        self.height = height
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: height))
        setup()
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
       
        let line = LineGraphic.lineGraphicWith(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: frame.size.height), thickness: 4.0)
        line.isDrawingLineDash = true
        /*A C-style array of floating point values that contains the lengths (measured in points) of the line segments and gaps in the pattern. The values in the array alternate, starting with the first line segment length, followed by the first gap length, followed by the second line segment length, and so on
         */
        line.lineDash = [2.0, 3.0]
        
        //The number of values in pattern.
        line.lineDashCount = 2
        line.lineDashPhase = 0
        line.strokeColor = NSColor.red
        backgroundColor = .clear

        graphics.append(line)
    }
}

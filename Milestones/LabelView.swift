//
//  LabelView.swift
//  Milestones
//
//  Created by Altay Cebe on 25.02.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class LabelView: GraphicView {
    
    private var labelGraphic: LabelGraphic = LabelGraphic()
    
    var text: String = "" {
        didSet {
            labelGraphic.text = text
            labelGraphic.sizeToFit()
            frame.size = labelGraphic.bounds.size
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        labelGraphic.bounds.size = frame.size
        labelGraphic.fillColor = NSColor.yellow
        labelGraphic.isDrawingFill = true
        labelGraphic.textAlignment = .left
        
        graphics.append(labelGraphic)
    }
}
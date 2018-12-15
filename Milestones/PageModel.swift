//
//  InfiniteScrollViewModel.swift
//  Milestones
//
//  Created by Altay Cebe on 09.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation

class PageModel {
    
    let startDate: Date
    let endDate: Date
    let length: CGFloat
    
    var absoluteStartPosition: CGFloat = 0.0
    
    var clipViewRelativeX: CGFloat = 0.0 {
        didSet {
            clipViewAbsoluteX = absoluteStartPosition + clipViewRelativeX
        }
    }
    
    var clipViewStartDate: Date {
        return horizontalCalculator.dateForXPosition(position: clipViewAbsoluteX).normalized()
    }
    
    var clipViewAbsoluteX: CGFloat = 0.0
    var clipViewLength: CGFloat = 0.0
    
    fileprivate let horizontalCalculator: HorizontalCalculator
    
    
    
    init(horizontalCalculator: HorizontalCalculator, startDate: Date, endDate: Date) {
        self.horizontalCalculator = horizontalCalculator
        self.startDate = startDate.normalized()
        self.endDate = endDate.normalized()
        
        absoluteStartPosition = horizontalCalculator.xPositionFor(date: startDate)
        let endPosition = horizontalCalculator.xPositionFor(date: endDate)
        length = endPosition - absoluteStartPosition
    }
    
    convenience init(horizontalCalculator: HorizontalCalculator, startDate: Date, length: CGFloat) {

        let endDate = horizontalCalculator.dateForXPosition(position:(horizontalCalculator.xPositionFor(date: startDate) + length))
        self.init(horizontalCalculator: horizontalCalculator, startDate: startDate, endDate: endDate)
    }
    
    func contains(date :Date) -> Bool{
        return ((date >= startDate) && (date <= endDate))
    }
    
    func recenterClipView() {
        
        let absoluteStartPosition = clipViewAbsoluteX - (length/2.0)
        let absoluteStartDate = horizontalCalculator.dateForXPosition(position: absoluteStartPosition)
        self.absoluteStartPosition = horizontalCalculator.xPositionFor(date: absoluteStartDate)
        let dayOffset = absoluteStartPosition - self.absoluteStartPosition

        self.clipViewRelativeX = (clipViewAbsoluteX - absoluteStartPosition) + dayOffset
    }
}

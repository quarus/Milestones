//
//  InfiniteScrollViewModel.swift
//  Milestones
//
//  Created by Altay Cebe on 09.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation

struct PageModel {
    
    let startDate: Date
    let endDate: Date
    let length: CGFloat
    
    fileprivate(set) var absoluteStartPosition: CGFloat = 0.0
    
    var clipViewRelativeX: CGFloat = 0.0 {
        didSet {
            clipViewAbsoluteX = absoluteStartPosition + clipViewRelativeX
        }
    }
    
    var clipViewStartDate: Date {
        return horizontalCalculator.dateForXPosition(position: clipViewAbsoluteX).normalized()
    }
    
    var clipViewCenterDate: Date {
        let clipViewCenterAbsolutePosition = absoluteStartPosition + clipViewRelativeX + (clipViewLength/2.0)
        return horizontalCalculator.dateForXPosition(position: clipViewCenterAbsolutePosition).normalized()
    }
    
    fileprivate(set) var clipViewAbsoluteX: CGFloat = 0.0
    fileprivate(set) var clipViewLength: CGFloat = 0.0
    
    fileprivate let horizontalCalculator: HorizontalCalculator
    
    init(horizontalCalculator: HorizontalCalculator,
        startDate: Date,
         endDate: Date,
         clipViewLength: CGFloat) {
        
        self.horizontalCalculator = horizontalCalculator
        self.startDate = startDate.normalized()
        self.endDate = endDate.normalized()
        
        absoluteStartPosition = horizontalCalculator.xPositionFor(date: startDate)
        let endPosition = horizontalCalculator.xPositionFor(date: endDate)
        length = endPosition - absoluteStartPosition
        self.clipViewLength = clipViewLength
    }
    
    init(horizontalCalculator: HorizontalCalculator,
         startDate: Date,
         length: CGFloat,
         clipViewLength: CGFloat) {

        let endDate = horizontalCalculator.dateForXPosition(position:(horizontalCalculator.xPositionFor(date: startDate) + length))
        self.init(horizontalCalculator: horizontalCalculator,
                  startDate: startDate,
                  endDate: endDate,
            clipViewLength: clipViewLength)

    }
    
    init(horizontalCalculator: HorizontalCalculator,
         centerDate: Date,
         length: CGFloat,
         clipViewLength: CGFloat) {
        
        let absoluteStartPosition = horizontalCalculator.xPositionFor(date: centerDate) - (length / 2.0)
        let startDate = horizontalCalculator.dateForXPosition(position: absoluteStartPosition)
        self.init(horizontalCalculator: horizontalCalculator,
                  startDate:startDate,
                  length: length,
                  clipViewLength: clipViewLength)
        
        clipViewRelativeX = (length / 2.0) - (clipViewLength / 2.0)
    }

    func contains(date :Date) -> Bool{
        return ((date >= startDate) && (date <= endDate))
    }
    
    mutating func makePageModelCenteredAroundClipView() -> PageModel {
        
        let absoluteStartPosition = clipViewAbsoluteX - (length/2.0)
        let startDate = horizontalCalculator.dateForXPosition(position: absoluteStartPosition)
        self.absoluteStartPosition = horizontalCalculator.xPositionFor(date: startDate)
        let dayOffset = absoluteStartPosition - self.absoluteStartPosition
        
        var newPageModel = PageModel(horizontalCalculator: horizontalCalculator,
                                     startDate: startDate,
                                     length: length,
                                     clipViewLength: clipViewLength)
        newPageModel.clipViewRelativeX = (clipViewAbsoluteX - absoluteStartPosition) + dayOffset
        return newPageModel
    }
    
}

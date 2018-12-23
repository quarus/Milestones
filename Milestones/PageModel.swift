//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// PageModel.swift
// Milestones
//
//  Created by Altay Cebe on 09.12.18.
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation

struct PageModel {
    
    let startDate: Date
    let endDate: Date
    fileprivate(set) var length: CGFloat
    
    fileprivate(set) var absoluteStartPosition: CGFloat = 0.0
    
    var clipViewRelativeX: CGFloat = 0.0 {
        didSet {
            clipViewAbsoluteX = absoluteStartPosition + clipViewRelativeX
        }
    }
    
    var clipViewStartDate: Date {
        return horizontalCalculator.dateForXPosition(position: clipViewAbsoluteX)
    }
    
    var clipViewCenterDate: Date {
        let clipViewCenterAbsolutePosition = absoluteStartPosition + clipViewRelativeX + (clipViewLength/2.0)
        return horizontalCalculator.dateForXPosition(position: clipViewCenterAbsolutePosition)
    }
    
    fileprivate(set) var clipViewAbsoluteX: CGFloat = 0.0
    var clipViewLength: CGFloat = 0.0
    
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

        self.horizontalCalculator = horizontalCalculator
        self.startDate = startDate.normalized()
        self.endDate = horizontalCalculator.dateForXPosition(position:(horizontalCalculator.xPositionFor(date: startDate) + length))
        self.length = length
        self.clipViewLength = clipViewLength

        absoluteStartPosition = horizontalCalculator.xPositionFor(date: startDate)
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
        
        let centerDateRelativeX = horizontalCalculator.xPositionFor(date:centerDate) - self.absoluteStartPosition
        self.clipViewRelativeX = centerDateRelativeX - (clipViewLength/2.0)
        clipViewAbsoluteX = absoluteStartPosition + clipViewRelativeX
    }

    func contains(date :Date) -> Bool {
        return ((date >= startDate) && (date <= endDate))
    }
    
    func clipViewContains(date: Date) -> Bool {        
        let datePosition = horizontalCalculator.xPositionFor(date: date)
        if (datePosition >= clipViewAbsoluteX) && (datePosition <= clipViewAbsoluteX + clipViewLength) {
            return true
        }
        return false
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
    
    
    func printDescription () {
        print("StartDate :\(startDate)")
        print("EndDate: \(endDate)")
        print("Length: \(length)")
        print("AbsoluteStartPosition: \(absoluteStartPosition)")
        print("ClipViewAbsolutePosition: \(clipViewAbsoluteX)")
        print("ClipViewRelativePosition: \(clipViewRelativeX)")
        print("ClipViewLength: \(clipViewLength)")
        print("\n")
    }
}

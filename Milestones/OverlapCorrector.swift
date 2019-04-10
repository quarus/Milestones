//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// OverlapCorrector.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation

protocol Overlappable: AnyObject {
    var  rect: NSRect {get set}
}

class OverlapCorrector {

    private var overlappables :[Overlappable] = [Overlappable]()
    private var indicesOfTranslatedOverlappables = [Int]()
    
    func horizontallyCorrectOverlapFor(_ overlappables: inout [Overlappable]) {
        
        var positions = [CGPoint]()
        
        for aOverlappable in overlappables {
            positions.append(aOverlappable.rect.center())
        }
        
        self.overlappables = overlappables
        let secondIndex = overlappables.count - 1
        let firstIndex = secondIndex - 1
        var indices :[Int] = [Int]()
        recursivelyCorrectForOverlap(indexOfFirstOverlappable: firstIndex,
                                     indexOfSecondOverlappable: secondIndex,
                                     touchedIndices: &indices)
        
        var overlappablesToTranslate = [Overlappable]()
        var accummulatedCenterX :CGFloat = 0
        for index in indices {
            overlappablesToTranslate.append(overlappables[index])
            accummulatedCenterX += positions[index].x
        }
        
        let averagedCenterXPosition = accummulatedCenterX / CGFloat (indices.count)
        let boundsOfOverlappableToTranslate = overlappablesToTranslate.reduce(NSZeroRect) {NSUnionRect($0,$1.rect)}
        let deltaXIconsAndLabels = averagedCenterXPosition - boundsOfOverlappableToTranslate.origin.x
        
        for idx in 0..<overlappablesToTranslate.count {
            let dX: CGFloat = deltaXIconsAndLabels - (boundsOfOverlappableToTranslate.size.width / 2)
            let dY: CGFloat = 0
            overlappablesToTranslate[idx].rect = NSOffsetRect(overlappablesToTranslate[idx].rect,dX, dY)
        }
    }

    // first index always smaller than second index
    private func recursivelyCorrectForOverlap(indexOfFirstOverlappable: Int,
                                              indexOfSecondOverlappable: Int,
                                              touchedIndices: inout[Int]){


        func correctionNeeded(_ firstBound :CGRect,_ secondBound :CGRect) -> Bool {

            let endPositionOfSecondBound = secondBound.origin.x + secondBound.size.width
            let startPositionOfFirstBound = firstBound.origin.x

            if (NSIntersectsRect(firstBound, secondBound)){
                return true
            }

            if (endPositionOfSecondBound < startPositionOfFirstBound){
                return true
            }

            return false
        }

        if (indexOfFirstOverlappable >= 0) {


            let firstOverlappable = overlappables[indexOfFirstOverlappable]
            let secondOverlappable = overlappables[indexOfSecondOverlappable]

            let boundsOfFirstOverlappable = firstOverlappable.rect
            let boundsOfSecondOverlappable = secondOverlappable.rect

            if (correctionNeeded(boundsOfFirstOverlappable, boundsOfSecondOverlappable)){

                let newRect = NSRect(x: secondOverlappable.rect.origin.x - firstOverlappable.rect.size.width,
                                     y: firstOverlappable.rect.origin.y,
                                     width: firstOverlappable.rect.size.width,
                                     height:firstOverlappable.rect.size.height)

                firstOverlappable.rect = newRect
                
                if (!indicesOfTranslatedOverlappables.contains(indexOfFirstOverlappable)) {
                    indicesOfTranslatedOverlappables.append(indexOfFirstOverlappable)
                }

                if (!indicesOfTranslatedOverlappables.contains(indexOfSecondOverlappable)) {
                    indicesOfTranslatedOverlappables.append(indexOfSecondOverlappable)
                }

                if (!touchedIndices.contains(indexOfSecondOverlappable)) {
                    touchedIndices.append(indexOfSecondOverlappable)
                }

                if (!touchedIndices.contains(indexOfFirstOverlappable)) {
                    touchedIndices.append(indexOfFirstOverlappable)
                }

                recursivelyCorrectForOverlap(indexOfFirstOverlappable: indexOfFirstOverlappable - 1,
                                             indexOfSecondOverlappable: indexOfFirstOverlappable,
                                             touchedIndices: &touchedIndices)
            }
        }
    }
/*
    private func lineForGraphics(atIndices indices :[Int]) -> [Graphic]{

        var graphics = [Graphic]()

        for index in indices {
            let labelGraphicBounds = Graphic.boundsOf(graphics: milestoneLabelGraphics[index])
            let iconGraphicBounds = Graphic.boundsOf(graphics: milestoneIconGraphics[index])

            let startPoint = iconGraphicBounds.center()
            let endPoint = CGPoint(x: labelGraphicBounds.center().x,y: labelGraphicBounds.origin.y)
            let lineGraphic = LineGraphic.lineGraphicWith(startPoint: startPoint, endPoint: endPoint, thickness: 1.0)

            graphics.append(lineGraphic)
        }
        return graphics
    }
 */

}

extension OverlapCorrector {
    
    func correctOverlapFor(_ overlappables: inout [Overlappable]) {
        horizontallyCorrectOverlapFor(&overlappables)
    }
}


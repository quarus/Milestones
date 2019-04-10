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

    var milestoneLabelGraphics :[Overlappable] = [Overlappable]()
    var milestoneIconGraphics :[Overlappable] = [Overlappable]()
    var lineGraphics :[Graphic] = [Graphic]()
    private var indicesOfTranslatedGraphics = [Int]()
    

    func horizontallyCorrectOverlapFor(_ overlappables: inout [Overlappable]) {
        
        var positions = [CGPoint]()
        
        for aOverlappable in overlappables {
            positions.append(aOverlappable.rect.center())
        }
        
        self.milestoneLabelGraphics = overlappables
        let secondIndex = milestoneLabelGraphics.count - 1
        let firstIndex = secondIndex - 1
        var indices :[Int] = [Int]()
        recursivelyCorrectForOverlap(indexOfFirstGraphics: firstIndex,
                                     indexOfSecondGraphics: secondIndex,
                                     touchedIndices: &indices)
        
        var milestoneLabelGraphicsToTranslate = [Overlappable]()
        var accummulatedCenterX :CGFloat = 0
        for index in indices {
            milestoneLabelGraphicsToTranslate.append(milestoneLabelGraphics[index])
            accummulatedCenterX += positions[index].x
        }
        
        let averagedCenterXPosition = accummulatedCenterX / CGFloat (indices.count)
        let boundsOfMilestoneLabelGraphicsToTranslate = milestoneLabelGraphicsToTranslate.reduce(NSZeroRect) {NSUnionRect($0,$1.rect)}
        let deltaXIconsAndLabels = averagedCenterXPosition - boundsOfMilestoneLabelGraphicsToTranslate.origin.x
        
        for idx in 0..<milestoneLabelGraphicsToTranslate.count {
            let dX: CGFloat = deltaXIconsAndLabels - (boundsOfMilestoneLabelGraphicsToTranslate.size.width / 2)
            let dY: CGFloat = 0
            milestoneLabelGraphicsToTranslate[idx].rect = NSOffsetRect(milestoneLabelGraphicsToTranslate[idx].rect,dX, dY)
        }
    }
    /*
    func correctForOverlap(milestoneLabelGraphics: inout [Overlappable], milestoneIconGraphics: inout [Overlappable]) {
        self.milestoneLabelGraphics = milestoneLabelGraphics
        self.milestoneIconGraphics = milestoneIconGraphics

        let secondIndex = milestoneLabelGraphics.count - 1
        let firstIndex = secondIndex - 1
        var indices :[Int] = [Int]()
        recursivelyCorrectForOverlap(indexOfFirstGraphics: firstIndex, indexOfSecondGraphics: secondIndex, touchedIndices: &indices)

//        Swift.print("Indices \(indices)")

        var milestoneLabelGraphicsToTranslate = [Overlappable]()
        var averagedCenterOfMilestones :CGFloat = 0
        for index in indices {
            milestoneLabelGraphicsToTranslate.append(milestoneLabelGraphics[index])
            averagedCenterOfMilestones += milestoneIconGraphics[index].rect.center().x
        }
        averagedCenterOfMilestones = averagedCenterOfMilestones / CGFloat(indices.count)
        let boundsOfMilestoneLabelGraphicsToTranslate = milestoneLabelGraphics.reduce(NSZeroRect) {NSUnionRect($0,$1.rect)}
        
//        let boundsOfMilestoneLabelGraphicsToTranslate = NSRect.boundsOf(milestoneLabelGraphicsToTranslate)

        let deltaXIconsAndLabels = averagedCenterOfMilestones - boundsOfMilestoneLabelGraphicsToTranslate.origin.x

        for idx in 0..<milestoneLabelGraphicsToTranslate.count {
            let dX: CGFloat = deltaXIconsAndLabels - (boundsOfMilestoneLabelGraphicsToTranslate.size.width / 2)
            let dY: CGFloat = 0
            milestoneLabelGraphicsToTranslate[idx].rect = NSOffsetRect(milestoneLabelGraphicsToTranslate[idx].rect,dX, dY)
        }
            
        
        
/*        for anOverlappable in milestoneLabelGraphicsToTranslate {
            let dX: CGFloat = deltaXIconsAndLabels - (boundsOfMilestoneLabelGraphicsToTranslate.size.width / 2)
            let dY: CGFloat = 0
            anOverlappable.rect = NSOffsetRect(anOverlappable.rect,dX, dY)
        }
  */
        /*Graphic.translate(graphics: milestoneLabelGraphicsToTranslate,
                          byX: deltaXIconsAndLabels - (boundsOfMilestoneLabelGraphicsToTranslate.size.width / 2),
                          byY: 0)*/



/*        lineGraphics.removeAll()
        lineGraphics.append(contentsOf: lineForGraphics(atIndices: indicesOfTranslatedGraphics))
*/
    }
 */

    // first index always smaller than second index
    private func recursivelyCorrectForOverlap(indexOfFirstGraphics :Int, indexOfSecondGraphics :Int, touchedIndices :inout[Int]){


        func correctionNeeded(_ firstBound :CGRect,_ secondBound :CGRect) -> Bool {

            let endPositionOfSecondBound = secondBound.origin.x + secondBound.size.width
            let startPositionOfFirstBound = firstBound.origin.x

            if (NSIntersectsRect(firstBound, secondBound)) {

                return true
            }

            if (endPositionOfSecondBound < startPositionOfFirstBound){
                return true
            }

            return false
        }

        if (indexOfFirstGraphics >= 0) {


            var firstGraphics = milestoneLabelGraphics[indexOfFirstGraphics]
            var secondGraphics = milestoneLabelGraphics[indexOfSecondGraphics]

            let boundsOfFirstGraphics = firstGraphics.rect
            let boundsOfSecondGraphics = secondGraphics.rect



            if (correctionNeeded(boundsOfFirstGraphics, boundsOfSecondGraphics)) {
                var correctionTranslate :CGFloat = 0.0
            /*    if ( boundsOfFirstGraphics.origin.x > boundsOfSecondGraphics.origin.x ) {
                    let xDelta = boundsOfFirstGraphics.origin.x - boundsOfSecondGraphics.origin.x
                    correctionTranslate = (xDelta + boundsOfFirstGraphics.size.width)

                } else {
                    correctionTranslate = NSIntersectionRect(boundsOfFirstGraphics, boundsOfSecondGraphics).size.width
                }
                
                print("\(firstGraphics.rect)")
                print ("\(correctionTranslate)")
                let offsetedRect = NSOffsetRect(firstGraphics.rect, -1 * correctionTranslate, 0)
                print("\(offsetedRect)")
                firstGraphics.rect = offsetedRect
//                Graphic.translate(graphics: firstGraphics, byX: -correctionTranslate, byY: 0)
                print("\(firstGraphics.rect)")
                print("\n")
*/
                let newRect = NSRect(x: secondGraphics.rect.origin.x - firstGraphics.rect.size.width,
                                     y: firstGraphics.rect.origin.y,
                                     width: firstGraphics.rect.size.width,
                                     height:firstGraphics.rect.size.height)

                firstGraphics.rect = newRect
                
                if (!indicesOfTranslatedGraphics.contains(indexOfFirstGraphics)) {
                    indicesOfTranslatedGraphics.append(indexOfFirstGraphics)
                }

                if (!indicesOfTranslatedGraphics.contains(indexOfSecondGraphics)) {
                    indicesOfTranslatedGraphics.append(indexOfSecondGraphics)
                }

                if (!touchedIndices.contains(indexOfSecondGraphics)) {
                    touchedIndices.append(indexOfSecondGraphics)
                }

                if (!touchedIndices.contains(indexOfFirstGraphics)) {
                    touchedIndices.append(indexOfFirstGraphics)
                }


                recursivelyCorrectForOverlap(indexOfFirstGraphics: indexOfFirstGraphics - 1, indexOfSecondGraphics: indexOfFirstGraphics, touchedIndices: &touchedIndices)
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
    
    func correctForOverlapFor(milestoneGraphicControllers: [MilestoneGraphicController]) {
        
        var labelGraphics = [Overlappable]()
        var iconGraphics = [Overlappable]()
        
        for aController in milestoneGraphicControllers {
            labelGraphics.append(aController.nameLabel)
            iconGraphics.append(aController.iconGraphic)
        }
        
//        correctForOverlap(milestoneLabelGraphics: &labelGraphics, milestoneIconGraphics: &iconGraphics)
        horizontallyCorrectOverlapFor(&labelGraphics)
    }

    func correctOverlapFor(_ overlappables: inout [Overlappable]) {        
        horizontallyCorrectOverlapFor(&overlappables)
    }
}


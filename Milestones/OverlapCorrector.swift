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

class OverlapCorrector {

    var milestoneLabelGraphics :[[Graphic]] = [[Graphic]]()
    var milestoneIconGraphics :[[Graphic]] = [[Graphic]]()
    var lineGraphics :[Graphic] = [Graphic]()
    var indicesOfTranslatedGraphics = [Int]()

    func correctForOverlap(milestoneLabelGraphics :[[Graphic]], milestoneIconGraphics :[[Graphic]]) {
        self.milestoneLabelGraphics = milestoneLabelGraphics
        self.milestoneIconGraphics = milestoneIconGraphics

        let secondIndex = milestoneLabelGraphics.count - 1
        let firstIndex = secondIndex - 1
        var indices :[Int] = [Int]()
        recursivelyCorrectForOverlap(indexOfFirstGraphics: firstIndex, indexOfSecondGraphics: secondIndex, touchedIndices: &indices)

//        Swift.print("Indices \(indices)")

        var milestoneLabelGraphicsToTranslate = [Graphic]()
        var averagedCenterOfMilestones :CGFloat = 0
        for index in indices {
            milestoneLabelGraphicsToTranslate.append(contentsOf: milestoneLabelGraphics[index])
            averagedCenterOfMilestones += Graphic.boundsOf(graphics: milestoneIconGraphics[index]).center().x
        }
        averagedCenterOfMilestones = averagedCenterOfMilestones / CGFloat(indices.count)
        let boundsOfMilestoneLabelGraphicsToTranslate = Graphic.boundsOf(graphics: milestoneLabelGraphicsToTranslate)

        let deltaXIconsAndLabels = averagedCenterOfMilestones - boundsOfMilestoneLabelGraphicsToTranslate.origin.x


        Graphic.translate(graphics: milestoneLabelGraphicsToTranslate,
                          byX: deltaXIconsAndLabels - (boundsOfMilestoneLabelGraphicsToTranslate.size.width / 2),
                          byY: 0)



        lineGraphics.removeAll()
        lineGraphics.append(contentsOf: lineForGraphics(atIndices: indicesOfTranslatedGraphics))

    }

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


            let firstGraphics = milestoneLabelGraphics[indexOfFirstGraphics]
            let secondGraphics = milestoneLabelGraphics[indexOfSecondGraphics]

            let boundsOfFirstGraphics = Graphic.boundsOf(graphics: firstGraphics)
            let boundsOfSecondGraphics = Graphic.boundsOf(graphics: secondGraphics)



            if (correctionNeeded(boundsOfFirstGraphics, boundsOfSecondGraphics)) {
                var correctionTranslate :CGFloat = 0.0
                if ( boundsOfFirstGraphics.origin.x > boundsOfSecondGraphics.origin.x ) {
                    let xDelta = boundsOfFirstGraphics.origin.x - boundsOfSecondGraphics.origin.x
                    correctionTranslate = (xDelta + boundsOfFirstGraphics.size.width)

                } else {
                    correctionTranslate = NSIntersectionRect(boundsOfFirstGraphics, boundsOfSecondGraphics).size.width
                }

                Graphic.translate(graphics: firstGraphics, byX: -correctionTranslate, byY: 0)

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

}

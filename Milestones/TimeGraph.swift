//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  TimelinesAndCalendarweeksView.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

protocol TimeGraphDelegate {
    func timeGraphNumberOfTimelines(graph :TimeGraph) -> Int
    func timeGraph(graph: TimeGraph, numberOfMilestonesForTimelineAt index: Int) -> Int
    func timeGraphStartDate(graph: TimeGraph) -> Date
    func timeGraph(graph: TimeGraph, didSelectMilestoneAt indexPath: IndexPath)
    func timeGraph(graph: TimeGraph, didSelectDate date: Date, inTimelineAtIndex index: Int)
}

protocol TimeGraphDataSource {
    func timeGraph(graph: TimeGraph, milstoneAt indexPath: IndexPath) ->MilestoneProtocol
    func timeGraph(graph: TimeGraph, adjustmentsForMilestoneAt indexPath: IndexPath) -> [AdjustmentProtocol]
}

protocol TimeGraphGraphicsSource {
   
    func timeGraph(graph: TimeGraph,
                   backgroundGraphicsStartingAt date: Date,
                   forSize: CGSize,
                   numberOfTimeline timelinesCount: Int,
                   usingHorizontalCalculator horizCalculator: HorizontalCalculator,
                   verticalCalculator verCalculator: VerticalCalculator) -> [Graphic]
    
    func timeGraph(graph: TimeGraph,
                   adjustmentGraphicsFor milestone: MilestoneProtocol,
                   adjustments: [AdjustmentProtocol],
                   startDate date: Date,
                   usingCalculator timelineCalculator: HorizontalCalculator) -> [Graphic]
    
}

class TimeGraph: GraphicView {
    
    var yOffset :CGFloat = 200;
    
    var timelineHorizontalCalculator: HorizontalCalculator?
    var timelineVerticalCalculator: VerticalCalculator?

    private var currentTrackingArea: NSTrackingArea?
    
    private var msgcDict: [MilestoneGraphicController:IndexPath] = [MilestoneGraphicController:IndexPath]()
    private var msgcArray: [[MilestoneGraphicController]] = [[MilestoneGraphicController]]()
    
    private(set) var absoluteX: CGFloat = 0.0
    private(set) var startDate: Date = Date() {
        didSet {
            absoluteX = timelineHorizontalCalculator?.xPositionFor(date: startDate) ?? 0.0
        }
    }
    
    var markedDate: Date?
    var indexOfMarkedTimeline: Int?
    
    var markedMilestoneGC: MilestoneGraphicController?
    
    var delegate: TimeGraphDelegate?
    var dataSource: TimeGraphDataSource?
    var graphicsSource: TimeGraphGraphicsSource?
    
    private var lastMouseLocation :NSPoint = NSZeroPoint

    var labelView: LabelView?
    var todayIndicatorView: TodayIndicatorView?
    var dateMarker: DateMarkerView?
    var staticDateMarker: DateMarkerView?
    
    //MARK: Life cycle
    init(withLength length: CGFloat,
         horizontalCalculator :HorizontalCalculator,
         verticalCalculator :VerticalCalculator){
        self.timelineVerticalCalculator = verticalCalculator
        self.timelineHorizontalCalculator = horizontalCalculator
        
        dateMarker = DateMarkerView(withHeight: 800)
        staticDateMarker = DateMarkerView(withHeight: 800)
        todayIndicatorView = TodayIndicatorView(withHeight: 800)
        labelView = LabelView(frame: NSMakeRect(0, 0, 200, 200))
        
        super.init(frame: NSRect(x: 0, y: 0, width: length, height: 800))
        
        addSubview(dateMarker!)
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
    }
    
    //MARK: Mouse Handling
    override func mouseDown(with event: NSEvent) {
        
        let mouselocation = self.convert(event.locationInWindow, from: nil)
        if let graphicUnderPointer = self.graphicUnderPoint(mouselocation) {
            
            guard let milestoneGraphicController = graphicUnderPointer.userInfo as? MilestoneGraphicController else {return}
            guard let indexPath = msgcDict[milestoneGraphicController] else {return}
            delegate?.timeGraph(graph: self, didSelectMilestoneAt: indexPath)
            
            
        } else {
            guard let xCalculator = timelineHorizontalCalculator else {return}
            let indexOfTimeline = timelineVerticalCalculator?.timelineIndexForYPosition(yPosition: mouselocation.y) ?? 0
            let date = xCalculator.dateForXPosition(position: mouselocation.x + absoluteX)
            delegate?.timeGraph(graph:self,
                                didSelectDate: date,
                                inTimelineAtIndex: indexOfTimeline)
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        let mouselocation = self.convert(event.locationInWindow, from: nil)

        func updateMilestoneLabel() {
            
            if let graphicUnderPointer = self.graphicUnderPoint(mouselocation) {
                if let milestoneGC = graphicUnderPointer.userInfo as? MilestoneGraphicController {
                    if let milestone = dataSource?.timeGraph(graph: self,
                                                                 milstoneAt: msgcDict[milestoneGC]!) {
                        if milestone.info.count > 0 {
                            if let label = labelView {
                                label.text = milestone.info
                                if label.superview == nil {
                                    addSubview(label)
                                }
                            }
                        }
                    }
                } else {
                }
            } else {
                labelView?.removeFromSuperview()
            }
            
            labelView?.frame.origin = mouselocation
        }
        
        updateDateMarkerFor(mouseLocation: lastMouseLocation)
        updateMilestoneLabel()
        lastMouseLocation = mouselocation
    }
 
    func setMarkedDate(date: Date, andTimelineAtIndex idx: Int) {
        markedDate = date
        indexOfMarkedTimeline = idx
        checkAndPlaceStaticDateMarker()
        
    }

    func selectMilestoneAt(indexPath: IndexPath? ) {
        
        func deselectCurrentMilestone() {
            if markedMilestoneGC != nil {
                markedMilestoneGC?.isSelected = false
                setNeedsDisplay(markedMilestoneGC!.bounds)
            }
        }
        
        guard let path = indexPath else {
            deselectCurrentMilestone()
            return
        }
        
        if path.count == 2 {
            deselectCurrentMilestone()
            markedMilestoneGC = msgcArray[path[0]][path[1]]
            markedMilestoneGC!.isSelected = true
            setNeedsDisplay(markedMilestoneGC!.bounds)
        }
    }
    
    private func updateFrameFor(numberOfTimelines :Int) {

        //Update this views frame
        let height = timelineVerticalCalculator?.yPositionForTimelineAt(index: numberOfTimelines) ?? 100
        self.frame = NSMakeRect(frame.origin.x,
                                frame.origin.y,
                                frame.size.width,
                                height)
        
        //Update the tracking area
        if (currentTrackingArea != nil) {
            self.removeTrackingArea(currentTrackingArea!)
        }
        
        let trackingOptions :NSTrackingArea.Options = [NSTrackingArea.Options.mouseMoved,NSTrackingArea.Options.activeAlways]
        currentTrackingArea = NSTrackingArea(rect: self.bounds, options: trackingOptions, owner: self, userInfo: nil)
        self.addTrackingArea(currentTrackingArea!)

    }

    func reloadData() {
        guard let xPositionCalculator = timelineHorizontalCalculator else {return}
        guard let yPositionCalculator = timelineVerticalCalculator else {return}
        
        startDate = delegate?.timeGraphStartDate(graph: self) ?? Date()

        let numberOfTimelines = delegate?.timeGraphNumberOfTimelines(graph: self) ?? 0
        updateFrameFor(numberOfTimelines: numberOfTimelines)
        
        graphics.removeAll()
        let bgGraphics = graphicsSource?.timeGraph(graph: self,
                                  backgroundGraphicsStartingAt: startDate,
                                  forSize: frame.size,
                                  numberOfTimeline: numberOfTimelines,
                                  usingHorizontalCalculator: xPositionCalculator,
                                  verticalCalculator: yPositionCalculator)
        if bgGraphics != nil {
            graphics.append(contentsOf: bgGraphics!)
        }

        msgcDict = [MilestoneGraphicController:IndexPath]()
        msgcArray = [[MilestoneGraphicController]]()

        for timelineIdx in 0..<numberOfTimelines {
            let numberOfMilestones = delegate?.timeGraph(graph: self,
                                                         numberOfMilestonesForTimelineAt: timelineIdx) ?? 0
            var msgArray = [MilestoneGraphicController]()
            for milestoneIdx in 0..<numberOfMilestones {
                if let info = dataSource?.timeGraph(graph: self, milstoneAt: IndexPath(indexes:[timelineIdx, milestoneIdx])) {
                   
                    let currentIndexPath = IndexPath(indexes: [timelineIdx, milestoneIdx])
                    //initiate a MilestoneGraphic and append it to all graphics
                    let milestoneGraphicController = MilestoneGraphicController(info)
                    let relativeX =  relativePositionForAbsolute(xPosition: xPositionCalculator.centerXPositionFor(date: info.date))
                    milestoneGraphicController.position.x = relativeX
                    milestoneGraphicController.position.y = yPositionCalculator.yPositionForTimelineAt(index: timelineIdx)
                    graphics.append(contentsOf: milestoneGraphicController.graphics)
                    
                    msgcDict[milestoneGraphicController] = currentIndexPath
                    msgArray.append(milestoneGraphicController)
                    
                    //get all adjustment graphic
                    if let adjustments = dataSource?.timeGraph(graph: self,
                                                               adjustmentsForMilestoneAt: currentIndexPath) {
                       
                        let adjustmentGraphics = graphicsSource?.timeGraph(graph: self,
                                                                           adjustmentGraphicsFor: info, adjustments: adjustments,
                                                                           startDate: startDate,
                                                                           usingCalculator: xPositionCalculator)
                        if adjustmentGraphics != nil {
                            graphics.append(contentsOf: adjustmentGraphics!)
                        }
                    }
                }
                let overlapCorrector = OverlapCorrector()
                overlapCorrector.correctForOverlapFor(milestoneGraphicControllers: msgArray)
                graphics.insert(contentsOf: overlapCorrector.lineGraphics, at: 0)
            }
            msgcArray.append(msgArray)
        }
        
        setNeedsDisplay(bounds)
        
        checkAndPlaceStaticDateMarker()
        checkAndPlaceTodayIndicator()
    }

    private func updateDateMarkerFor(mouseLocation: CGPoint) {
        guard let xPositionCalculator = timelineHorizontalCalculator else {return}
        guard let yPositionCalculator = timelineVerticalCalculator else {return}

        let y = yPositionCalculator.timelineIndexForYPosition(yPosition: lastMouseLocation.y)
        let x = lastMouseLocation.x
        
        let numberOfDays = Int(x/xPositionCalculator.lengthOfDay)
        let dayX = CGFloat(numberOfDays) * xPositionCalculator.lengthOfDay
        
        dateMarker?.iconYPosition = CGFloat(y) * (timelineVerticalCalculator?.heightOfTimeline ?? 0.0)
        dateMarker?.frame.origin = CGPoint(x: dayX, y: 0)
    }
    
    private func checkAndPlaceStaticDateMarker() {
        guard let xPositionCalculator = timelineHorizontalCalculator else {return}
        guard let yPositionCalculator = timelineVerticalCalculator else {return}
        guard let markerView = staticDateMarker else {return}
        guard let md = markedDate else {return}
        guard let mTimeline = indexOfMarkedTimeline else {return}
        
        
        if (isDateVisible(date: md)) {
            if markerView.superview == nil {
                addSubview(markerView)
            }
            let xPos = xPositionCalculator.xPositionFor(date: md)
            let yPos = yPositionCalculator.yPositionForTimelineAt(index: mTimeline)
            let relativeXPos = relativePositionForAbsolute(xPosition: xPos)
            markerView.frame.origin = CGPoint(x: relativeXPos, y: 0)
            markerView.iconYPosition = yPos
        } else {
            if markerView.superview != nil {
                markerView.removeFromSuperview()
            }
        }
    }
    
    private func checkAndPlaceTodayIndicator() {
        guard let xPositionCalculator = timelineHorizontalCalculator else {return}
        guard let todayIndicator = todayIndicatorView else {return}
        
        
        if (isDateVisible(date: Date())) {
            if todayIndicator.superview == nil {
                addSubview(todayIndicator)
            }
            let xPos = xPositionCalculator.xPositionFor(date: Date())
            let relativeXPos = relativePositionForAbsolute(xPosition: xPos)
            todayIndicatorView?.frame.origin = CGPoint(x: relativeXPos, y: 0)
        } else {
            if todayIndicator.superview != nil {
                todayIndicator.removeFromSuperview()
            }
        }
    }
    
    //MARK: Helper
    private func relativePositionForAbsolute(xPosition :CGFloat) -> CGFloat{
        guard let xPositionCalculator = timelineHorizontalCalculator else {return 0.0}
        
        let absoluteStartX = xPositionCalculator.xPositionFor(date: startDate)
        return xPosition - absoluteStartX
    }
    
    private func isDateVisible(date: Date) -> Bool {
        guard let xPositionCalculator = timelineHorizontalCalculator else {return false}
        let xPos = xPositionCalculator.xPositionFor(date: date)
        
        if (xPos > absoluteX) && (xPos < absoluteX + bounds.width) {
            return true
        } else {
            return false
        }
    }
}




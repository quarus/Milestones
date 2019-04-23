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
    
    
    private(set) var absoluteX: CGFloat = 0.0
    private(set) var startDate: Date = Date() {
        didSet {
            absoluteX = timelineHorizontalCalculator?.xPositionFor(date: startDate) ?? 0.0
        }
    }
    
    var markedDate: Date?
    var indexOfMarkedTimeline: Int?
    
    var delegate: TimeGraphDelegate?
    var dataSource: TimeGraphDataSource?
    var graphicsSource: TimeGraphGraphicsSource?
    
    private var lastMouseLocation :NSPoint = NSZeroPoint

    var labelView: LabelView?
    var todayIndicatorView: TodayIndicatorView?
    var dateMarker: DateMarkerView?
    var staticDateMarker: DateMarkerView?
    
    var markedMilestoneView: MilestoneView?
    var milestoneViews: [MilestoneView] = [MilestoneView]()
    var milestoneLabelViews: [LabelView] = [LabelView]()
    private var viewDict: [IndexPath:GraphicView] = [IndexPath:GraphicView]()

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

        if let view = graphicViewForPoint(mouselocation) {
            if let indexPath = view.context as? IndexPath {
                delegate?.timeGraph(graph: self, didSelectMilestoneAt: indexPath)
            }
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
            if let view = graphicViewForPoint(mouselocation) {
                if let indexPath = view.context as? IndexPath {
                    if let milestone = dataSource?.timeGraph(graph: self,
                                                             milstoneAt: indexPath) {
                        if milestone.info.count > 0 {
                            if let label = labelView {
                                label.text = milestone.info
                                if label.superview == nil {
                                    addSubview(label)
                                }
                            }
                        }
                    }
                }
            } else {
                if labelView?.superview != nil {
                    labelView?.removeFromSuperview()
                }
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
            markedMilestoneView?.isSelected = false
        }
        
        guard let path = indexPath else {
            deselectCurrentMilestone()
            return
        }
        
        if path.count == 2 {
            if let milestoneView = viewDict[indexPath!] as? MilestoneView{
                deselectCurrentMilestone()
                milestoneView.isSelected = true
                markedMilestoneView = milestoneView
            }
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
        
        labelView?.removeFromSuperview()
        graphics.removeAll()
        
        for aView in milestoneViews {
            aView.removeFromSuperview()
        }
        milestoneViews.removeAll()
        
        for aView in milestoneLabelViews {
            aView.removeFromSuperview()
        }
        milestoneLabelViews.removeAll()
        
        viewDict.removeAll()
        
        let bgGraphics = graphicsSource?.timeGraph(graph: self,
                                  backgroundGraphicsStartingAt: startDate,
                                  forSize: frame.size,
                                  numberOfTimeline: numberOfTimelines,
                                  usingHorizontalCalculator: xPositionCalculator,
                                  verticalCalculator: yPositionCalculator)
        if bgGraphics != nil {
            graphics.append(contentsOf: bgGraphics!)
        }
        
        markedMilestoneView = nil
        
        for timelineIdx in 0..<numberOfTimelines {
            var labelViews: [Overlappable] = [Overlappable]()
            let numberOfMilestones = delegate?.timeGraph(graph: self,
                                                         numberOfMilestonesForTimelineAt: timelineIdx) ?? 0
            for milestoneIdx in 0..<numberOfMilestones {
                if let info = dataSource?.timeGraph(graph: self, milstoneAt: IndexPath(indexes:[timelineIdx, milestoneIdx])) {
                   
                    let currentIndexPath = IndexPath(indexes: [timelineIdx, milestoneIdx])
                    //initiate a MilestoneGraphic and append it to all graphics
                    let relativeX =  relativePositionForAbsolute(xPosition: xPositionCalculator.centerXPositionFor(date: info.date))
                    let relativeY = yPositionCalculator.yPositionForTimelineAt(index: timelineIdx)
                    let position = CGPoint(x: relativeX, y: relativeY)
                    
                    let milestoneView = MilestoneView(milestone: info)
                    milestoneView.frame.origin = position
                    milestoneView.centerHorizontally()
                    milestoneViews.append(milestoneView)
                    viewDict[currentIndexPath] = milestoneView

                    let milestoneLabelView = LabelView(frame: NSMakeRect(0, 0, 100, 0))
                    milestoneLabelView.text = info.name
                    milestoneLabelView.textAlignment = .center
                    milestoneLabelView.frame.origin = CGPoint(x: position.x,
                                                              y: position.y + milestoneView.frame.size.height)
                    milestoneLabelView.centerHorizontally()
                    labelViews.append(milestoneLabelView)
                    milestoneLabelViews.append(milestoneLabelView)
//                    viewDict[currentIndexPath] = milestoneLabelView

                    addSubview(milestoneView)
                    addSubview(milestoneLabelView)

                    milestoneLabelView.context = currentIndexPath
                    milestoneView.context = currentIndexPath
                    
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
                } //milestones
                let overlapCorrector = OverlapCorrector()
                overlapCorrector.horizontallyCorrectOverlapFor(&labelViews)
                
                
                
            } // timelines
        }
        
        let lineGenerator = LineGenerator()
        if let lineGraphics = lineGenerator.graphicsForStartPoints(milestoneLabelViews,
                                                                   endPoints: milestoneViews) {
            graphics.append(contentsOf: lineGraphics)
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
    
    private func graphicViewForPoint(_ point: CGPoint) -> GraphicView? {
        
        // there are problems with NView.hitTest. Therefore this helper method
        
        var foundView: GraphicView?
        var combinedViews = [GraphicView]()
        combinedViews.append(contentsOf: milestoneLabelViews)
        combinedViews.append(contentsOf: milestoneViews)
        
        for aView in combinedViews {
            if NSPointInRect(point, aView.frame) {
                foundView = aView
            }
        }
        return foundView
    }
}




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
}

protocol TimeGraphDataSource {
    func timeGraph(graph: TimeGraph, milestoneAtIndex index: Int, inTimelineAtIndex msIndex: Int) -> MilestoneProtocol
}

class TimeGraph: GraphicView {
    
    var dateMarkedHandler: ((_ markedDate: Date, _ markedTimeline: Timeline) -> ())?
    
    var yOffset :CGFloat = 200;
    
    var timelineHorizontalCalculator: HorizontalCalculator?
    var timelineVerticalCalculator: VerticalCalculator?

    private var currentTrackingArea: NSTrackingArea?
    private weak var currentlySelectedMilestone: Milestone?
    private var currentlyDisplayedInfoLabel: LabelGraphic?
    private var dateIndictorLineGraphic: LineGraphic?
    private var markedDateGraphicController: DateIndicatorController?
    private var showInfoLabel :Bool = false
    
    private var milestoneGraphicControllers: [MilestoneGraphicController] = [MilestoneGraphicController]()
    
    private var msDict: [MilestoneGraphicController:IndexPath] = [MilestoneGraphicController:IndexPath]()
    private var msArray: [[MilestoneGraphicController]] = [[MilestoneGraphicController]]()
    
    var absoluteX: CGFloat = 0.0
    var timelines: [Timeline] = [Timeline]()
    var startDate: Date = Date()
    var markedDate: Date?
    var indexOfMarkedTimeline: Int?
    
    var delegate: TimeGraphDelegate?
    var dataSource: TimeGraphDataSource?
    
    private var lastMouseLocation :NSPoint = NSZeroPoint

    //MARK: Life dycle
    init(withLength length: CGFloat,
         horizontalCalculator :HorizontalCalculator,
         verticalCalculator :VerticalCalculator){
        self.timelineVerticalCalculator = verticalCalculator
        self.timelineHorizontalCalculator = horizontalCalculator
        super.init(frame: NSRect(x: 0, y: 0, width: length, height: 800))
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        if (currentlyDisplayedInfoLabel != nil) {
            stopObservingKVOForGraphic(currentlyDisplayedInfoLabel!)
        }
        
        if (dateIndictorLineGraphic != nil){
            stopObservingKVOForGraphic(dateIndictorLineGraphic!)
        }
    }
    
    func milestoneGraphicControllerForMilestone(_ milestone: Milestone) -> MilestoneGraphicController? {
       
  /*      let filteredArray = milestoneGraphicControllers.filter({
            if ($0.milestone == milestone) {
                return true
            } else {
                return false
            }
        })
        
        if (filteredArray.count > 0) {
            return filteredArray[0]
        }
        */
        return nil
    }
    
    
    
    //MARK: KVO
    func startObservingGraphic(_ aGraphic :Graphic) {
        let KVOOptions = NSKeyValueObservingOptions([.new, .old])
        aGraphic.addObserver(self, forKeyPath: "drawingBounds", options: KVOOptions, context: nil)
    }
    
    func stopObservingKVOForGraphic(_ aGraphic :Graphic){
        aGraphic.removeObserver(self, forKeyPath: "drawingBounds")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object is Graphic {
            if keyPath == "drawingBounds"{
                // Redraw the part of the view that the graphic used to occupy, and the part that it now occupies.
                if let theChange = change as? [NSKeyValueChangeKey: NSValue] {
                    
                    let oldValue = theChange[NSKeyValueChangeKey.oldKey]?.rectValue
                    let newValue = theChange[NSKeyValueChangeKey.newKey]?.rectValue
                    
                    guard ((oldValue != nil) && (newValue != nil)) else {return}
                    
                    self.setNeedsDisplay(oldValue!)
                    self.setNeedsDisplay(newValue!)
                }
            }
        }
    }
    
    //MARK: Mouse Handling
    func graphicUnderPoint(_ aPoint :NSPoint) -> Graphic? {
        
        for aGraphic in graphics{
            if (aGraphic.isContentUnderPoint(aPoint)){
                return aGraphic
            }
        }
        return nil
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let mouselocation = self.convert(event.locationInWindow, from: nil)
        if let graphicUnderPointer = self.graphicUnderPoint(mouselocation) {
            
            guard let milestoneGraphicController = graphicUnderPointer.userInfo as? MilestoneGraphicController else {return}
            guard let indexPath = msDict[milestoneGraphicController] else {return}
            guard let handler = delegate else {return}
            handler.timeGraph(graph: self, didSelectMilestoneAt: indexPath)
            
            
        } else {
            guard let xCalculator = timelineHorizontalCalculator else {return}
            if let handler = dateMarkedHandler {
                let indexOfTimeline = timelineVerticalCalculator?.timelineIndexForYPosition(yPosition: mouselocation.y) ?? 0
                if indexOfTimeline < timelines.count {
                    let timeline = timelines[indexOfTimeline]
                    let date = xCalculator.dateForXPosition(position: mouselocation.x + absoluteX)
                    handler(date, timeline)
                }
            }
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        let mouselocation = self.convert(event.locationInWindow, from: nil)
        
        func updateMilestoneLabel() {
            
            var newShowInfoLabel = false
            
            if let graphicUnderPointer = self.graphicUnderPoint(mouselocation) {
                
                if let milestoneGC = graphicUnderPointer.userInfo as? MilestoneGraphicController {
                
                /*    if let milestoneInfo = milestoneGC.milestone?.info {
                        if milestoneInfo.count > 0 {
                            
                            newShowInfoLabel = true
                            
                            if (currentlyDisplayedInfoLabel != nil) {
                                
                                currentlyDisplayedInfoLabel!.bounds = NSRect(x: mouselocation.x + 5, y: mouselocation.y + 5 , width: 200, height: 0)
                                currentlyDisplayedInfoLabel!.text = milestoneInfo
                                currentlyDisplayedInfoLabel!.sizeToFit()
                            }
                        }
                    }*/
                } else {
                    newShowInfoLabel = false
                }
            }
            
            if (showInfoLabel && !newShowInfoLabel) {
                if let index = graphics.index(of: currentlyDisplayedInfoLabel!) {
                    graphics.remove(at: index)
                    setNeedsDisplay(currentlyDisplayedInfoLabel!.bounds)
                }
            }
            
            if (!showInfoLabel && newShowInfoLabel) {
                graphics.append(currentlyDisplayedInfoLabel!)
                setNeedsDisplay(currentlyDisplayedInfoLabel!.bounds)
            }
            
            showInfoLabel = newShowInfoLabel
 
        }
        
        func updateDateIndicatorLine() {
            if let lineGraphic = dateIndictorLineGraphic {
                
                let deltaX = mouselocation.x - lastMouseLocation.x
                Graphic.translate(graphics: [lineGraphic], byX: deltaX, byY: 0)
                
            }
        }
        
        updateMilestoneLabel()
        
        lastMouseLocation = mouselocation
    }
 /*
    func updateForMarkedDate(date: Date, timelineAtIndex idx: Int) {
        markedDate = date
        indexOfMarkedTimeline = idx

  //      updateContent()
    }
 */
    func markMilestoneAt(indexPath: IndexPath) {
        if indexPath.count == 2 {
            let controller = msArray[indexPath[0]][indexPath[1]]
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
        msDict = [MilestoneGraphicController:IndexPath]()
        msArray = [[MilestoneGraphicController]]()

        for timelineIdx in 0..<numberOfTimelines {
            let numberOfMilestones = delegate?.timeGraph(graph: self,
                                                         numberOfMilestonesForTimelineAt: timelineIdx) ?? 0
            var msgArray = [MilestoneGraphicController]()
            for milestoneIdx in 0..<numberOfMilestones {
                if let info = dataSource?.timeGraph(graph: self,
                                                    milestoneAtIndex: milestoneIdx,
                                                    inTimelineAtIndex: timelineIdx) {
                    //initiate a MilestoneGraphic and append it to all graphics
                    let milestoneGraphicController = MilestoneGraphicController(info)
                    let relativeX =  relativePositionForAbsolute(xPosition: xPositionCalculator.centerXPositionFor(date: info.date))
                    milestoneGraphicController.position.x = relativeX
                    milestoneGraphicController.position.y = yPositionCalculator.yPositionForTimelineAt(index: timelineIdx)
                    graphics.append(contentsOf: milestoneGraphicController.graphics)
                    
                    msDict[milestoneGraphicController] = IndexPath(indexes: [timelineIdx, milestoneIdx])
                    msgArray.append(milestoneGraphicController)
                }
                msArray.append(msgArray)
            }
        }
        
        resetDescriptionLabel()
        //        resetDateIndicator()
        
        graphics.append(contentsOf: graphicsForBackground())
        graphics.append(contentsOf: graphicsForCurrentlyMarkedDate())
        graphics.append(contentsOf: graphicsForTodayIndicator())
        
        setNeedsDisplay(bounds)
    }
    
    //MARK: Drawing
    private func graphicsForCurrentlyMarkedDate() -> [Graphic] {
        guard let xPositionCalculator = timelineHorizontalCalculator else {return [Graphic]()}
        guard let yPositionCalculator = timelineVerticalCalculator else {return [Graphic]()}
        
        if let currentlyMarkedDate = markedDate {
            
            let absoluteDateX = xPositionCalculator.centerXPositionFor(date: currentlyMarkedDate)
            if absoluteDateX > absoluteX && absoluteDateX < absoluteX + bounds.size.width {
                
                let relativeX = absoluteDateX - absoluteX
                let markedDateGraphicController = DateIndicatorController(height:bounds.size.height,
                                                                          xPosition: relativeX)
                
                markedDateGraphicController.yPosition = yPositionCalculator.yPositionForTimelineAt(index: indexOfMarkedTimeline ?? 0)
                
                return markedDateGraphicController.graphics
            }
        }
        return [Graphic]()
    }
    
    private func graphicsForTodayIndicator() -> [Graphic] {
        guard let xPositionCalculator = timelineHorizontalCalculator else {return [Graphic]()}
        
        let todayIndicatorGraphics = GraphicsFactory.sharedInstance.graphicsForTodayIndicatorLine(height: self.bounds.size.height)
        let relativeXPos = relativePositionForAbsolute(xPosition: xPositionCalculator.centerXPositionFor(date: Date()))
        Graphic.translate(graphics: todayIndicatorGraphics, byX: relativeXPos, byY: 0)
        
        return todayIndicatorGraphics
    }
    
    private func graphicsForBackground() -> [Graphic] {
        guard let xPositionCalculator = timelineHorizontalCalculator else {return [Graphic]()}
        
        //Generate all vertical lines for months, calendarweeks, etc.
        let cwLineGraphics = GraphicsFactory.sharedInstance.graphicsForVerticalCalendarWeeksLinesStartingAt(startDate: startDate,
                                                                                                            height: self.bounds.size.height,
                                                                                                            length: self.bounds.size.width, usingCalculator: xPositionCalculator)
        return cwLineGraphics
    }
    
    func resetDescriptionLabel() {
    
        if (currentlyDisplayedInfoLabel != nil) {
            stopObservingKVOForGraphic(currentlyDisplayedInfoLabel!)
        }
    
        currentlyDisplayedInfoLabel = LabelGraphic()
        currentlyDisplayedInfoLabel?.fillColor = NSColor.yellow
        currentlyDisplayedInfoLabel?.isDrawingFill = true
        currentlyDisplayedInfoLabel?.textAlignment = .left
        startObservingGraphic(currentlyDisplayedInfoLabel!)
    }
    
    func resetDateIndicator() {
        
        if (dateIndictorLineGraphic != nil) {
            stopObservingKVOForGraphic(dateIndictorLineGraphic!)
        }
        dateIndictorLineGraphic = GraphicsFactory.sharedInstance.graphicsForDateIndicatorLine(height: self.bounds.size.height)[0] as? LineGraphic
        lastMouseLocation = CGPoint(x: 0, y: 0)
        graphics.insert(dateIndictorLineGraphic!, at: 0)
        startObservingGraphic(dateIndictorLineGraphic!)
    }
    
    
    //MARK: Helper
    
    private func relativePositionForAbsolute(xPosition :CGFloat) -> CGFloat{
        guard let xPositionCalculator = timelineHorizontalCalculator else {return 0.0}
        
        let absoluteStartX = xPositionCalculator.xPositionFor(date: startDate)
        return xPosition - absoluteStartX
    }
}




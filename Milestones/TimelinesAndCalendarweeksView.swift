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



let MILESTONE_SELECTED_NOTIFICATION = "MILESTONE_SELECTED_NOTIFICATION"
let MILESTONE_SELECTED_NOTIFICATION_PAYLOAD_KEY = "MILESTONE_SELECTED_KEY"


class TimelinesAndCalendarWeeksView: GraphicView {
    
    
    private var showInfoLabel: Bool = false

    var timelineHorizontalCalculator: HorizontalCalculator?
    var timelineVerticalCalculator: VerticalCalculator?

    private var currentTrackingArea: NSTrackingArea?
    private var currentlyDisplayedInfoLabel: LabelGraphic?
    private var dateIndictorLineGraphic: LineGraphic?
    private var milestoneGraphicControllers: [MilestoneGraphicController] = [MilestoneGraphicController]()
    
    private var lastMouseLocation: NSPoint = NSZeroPoint
    
    //    userInitiated (async UI related tasks) -> high priority global queue
    private var dispatchQueue = DispatchQueue.global(qos: .userInitiated)
    private var graphicsWorkItem: DispatchWorkItem = DispatchWorkItem(block: {})
    

    //MARK: Life dycle
    init(withLength length: CGFloat, horizontalCalculator: HorizontalCalculator, verticalCalculator: VerticalCalculator){
        self.timelineVerticalCalculator = verticalCalculator
        self.timelineHorizontalCalculator = horizontalCalculator
        super.init(frame: NSRect(x: 0, y: 0, width: length, height: 800))
        
        
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        if currentlyDisplayedInfoLabel != nil {
            stopObservingKVOForGraphic(currentlyDisplayedInfoLabel!)
        }
        
        if dateIndictorLineGraphic != nil {
            stopObservingKVOForGraphic(dateIndictorLineGraphic!)
        }
        
    }
    
    func milestoneGraphicControllerForMilestone(_ milestone: Milestone) -> MilestoneGraphicController? {
       
        let filteredArray = milestoneGraphicControllers.filter({
            if ($0.milestone == milestone) {
                return true
            } else {
                return false
            }
        })
        
        if filteredArray.count > 0 {
            return filteredArray[0]
        }
        return nil
    }
    
    
    //MARK: KVO
    func startObservingGraphic(_ aGraphic: Graphic) {
        let KVOOptions = NSKeyValueObservingOptions([.new, .old])
        aGraphic.addObserver(self, forKeyPath: "drawingBounds", options: KVOOptions, context: nil)
    }
    
    func stopObservingKVOForGraphic(_ aGraphic: Graphic){
        aGraphic.removeObserver(self, forKeyPath: "drawingBounds")
    }
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if object is Graphic {
            if keyPath == "drawingBounds"{
                // Redraw the part of the view that the graphic used to occupy, and the part that it now occupies.
                if let theChange = change as? [NSKeyValueChangeKey: NSValue] {
                    
                    let oldValue = theChange[NSKeyValueChangeKey.oldKey]?.rectValue
                    let newValue = theChange[NSKeyValueChangeKey.newKey]?.rectValue
                    
                    guard (oldValue != nil) && (newValue != nil) else {return}
                    
                    self.setNeedsDisplay(oldValue!)
                    self.setNeedsDisplay(newValue!)
                }
            }
        }
    }
    
    //MARK: Mouse Handling
    func graphicUnderPoint(_ aPoint: NSPoint) -> Graphic? {
        for aGraphic in graphics {
            if aGraphic.isContentUnderPoint(aPoint) {
                return aGraphic
            }
        }
        return nil
    }
    
    override func mouseDown(with event: NSEvent) {
        let mouselocation = self.convert(event.locationInWindow, from: nil)
        
        guard let graphicUnderPointer = self.graphicUnderPoint(mouselocation) else { return }
        guard let milestoneGraphicController = graphicUnderPointer.userInfo as? MilestoneGraphicController else { return }

        var info: [AnyHashable : Any] = [AnyHashable : Any]()
        info[MILESTONE_SELECTED_NOTIFICATION_PAYLOAD_KEY] = milestoneGraphicController.milestone
        NotificationCenter.default.post(name: Notification.Name(rawValue: MILESTONE_SELECTED_NOTIFICATION),
                                        object: self,
                                        userInfo: info)
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        let mouselocation = self.convert(event.locationInWindow, from: nil)
        
        func updateMilestoneLabel() {
            
            var newShowInfoLabel = false
            
            if let graphicUnderPointer = self.graphicUnderPoint(mouselocation) {
                
                if let milestoneGC = graphicUnderPointer.userInfo as? MilestoneGraphicController {
                    
                    if let milestoneInfo = milestoneGC.milestone?.info {
                        if milestoneInfo.count > 0 {
                            
                            newShowInfoLabel = true
                            
                            if (currentlyDisplayedInfoLabel != nil) {
                                
                                currentlyDisplayedInfoLabel!.bounds = NSRect(x: mouselocation.x + 5, y: mouselocation.y + 5 , width: 200, height: 0)
                                currentlyDisplayedInfoLabel!.text = milestoneInfo
                                currentlyDisplayedInfoLabel!.sizeToFit()
                            }
                        }
                    }
                } else {
                    newShowInfoLabel = false
                }
            }
            
            if showInfoLabel && !newShowInfoLabel {
                if let index = graphics.index(of: currentlyDisplayedInfoLabel!) {
                    graphics.remove(at: index)
                    setNeedsDisplay(currentlyDisplayedInfoLabel!.bounds)
                }
            }
            
            if !showInfoLabel && newShowInfoLabel {
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
     //   updateDateIndicatorLine()
        lastMouseLocation = mouselocation
    }
    
    func updateForGroup(group :Group, firstVisibleDate date: Date) {
        guard let timelines = group.timelines?.array as? [Timeline] else { return }
        updateFrameFor(numberOfTimelines: timelines.count)
        
        let viewBounds = self.bounds
        graphicsWorkItem.cancel()
        graphicsWorkItem = DispatchWorkItem {
            self.updateContentForTimelines(timelines: timelines,
                                           startDate: date,
                                           viewBounds: viewBounds)
        }
        
        dispatchQueue.async(execute: graphicsWorkItem)
        setNeedsDisplay(bounds)
    }
    
    private func updateFrameFor(numberOfTimelines :Int) {
        //Update this views frame
        let height = timelineVerticalCalculator?.yPositionForTimelineAt(index: numberOfTimelines) ?? 100
        self.frame = NSMakeRect(frame.origin.x,
                                frame.origin.y,
                                frame.size.width,
                                height)
        
        //Update the tracking area
        if let trackingArea = currentTrackingArea {
            self.removeTrackingArea(trackingArea)
        }
        
        let trackingOptions :NSTrackingArea.Options = [NSTrackingArea.Options.mouseMoved,NSTrackingArea.Options.activeAlways]
        currentTrackingArea = NSTrackingArea(rect: self.bounds,
                                             options: trackingOptions,
                                             owner: self,
                                             userInfo: nil)
        self.addTrackingArea(currentTrackingArea!)

    }
    
    private func updateContentForTimelines(timelines :[Timeline],
                                           startDate: Date,
                                           viewBounds: CGRect) {
        
        guard let xPositionCalculator = timelineHorizontalCalculator else { return }
        guard let yPositionCalculator = timelineVerticalCalculator else { return }
        
        if let infoLabel = currentlyDisplayedInfoLabel {
            stopObservingKVOForGraphic(infoLabel)
        }

        if let indicatorGraphic = dateIndictorLineGraphic {
            stopObservingKVOForGraphic(indicatorGraphic)
        }
        
        graphics.removeAll()
        milestoneGraphicControllers.removeAll()
        
        //Generate timeline graphics
        var idx = 0
        for aTimeline in timelines {


            let timelineGraphics = GraphicsFactory.sharedInstance.timelineGraphicsFor(timeline: aTimeline,
                                                                                      length: viewBounds.size.width,
                                                                                      startDate: startDate,
                                                                                      usingCalculator: xPositionCalculator)

            
            let yPos = yPositionCalculator.yPositionForTimelineAt(index: idx)
            Graphic.translate(graphics: timelineGraphics.allGraphics, byX: 0.0, byY: yPos)
            graphics.append(contentsOf: timelineGraphics.allGraphics)
            milestoneGraphicControllers.append(contentsOf: timelineGraphics.milestoneGraphicControllers)
            
            idx = idx + 1
        }
        
        //Generate all vertical lines for months, calendarweeks, etc.
        let cwLineGraphics = GraphicsFactory.sharedInstance.graphicsForVerticalCalendarWeeksLinesStartingAt(startDate: startDate,
                                                                                                            height: viewBounds.size.height,
                                                                                                            length: viewBounds.size.width, usingCalculator: xPositionCalculator)
        graphics.append(contentsOf: cwLineGraphics)
        
        // Generate the line, which indicates the current date
        let todayIndicatorGraphics = GraphicsFactory.sharedInstance.graphicsForTodayIndicatorLine(height: viewBounds.size.height)
        let relativeXPos = xPositionCalculator.centerXPositionFor(date: Date()) - xPositionCalculator.xPositionFor(date: startDate)
        Graphic.translate(graphics: todayIndicatorGraphics, byX: relativeXPos, byY: 0)
        graphics.insert(contentsOf: todayIndicatorGraphics, at: 0)

        //Generate the line which follows the mouse curser
        dateIndictorLineGraphic = GraphicsFactory.sharedInstance.graphicsForDateIndicatorLine(height: viewBounds.size.height)[0] as? LineGraphic
        lastMouseLocation = CGPoint(x: 0, y: 0)
        graphics.insert(dateIndictorLineGraphic!, at: 0)
        
        startObservingGraphic(dateIndictorLineGraphic!)

        currentlyDisplayedInfoLabel = LabelGraphic()
        currentlyDisplayedInfoLabel?.fillColor = NSColor.yellow
        currentlyDisplayedInfoLabel?.isDrawingFill = true
        currentlyDisplayedInfoLabel?.textAlignment = .left
        startObservingGraphic(currentlyDisplayedInfoLabel!)
        
    }
}




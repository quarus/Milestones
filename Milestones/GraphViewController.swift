//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  GraphViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class GraphViewController :NSViewController, StateObserverProtocol, CoreDataNotificationManagerDelegate, ClipViewDelegate {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    var verticalRulerView :VerticalRulerview?
    var horizontalRulerView :HorizontalRulerView?
    var timelinesAndGraphicsView :TimelinesAndCalendarWeeksView?

    private var MOCHandler = CoreDataNotificationManager()

    private weak var currentlySelectedMilestoneGraphicController: MilestoneGraphicController?
    
    var firstVisibleDate = Date().normalized() ?? Date()

    let length :CGFloat = 8000.0
    
    var currentLengthOfDay: CGFloat = 40 {
        didSet {

            if (currentLengthOfDay > 150) {
                currentLengthOfDay = 150
            
            } else if (currentLengthOfDay < 10) {
                currentLengthOfDay = 10
            }
        }
    }
    
    var magnificationCenterDate: Date?
    var magnificationClipViewDelta: CGFloat = 0
    
    override var representedObject: Any? {
        
        didSet {
            MOCHandler.deregisterForMOCNotifications()
            MOCHandler.registerForNotificationsOn(moc: dataModel()?.managedObjectContext)
            MOCHandler.delegate = self
            
            dataModel()?.remove(dataObserver: self)
            dataModel()?.add(dataObserver: self)
        }
    }
    
    //MARK: View life cycle
    deinit {
    }
    
    override  func viewDidAppear() {
        
        
        guard let horizCalc = timelineHorizontalCalculator() else {return}
        guard let vertCalc = timelineVerticalCalculator() else {return}
        
        let heightOfHorizontalRulerView :CGFloat = 50
        
        timelinesAndGraphicsView = TimelinesAndCalendarWeeksView(withLength: length,
                                                                 horizontalCalculator: horizCalc,
                                                                 verticalCalculator: vertCalc)
        
        scrollView.documentView?.addSubview(timelinesAndGraphicsView!)
        timelinesAndGraphicsView?.frame.origin.y = heightOfHorizontalRulerView
        
        if let view = scrollView?.documentView as? GraphicView {
            view.frame = NSRect(x: 0, y: 0, width: length, height: 800)
        }
        
        let yOffSet = heightOfHorizontalRulerView
        
        horizontalRulerView = HorizontalRulerView(withLength: length, height: heightOfHorizontalRulerView, horizontalCalculator: horizCalc)
        verticalRulerView = VerticalRulerview(withLength: 120, positionCalculator: vertCalc)
        
        verticalRulerView?.frame.origin = CGPoint(x: 0, y: yOffSet)
        
        scrollView.addFloatingSubview(horizontalRulerView!, for: .vertical)
        scrollView.addFloatingSubview(verticalRulerView!, for: .horizontal)
        
        
        if let clipView = scrollView.contentView as? ClipView {
            
            clipView.scroll(to: NSPoint(x: length/2, y: 0))
            clipView.registerForBoundsChangedNotifications()
            clipView.delegate = self
        }
        
        updateViews()
    }
    
    //MARK: Helper Functions
    private func dataModel() -> StateProtocol? {
        
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        guard let dependencies = representedObject as? AnyObject as? Dependencies else {return nil}
        return dependencies.stateModel
        
    }
    
    private func timelineHorizontalCalculator() -> HorizontalCalculator? {
       
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        var dependencies = representedObject as? AnyObject as? Dependencies
        return dependencies?.xCalculator

    }
    
    private func timelineVerticalCalculator() -> VerticalCalculator? {
        
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        var dependencies = representedObject as? AnyObject as? Dependencies
        return dependencies?.yCalculator
        
    }
    

    func update() {
        updateViews()
    }
    
    private func isDateVisible(_ date: Date) -> Bool {
        
        guard let horizontalCalulator = timelineHorizontalCalculator() else {return false}
        
        let clipViewStartX = clipView.bounds.minX + horizontalCalulator.xPositionFor(date: firstVisibleDate)
        let clipViewEndX = clipViewStartX + clipView.bounds.size.width
        
        let dateXPosition = horizontalCalulator.xPositionFor(date: date)
        
        if ((dateXPosition >= clipViewStartX) && (dateXPosition <= clipViewEndX)) {
            return true
        }
        
        return false
    }

    
    private func lengthOfDayFor(magnifcation magnification: CGFloat) -> CGFloat {
        
        let slowingFactor: CGFloat = 0.25
        let scaleFactor = 1 + magnification * slowingFactor
        let newLengthOfDay = currentLengthOfDay * scaleFactor

        return newLengthOfDay
    }
    
    @IBAction func handleMagnificationChange(gestureRecognizer: NSMagnificationGestureRecognizer) {
        
        guard var xCalculator = timelineHorizontalCalculator() else {return}
    // The general idea is to scale the content, while always maintaing the same distance between the date on which the
    // the zoom occured on and the left boundary of the clipview.
   
        switch gestureRecognizer.state {
        case .began:
            
            let locationInView = gestureRecognizer.location(in: scrollView.documentView)
            let absolutePosition = xCalculator.xPositionFor(date: firstVisibleDate) + locationInView.x
            magnificationCenterDate = xCalculator.dateForXPosition(position: absolutePosition)
            magnificationClipViewDelta = locationInView.x - clipView.visibleRect.minX
       
        case .changed:
            
            if magnificationCenterDate != nil {
                
                currentLengthOfDay = lengthOfDayFor(magnifcation: gestureRecognizer.magnification)
                xCalculator.lengthOfDay = currentLengthOfDay
                realginAfterScrollAround(magnificationCenterDate!)
                
                let relpos = xCalculator.lengthBetween(firstDate: firstVisibleDate, secondDate: magnificationCenterDate! )
                clipView.bounds.origin.x = relpos - magnificationClipViewDelta
                
            }
        case .ended:
            magnificationCenterDate = nil
        
        default:
            break
        }
 
 
    }
    
    //MARK: DataObserverProtocol
    func didChangeSelectedGroup(_ group: Group?) {
        update()
    }
    
    func didChangeSelectedTimeline(_ selectedTimelines: [Timeline]) {
        
    }
    
    func didChangeSelectedMilestone(_ milestone :Milestone?){
        
        if let date = milestone?.date {
            
            if !isDateVisible(date) {
                centerAroundDate(date)
            } else {
                highlightCurrentlySelectedMilestone()
            }
        }
    }
    
    //MARK: Managed Object Context Change Handling
    func managedObjectContext(_ moc: NSManagedObjectContext, didInsertObjects objects: NSSet) {
        update()
    }

    func managedObjectContext(_ moc: NSManagedObjectContext, didUpdateObjects objects: NSSet) {
        update()
    }
    
    func managedObjectContext(_ moc: NSManagedObjectContext, didRemoveObjects objects: NSSet) {
        update()
    }
    
    //MARK: ClipViewDelegate
    func clipViewWillRecenter(_ clipView :ClipView) {

    }

    func clipViewDidRecenter(_ clipView :ClipView) {
        
    }
    
    func clipViewDidMove(_ clipView: ClipView) {

    }
    
    func clipViewNeedsRecentering(_ clipView: ClipView) {
        
        
        guard let xCalculator = timelineHorizontalCalculator() else {return}

        /*
         *                           |                                |
         *   Document View           |            ClipView            |
         *                           |                                |
         *                           |                                |
         *                           |                                |
         *  +------------------------+--------------------------------+----------
         *firstVisDate              position
         *
         */
        
        let position = xCalculator.xPositionFor(date: firstVisibleDate) + clipView.frame.origin.x
        let date = xCalculator.dateForXPosition(position: position)
        realginAfterScrollAround(date)
    
    }
    
    private func centerAroundDate(_ date: Date) {
        
        guard let xCalculator = timelineHorizontalCalculator() else {return}

        
        let positionOfDate = xCalculator.xPositionFor(date: date)
        let positionOfFirstDate = positionOfDate - (length / 2.0)
        firstVisibleDate = xCalculator.dateForXPosition(position: positionOfFirstDate)
        
        updateViews()
        
        let absolutePositionOfClipViewMinX = positionOfDate - (clipView.frame.size.width / 2.0)
        let relativePositionOfClipViewMinX = absolutePositionOfClipViewMinX - positionOfFirstDate
        clipView.bounds.origin.x = relativePositionOfClipViewMinX
    }

    private func realginAfterScrollAround(_ date: Date) {
        
        guard let xCalculator = timelineHorizontalCalculator() else {return}

        
        /*
         *                           |                                |
         *   Document View           |            ClipView            |
         *                           |                                |
         *                           |                                |
         *                           |<--- offset --->                |
         *  +------------------------+----------------|---------------+----------
         *firstVisDate        smallestVisDate         date
         *
         *
         *
         */
        
        let posFirstVisibileDate = xCalculator.xPositionFor(date: firstVisibleDate)
        let posClipRectMinX = posFirstVisibileDate + clipView.documentVisibleRect.origin.x

        let smallestVisibileDate = xCalculator.dateForXPosition(position: posClipRectMinX)
        
        let posDate = xCalculator.xPositionFor(date: date)
        let offset = fabs(xCalculator.xPositionFor(date: smallestVisibileDate) - posDate)

        
        let posNewFirstVisibleDate = posClipRectMinX - length / 2.0
        let newFirstVisibleDate = xCalculator.dateForXPosition(position: posNewFirstVisibleDate)

        firstVisibleDate = newFirstVisibleDate
        updateViews()
        
        
        let relativePositionOfCurrentlyVisibleDate = xCalculator.xPositionFor(date: date) - xCalculator.xPositionFor(date: firstVisibleDate)
        
        clipView.bounds.origin.x = relativePositionOfCurrentlyVisibleDate + offset

    }

    //MARK: Helper funcions
    func updateViews() {
        
        guard let currentGroup = dataModel()?.selectedGroup else {return}
        guard let timelines = dataModel()?.selectedGroup?.timelines?.array as? [Timeline]  else {return}
        
        horizontalRulerView?.updateForStartDate(date: firstVisibleDate)
        verticalRulerView?.updateFor(timelines: timelines)

        timelinesAndGraphicsView?.updateForGroup(group: currentGroup,
                                firstVisibleDate: firstVisibleDate,
                                length: length)
                
        
        highlightCurrentlySelectedMilestone()
        

        //recalculate the documents view new height
        if let currentFrame = scrollView.documentView?.frame {
            let newHeight = (timelinesAndGraphicsView?.frame.size.height ?? 0) + (horizontalRulerView?.frame.size.height ?? 0)
            scrollView.documentView?.frame.size = NSSize(width: currentFrame.width, height: newHeight)
        }
    }
    
    private func highlightCurrentlySelectedMilestone() {
        
        guard let selectedMilestone = dataModel()?.selectedMilestone else {return}
        
        if (currentlySelectedMilestoneGraphicController != nil) {
            currentlySelectedMilestoneGraphicController!.iconGraphic.isSelected = false
            view.setNeedsDisplay(currentlySelectedMilestoneGraphicController!.iconGraphic.bounds)
            view.display()
            
        }
        
        currentlySelectedMilestoneGraphicController = timelinesAndGraphicsView?.milestoneGraphicControllerForMilestone(selectedMilestone)
        if let mgc = currentlySelectedMilestoneGraphicController{
            mgc.iconGraphic.isSelected = true
            view.setNeedsDisplay(mgc.iconGraphic.bounds)
            view.display()
        }
    }

}

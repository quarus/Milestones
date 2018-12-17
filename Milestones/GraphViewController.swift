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
    var currentLengthOfDay: CGFloat = 40

    var pageModel: PageModel?
    
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
        
        pageModel = PageModel(horizontalCalculator: horizCalc,
                              startDate: firstVisibleDate,
                              length: length)
        pageModel?.clipViewLength = clipView.bounds.size.width
        pageModel?.clipViewRelativeX = length/2.0
        
        if let clipView = scrollView.contentView as? ClipView {
            

            clipView.scroll(to: NSPoint(x: length/2.0, y: 0))
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
    
    private func isDateVisible(_ date: Date) -> Bool {
        
        guard let horizontalCalulator = timelineHorizontalCalculator() else {return false}
        
        let clipViewStartX = clipView.bounds.minX + horizontalCalulator.xPositionFor(date: firstVisibleDate)
        let clipViewEndX = clipViewStartX + clipView.bounds.size.width
        
        let dateXPosition = horizontalCalulator.xPositionFor(date: date)
        
        if (dateXPosition >= clipViewStartX) && (dateXPosition <= clipViewEndX) {
            return true
        }
        return false
    }

    
    private func currentlyVisibleCenterDate() -> Date? {
        guard let xCalculator = timelineHorizontalCalculator() else { return nil }

        let absolutePositionOfFirstVisibleDate = xCalculator.xPositionFor(date: firstVisibleDate)
        let clipViewOffset = (clipView.frame.size.width / 2.0) + clipView.visibleRect.minX
        let absolutePositionOfCurrentlyCenteredDate = absolutePositionOfFirstVisibleDate +
                                                    clipViewOffset
    
        let date = xCalculator.dateForXPosition(position: absolutePositionOfCurrentlyCenteredDate)
        return date
    }
    
    func updateViews() {
        guard let currentGroup = dataModel()?.selectedGroup else {return}
        guard let timelines = dataModel()?.selectedGroup?.timelines?.array as? [Timeline]  else {return}
        guard let pageModelFirstVisibleDate = pageModel?.startDate else {return}
        guard let pageModelLength = pageModel?.length else {return}
            
        horizontalRulerView?.updateForStartDate(date: pageModelFirstVisibleDate)
        verticalRulerView?.updateFor(timelines: timelines)
        
        timelinesAndGraphicsView?.updateForGroup(group: currentGroup,
                                                 firstVisibleDate: pageModelFirstVisibleDate,
                                                 length: pageModelLength)
        
        
 /*       highlightCurrentlySelectedMilestone()
        
        
        //recalculate the documents view new height
        if let currentFrame = scrollView.documentView?.frame {
            let newHeight = (timelinesAndGraphicsView?.frame.size.height ?? 0) + (horizontalRulerView?.frame.size.height ?? 0)
            scrollView.documentView?.frame.size = NSSize(width: currentFrame.width, height: newHeight)
        }*/
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
    //MARK: DataObserverProtocol
    func didChangeSelectedGroup(_ group: Group?) {
        updateViews()
    }
    
    func didChangeZoomLevel(_ level: ZoomLevel) {
        applyZoomLevel(level)
    }
    
    func didChangeSelectedTimeline(_ selectedTimelines: [Timeline]) {}
    
    func didChangeSelectedMilestone(_ milestone :Milestone?){
        guard let model = pageModel else {return}
        
        if let date = milestone?.date {
            
            if model.contains(date: date) {
                centerAroundDate(date)
            }
        
//            highlightCurrentlySelectedMilestone()
        }
    }
    
    //MARK: Managed Object Context Change Handling
    func managedObjectContext(_ moc: NSManagedObjectContext, didInsertObjects objects: NSSet) {
        updateViews()
    }

    func managedObjectContext(_ moc: NSManagedObjectContext, didUpdateObjects objects: NSSet) {
        updateViews()
    }
    
    func managedObjectContext(_ moc: NSManagedObjectContext, didRemoveObjects objects: NSSet) {
        updateViews()
    }
    
    //MARK: ClipViewDelegate
    func clipViewDidMove(_ clipView: ClipView) {
        print(clipView.bounds.origin.x)
        pageModel?.clipViewRelativeX = clipView.bounds.origin.x

    }
    
    func clipViewPassedEdgeTreshold(_ clipView: ClipView) {
        
        print("Recenter")
        pageModel = pageModel?.makePageModelCenteredAroundClipView()
        updateViews()
        clipView.bounds.origin.x = pageModel?.clipViewRelativeX ?? 0.0
    }
    
  

    private func centerAroundDate(_ date: Date) {
        guard let xCalculator = timelineHorizontalCalculator() else {return}
        
        let positionOfDate = xCalculator.xPositionFor(date: date)
        let positionOfFirstDate = positionOfDate - (length / 2.0)
        firstVisibleDate = xCalculator.dateForXPosition(position: positionOfFirstDate)
        print("New first visible date: \(firstVisibleDate)")
        
        updateViews()

        //align the clipview so that the date is in its center.
        let numberOfDaysOffset = Int (clipView.frame.size.width / 2.0) / Int(currentLengthOfDay)
        let absolutePositionOfClipViewMinX = positionOfDate - CGFloat(numberOfDaysOffset) * currentLengthOfDay
        let relativePositionOfClipViewMinX = absolutePositionOfClipViewMinX - positionOfFirstDate
        clipView.bounds.origin.x = relativePositionOfClipViewMinX
    }
    
    private func applyZoomLevel(_ level: ZoomLevel) {
        guard var xCalculator = timelineHorizontalCalculator() else {return}
        
        let currentCenterDate = currentlyVisibleCenterDate()
        print("Current center Date \(currentCenterDate)")
        currentLengthOfDay = CGFloat(level.rawValue)
        xCalculator.lengthOfDay = currentLengthOfDay
        
        updateViews()
        
        if let date = currentCenterDate {
            print("Centering around Date \(date)")
            centerAroundDate(date)
        }
    }

}

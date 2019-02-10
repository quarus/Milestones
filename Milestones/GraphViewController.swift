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

    private var MOCHandler: CoreDataNotificationManager?

    private weak var currentlySelectedMilestoneGraphicController: MilestoneGraphicController?
    
    let length :CGFloat = 8000.0
    var currentLengthOfDay: CGFloat = 40

    var pageModel: PageModel? {
        didSet {
            clipView.bounds.origin.x = pageModel?.clipViewRelativeX ?? 0.0
        }
    }
    
    override var representedObject: Any? {
        
        didSet {
            
            if let moc = dataModel()?.managedObjectContext {
                MOCHandler = CoreDataNotificationManager(managedObjectContext: moc)
                MOCHandler?.delegate = self
            }
            
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
        timelinesAndGraphicsView?.milestoneClickedHandler = userDidSelectMilestone
        timelinesAndGraphicsView?.dateMarkedHandler = userDidMarkDate
        
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
                              startDate: Date(),
                              length: length,
                              clipViewLength:clipView.bounds.size.width)
        pageModel?.clipViewRelativeX = length/2.0
        
        if let clipView = scrollView.contentView as? ClipView {
            
            clipView.bounds.origin = CGPoint(x: length/2.0, y: 0.0)
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
    
    func updateViews() {
        guard let timelines = dataModel()?.selectedGroup?.timelines?.array as? [Timeline]  else {return}
        guard let pageModelFirstVisibleDate = pageModel?.startDate else {return}
        guard let pageModelLength = pageModel?.length else {return}
            
        horizontalRulerView?.updateForStartDate(date: pageModelFirstVisibleDate)
        verticalRulerView?.updateFor(timelines: timelines)
        
        timelinesAndGraphicsView?.updateForTimelines(timelines: timelines,
                                                      firstVisibleDate: pageModelFirstVisibleDate,
                                                      length: pageModelLength)
        highlightCurrentlySelectedMilestone()
    }
    
    private func highlightCurrentlySelectedMilestone() {
        
        guard let selectedMilestone = dataModel()?.selectedMilestone else {return}
        
        if (currentlySelectedMilestoneGraphicController != nil) {
            currentlySelectedMilestoneGraphicController!.iconGraphic.isSelected = false
            timelinesAndGraphicsView?.setNeedsDisplay(currentlySelectedMilestoneGraphicController!.iconGraphic.bounds)
            
        }
        
        currentlySelectedMilestoneGraphicController = timelinesAndGraphicsView?.milestoneGraphicControllerForMilestone(selectedMilestone)
        if let mgc = currentlySelectedMilestoneGraphicController{
            mgc.iconGraphic.isSelected = true
            timelinesAndGraphicsView?.setNeedsDisplay(mgc.iconGraphic.bounds)
        }
        
        timelinesAndGraphicsView?.display()
    }
    
    //MARK: Event Handling
    func userDidSelectMilestone(milestone: Milestone) {
        guard let stateModel = dataModel() else {return}
        stateModel.selectedMilestone = milestone
    }
    
    func userDidMarkDate(date: Date, timeline: Timeline) {
        print(date)
        print(timeline.name)
        dataModel()?.markedDate = date
        dataModel()?.markedTimeline = timeline
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
            if !model.clipViewContains(date: date) {
                centerAroundDate(date)
            }
            highlightCurrentlySelectedMilestone()
        }
    }
    
    func didChangeMarkedTimeline(_ markedTimeline: Timeline?) {
        guard let markedDate = dataModel()?.markedDate else {return}
        guard let markedTimeline = dataModel()?.markedTimeline else {return}
        
        timelinesAndGraphicsView?.updateForMarkedDate(date: markedDate,
                                                      timeline: markedTimeline)
    }
    
    func didChangeMarkedDate(_ markedDate: Date?) {
        guard let markedDate = dataModel()?.markedDate else {return}
        guard let markedTimeline = dataModel()?.markedTimeline else {return}
        
        timelinesAndGraphicsView?.updateForMarkedDate(date: markedDate,
                                                      timeline: markedTimeline)
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
    func clipViewFrameDidChange(_ clipView: ClipView) {
        pageModel?.clipViewLength = clipView.bounds.size.width
    }

    func clipViewDidMove(_ clipView: ClipView) {
        pageModel?.clipViewRelativeX = clipView.bounds.origin.x
    }
    
    func clipViewPassedEdgeTreshold(_ clipView: ClipView) {
        pageModel = pageModel?.makePageModelCenteredAroundClipView()
        updateViews()
    }

    private func centerAroundDate(_ date: Date) {
        guard let xCalculator = timelineHorizontalCalculator() else {return}
        guard let model = pageModel else {return}
        
        let newModel = PageModel(horizontalCalculator: xCalculator,
                                 centerDate: date,
                                 length: model.length,
                                 clipViewLength: model.clipViewLength)
        
        pageModel = newModel
        updateViews()
    }
    
    private func applyZoomLevel(_ level: ZoomLevel) {
        guard var xCalculator = timelineHorizontalCalculator() else {return}
        guard let model = pageModel else {return}

        let currentCenterDate = model.clipViewCenterDate
        xCalculator.lengthOfDay =  CGFloat(level.rawValue)
        centerAroundDate(currentCenterDate)
    }
}

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
    var horizontalRulerView :RulerView?
    var timelinesAndGraphicsView :TimeGraph?

    private var MOCHandler: CoreDataNotificationManager?
    
    let length :CGFloat = 8000.0

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
        
        let heightOfHorizontalRulerView :CGFloat = 75
        
        timelinesAndGraphicsView = TimeGraph(withLength: length,
                                                                 horizontalCalculator: horizCalc,
                                                                 verticalCalculator: vertCalc)

        timelinesAndGraphicsView?.delegate = self
        timelinesAndGraphicsView?.dataSource = self
        
        scrollView.documentView?.addSubview(timelinesAndGraphicsView!)
        timelinesAndGraphicsView?.frame.origin.y = heightOfHorizontalRulerView
        
        if let view = scrollView?.documentView as? GraphicView {
            view.frame = NSRect(x: 0, y: 0, width: length, height: 800)
        }
        
        let yOffSet = heightOfHorizontalRulerView
        
        horizontalRulerView = RulerView(withLength: length,
                                        height: heightOfHorizontalRulerView,
                                        horizontalCalculator: horizCalc)
        
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
        applyZoomLevel(.month)
        
    }
    
    func updateViews() {
        guard let timelines = dataModel()?.selectedGroup?.timelines?.array as? [Timeline]  else {return}
        guard let pageModelFirstVisibleDate = pageModel?.startDate else {return}
        
        horizontalRulerView?.updateForStartDate(date: pageModelFirstVisibleDate)
        verticalRulerView?.updateFor(timelines: timelines)
        
        timelinesAndGraphicsView?.reloadData()
                
        if let selectedMilestone = dataModel()?.selectedMilestone {
            if let path = dataModel()?.selectedGroup?.indexPathFor(milestone: selectedMilestone) {
                timelinesAndGraphicsView?.selectMilestoneAt(indexPath: path)
            }
        }
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

    //MARK: DataObserverProtocol
    func didChangeSelectedGroup(_ group: Group?) {
        updateViews()
    }
    
    func didChangeZoomLevel(_ level: ZoomLevel) {
        applyZoomLevel(level)
    }
    
    func didChangeSelectedTimeline(_ selectedTimelines: [Timeline]) {}
    
    func didChangeSelectedMilestone(_ milestone :Milestone?){

        selectAndCenterMilestone()
    }
    
    func didChangeMarkedTimeline(_ markedTimeline: Timeline?) {
        updateDateMarking()
    }
    
    func didChangeMarkedDate(_ markedDate: Date?) {
        updateDateMarking()
    }
    
    private func updateDateMarking() {
        guard let markedDate = dataModel()?.markedDate else {return}
        guard let markedTimeline = dataModel()?.markedTimeline else {return}
        guard let timelines = dataModel()?.selectedGroup?.timelines?.array as? [Timeline] else {return}
        
        let idx = timelines.firstIndex(of: markedTimeline) ?? 0
        horizontalRulerView?.displayMarkerAtDate(date: markedDate)
        timelinesAndGraphicsView?.setMarkedDate(date: markedDate, andTimelineAtIndex: idx)
        timelinesAndGraphicsView?.reloadData()
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
        
        var source: RulerViewGraphicsSource?
        var lengthOfDay = CGFloat(ZoomLevel.month.rawValue)
        
        switch level {
        case .quarter:
            lengthOfDay = CGFloat(ZoomLevel.quarter.rawValue)
            source = QuarterAndMonthGraphicsSource()
        case .month:
            lengthOfDay = CGFloat(ZoomLevel.month.rawValue)
            source = MonthAndWeekGraphicsSource()
            
        case .year:
            lengthOfDay = CGFloat(ZoomLevel.year.rawValue)
            source = YearAndQuarterGraphicsSource()
        default:
            break
        }
        
        xCalculator.lengthOfDay = lengthOfDay
        horizontalRulerView?.dataSource = source
        timelinesAndGraphicsView?.graphicsSource = TimeGraphBackground()

        //Update all views
        centerAroundDate(currentCenterDate)
    }
    
    func selectAndCenterMilestone() {
        guard let model = pageModel else {return}
        guard let selectedMilestone = dataModel()?.selectedMilestone else {return}
        
        if let date = selectedMilestone.date {
            if !model.clipViewContains(date: date) {
                centerAroundDate(date)
            }
        }
            
        if let path = dataModel()?.selectedGroup?.indexPathFor(milestone: selectedMilestone) {
                timelinesAndGraphicsView?.selectMilestoneAt(indexPath: path)
        }
    }
}

extension GraphViewController: TimeGraphDataSource, TimeGraphDelegate {
  
    //TimeGraphDataSource
    func timeGraph(graph: TimeGraph, milstoneAt indexPath: IndexPath) -> MilestoneProtocol {
        guard let selectedGroup = dataModel()?.selectedGroup else {return MilestoneInfo()}
        if let milestone = selectedGroup.milestoneAt(indexPath: indexPath) {
            return MilestoneInfo(milestone)
        }
        return MilestoneInfo()
    }
    
    func timeGraph(graph: TimeGraph, adjustmentsForMilestoneAt indexPath: IndexPath) -> [AdjustmentProtocol] {
        guard let selectedGroup = dataModel()?.selectedGroup else {return [AdjustmentProtocol]()}
        guard let adjustments = selectedGroup.milestoneAt(indexPath: indexPath)?.adjustments?.array as? [Adjustment] else {return [AdjustmentProtocol]()}
        
        var returnAdjustments = [AdjustmentProtocol]()
        
        if let ms = dataModel()?.selectedGroup?.milestoneAt(indexPath: indexPath) {
            if (ms.showAdjustments?.boolValue ?? false) {
                for anAdjustment in adjustments {
                    let newAdjustment = AdjustmentInfo(anAdjustment)
                    returnAdjustments.append(newAdjustment)
                }
            }
        }
        return returnAdjustments
    }
    
    //TimeGraphDelegate
    func timeGraphNumberOfTimelines(graph: TimeGraph) -> Int {
        let count = dataModel()?.selectedGroup?.timelines?.array.count ?? 0
        return count
    }
    
    func timeGraph(graph: TimeGraph, numberOfMilestonesForTimelineAt index: Int) -> Int {
        guard let timelineArray = dataModel()?.selectedGroup?.timelines?.array as? [Timeline] else {return 0}
        return timelineArray[index].milestonesOrderedByDate()?.count ?? 0
    }
    
    func timeGraphStartDate(graph: TimeGraph) -> Date {
        return pageModel?.startDate ?? Date()
    }
    
    func timeGraph(graph: TimeGraph, didSelectMilestoneAt indexPath: IndexPath) {
        guard let selectedGroup = dataModel()?.selectedGroup else {return}

        var selectedTimeline: Timeline?
        if indexPath.count > 1 {
            selectedTimeline = selectedGroup.timelines?.array[indexPath[0]] as? Timeline
        }

        if let milestone = selectedGroup.milestoneAt(indexPath: indexPath) {
            dataModel()?.selectedMilestone = milestone
            dataModel()?.markedDate = milestone.date
            dataModel()?.markedTimeline = selectedTimeline
            timelinesAndGraphicsView?.selectMilestoneAt(indexPath: indexPath)
        }
    }
    
    func timeGraph(graph: TimeGraph, didSelectDate date: Date, inTimelineAtIndex index: Int) {
        guard let timeline = dataModel()?.selectedGroup?.timelines?.array[index] as? Timeline else {return}
        dataModel()?.markedDate = date
        dataModel()?.markedTimeline = timeline
        
    }
}

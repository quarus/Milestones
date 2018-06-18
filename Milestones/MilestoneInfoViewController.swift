//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MilestoneInfoViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class MilestoneInfoViewController:
    NSViewController,
    NSTextFieldDelegate,
    NSTextViewDelegate,
    StateObserverProtocol
{
    
    @IBOutlet weak var cwEntry: NSTextField?
    @IBOutlet weak var titleEntry: NSTextField?
    @IBOutlet weak var descriptionEntry: NSTextView?
    @IBOutlet weak var timeIntervalLabel: NSTextField?

    @IBOutlet weak var graphicDatePicker: NSDatePicker?
    @IBOutlet weak var cwDatePicker: NSDatePicker?
    @IBOutlet weak var regularDatePicker: NSDatePicker?
    
    @IBOutlet weak var adjustmentButton: NSButton?
    @IBOutlet weak var showAdjustmentsCheckBox: NSButton?
    @IBOutlet weak var timelinePopUpButton: NSPopUpButton?
    
    @IBOutlet weak var cwDateFormatter: DateFormatter!
    
    @objc var currentDate :Date = Date() {
        willSet {
            if newValue != currentDate {
                dataModel()?.selectedMilestone?.date = newValue
                cwEntry?.stringValue = cwDateFormatter.string(from: newValue)
                updateTimeIntervalSinceTodayLabel()
                updateAdjustmentButtons()
            }
        }
    }
    
    var datePickerPopOver : NSPopover?
    var timelines :[Timeline] = [Timeline]()
    
    override var representedObject: Any? {
        willSet {
            dataModel()?.remove(dataObserver: self)
        }
        didSet {
            dataModel()?.add(dataObserver: self)
        }
    }
    
    private func dataModel() -> StateProtocol? {
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        let dependencies = representedObject as? AnyObject as? Dependencies
        return dependencies?.stateModel
    }

    func fetchTimelines() -> [Timeline] {
        guard let moc = dataModel()?.managedObjectContext else { return [Timeline]() }
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let fetchRequest: NSFetchRequest<Timeline> = Timeline.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var fetchResult :[Timeline]?
        do {
            fetchResult = try moc.fetch(fetchRequest)
            return fetchResult!
        } catch {
        }
       
        return [Timeline]()
    }
    
    func timelinePopUpValue() -> Timeline? {
        guard let indexOfSelectedIndex = timelinePopUpButton?.indexOfSelectedItem else {return nil}
        if (indexOfSelectedIndex > -1) && (timelines.count > 0) {
            return timelines[indexOfSelectedIndex]
        }
        return nil
    }
    
    private func updateTimeIntervalSinceTodayLabel() {
        guard let milestoneDate = dataModel()?.selectedMilestone?.date else {return}
        guard let today = Date().normalized() else {return}
        
        let deltaComponents = Calendar.defaultCalendar().dateComponents([.year, .month, .weekOfYear,.day], from: today, to: milestoneDate)
        
        var usePastTense: Bool = true
        if today < milestoneDate {
            usePastTense = false
        }
        
        let days = deltaComponents.day ?? 0
        let weeks = deltaComponents.weekOfYear ?? 0
        let months = deltaComponents.month ?? 0
        let years = deltaComponents.year ?? 0

        var deltaString: String = ""
        if days == 0 && weeks == 0 && months == 0 && years == 0 {
            deltaString = "Heute"
        } else {
            if usePastTense {
                deltaString += "Vor "
            } else {
                deltaString += "In "
            }
            
            if years != 0 {
                deltaString += "\(abs(years)) Jahre "
            }
            
            if months != 0 {
                deltaString += "\(abs(months)) Monate "
            }
            
            if weeks != 0 {
                deltaString += "\(abs(weeks)) Wochen "
            }
            
            if (days != 0) {
                deltaString += "\(abs(days)) Tage "
            }
        }
        timeIntervalLabel?.stringValue = deltaString
    }
    
    private func updateAdjustmentButtons() {
        guard let milestone = dataModel()?.selectedMilestone else {return}
        guard let milestoneDate = milestone.date else {return}
        guard let adjustments = dataModel()?.selectedMilestone?.adjustments else {return}
        
        //1. Setup the button to add adjustments
        
        //No existing adjustments? The user may add an adjustemnt without checks
        if adjustments.count == 0 {
            adjustmentButton?.isEnabled = true
        } else {
            
            //Only enable the "Mark as adjustment" button when there is actually a change
            if let lastAdjustment = (adjustments.lastObject as? Adjustment)?.date {
                if milestoneDate == lastAdjustment {
                    adjustmentButton?.isEnabled = false
                } else {
                    adjustmentButton?.isEnabled = true
                }
            }
        }
        
        //2. Setup the checkbox, which indicates wether to draw adjustemnts or not
        if let showAdjustments = milestone.showAdjustments?.boolValue {
            if showAdjustments {
                showAdjustmentsCheckBox?.state = NSControl.StateValue.on
            } else {
                showAdjustmentsCheckBox?.state = NSControl.StateValue.off
            }
        }
    }
    
    private func setupTimelinePopUpButtonFor(timeline :Timeline?) {
        //Remove all current entries
        timelinePopUpButton?.removeAllItems()
        
        //figure out the first active (selected) timeline
        let activeTimeline = timeline
        var indexOfPreselectedTimeline = 0
        
        //populate the timeline PopUpButton
        let numberOfTimelines = timelines.count
        for index in 0..<numberOfTimelines {
            
            let timeline = timelines[index]
            
            //Add an entry
            let timelineName = timeline.name ?? "Unkown"
            let newMenuItem = NSMenuItem(title: timelineName, action: nil, keyEquivalent: "")
            timelinePopUpButton?.menu?.addItem( newMenuItem)
            
            //Check if this timeline is the active one
            if timeline == activeTimeline {
                indexOfPreselectedTimeline = index
            }
        }
 
        //preselect the active timeline
        timelinePopUpButton?.selectItem(at: indexOfPreselectedTimeline)
    }
    
    func update() {
        timelines = fetchTimelines()
        
        if let timeline = dataModel()?.selectedMilestone?.timeline {
            setupTimelinePopUpButtonFor(timeline: timeline)
        }
        
        if let milestoneName = dataModel()?.selectedMilestone?.name {
            titleEntry?.stringValue = milestoneName
        }
        
        if let milestoneDescription = dataModel()?.selectedMilestone?.info {
            descriptionEntry?.string = milestoneDescription
            descriptionEntry?.checkTextInDocument(nil)
        }
        
        if let milestoneDate = dataModel()?.selectedMilestone?.date {
            
            //Update the date display
            graphicDatePicker?.dateValue = milestoneDate
            regularDatePicker?.dateValue = milestoneDate
            cwEntry?.stringValue = cwDateFormatter.string(from: milestoneDate)
            
        }
        
        updateAdjustmentButtons()
        updateTimeIntervalSinceTodayLabel()
    }
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        cwDateFormatter.calendar = Calendar.defaultCalendar()
        cwDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    }
    
    override func viewWillAppear() {
        update()
    }

    //MARK: UI Callbacks & more
    
    @IBAction func onShowAdjustmentCheck(_ sender: Any) {
        guard let milestone = dataModel()?.selectedMilestone else {return}
        
        switch showAdjustmentsCheckBox?.state {
        case NSControl.StateValue.on:
            milestone.showAdjustments = true
            break
        case NSControl.StateValue.off:
            milestone.showAdjustments = false
            break
        default:
            break
        }
    }
    
    @IBAction func onTimelineChange(_ sender: Any) {
        if let selectedTimeline = timelinePopUpValue() {
            dataModel()?.selectedMilestone?.timeline = selectedTimeline
        }
    }
    
  
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let segueID = segue.identifier?.rawValue else { return }
        guard let  destinationViewController = segue.destinationController as? AddAdjustmentViewController  else { return }

        switch segueID {
        case "AdjustmentViewController":
            destinationViewController.representedObject = dataModel()
            break
        default:
            break
        }
    }

    private func hideDatePicker() {
        datePickerPopOver?.performClose(self)
    }
    
    //DataObserverProtocol
    func didChangeSelectedGroup(_ group :Group?) {
        
    }
    
    func didChangeSelectedTimeline(_ selectedTimelines :[Timeline]) {
        
    }
    
    func didChangeSelectedMilestone(_ milestone :Milestone?) {
        update()
    }
    
    //MARK: NSTextFieldDelegate
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        return true
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        //Prevent the user from entering an empty name for a milestone
        if control == titleEntry {
            if titleEntry?.stringValue.count == 0 {
                return false
            }
            dataModel()?.selectedMilestone?.name = titleEntry?.stringValue
        } else if control == cwEntry {
            if let date =  cwDateFormatter.date(from: cwEntry?.stringValue ?? "") {
                if let enteredDate = date.normalized() {
                    self.setValue(enteredDate, forKey: "currentDate")
                }
            }
        }
        return true
    }
    
    //MARK: NSTextDelegate (used for NSTextView)
    func textShouldEndEditing(_ textObject: NSText) -> Bool {
        dataModel()?.selectedMilestone?.info = descriptionEntry?.string
        return true
    }
}

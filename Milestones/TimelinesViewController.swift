//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  TimelinesViewController.swift
//  Milestones
//
//  Copyright © 2016 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class TimelinesViewController :NSViewController, NSTableViewDataSource, NSTableViewDelegate, StateObserverProtocol, CoreDataNotificationManagerDelegate {

    let TIMELINE_DRAG_TYPE :String = "TIMELINE.ROW"

    @IBOutlet private weak var timelineTableView: NSTableView!
    @IBOutlet private weak var addTimelineButton: NSButton!
    @IBOutlet private weak var removeTimelineButton: NSButton!

    private var hasNotificationObserving = false
    private var MOCHandler = CoreDataNotificationManager()
    
    override var representedObject: Any? {
        
        willSet {
            dataModel()?.remove(dataObserver: self)
        }
        
        didSet {

            MOCHandler.deregisterForMOCNotifications()
            MOCHandler.registerForNotificationsOn(moc: dataModel()?.managedObjectContext)
            MOCHandler.delegate = self
            
            timelineTableView.reloadData()
            dataModel()?.add(dataObserver: self)
            
        }
    }
    
    //MARK: Helper Functions
    
    private func dataModel() -> StateProtocol? {
        
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        let dependencies = representedObject as? AnyObject as? Dependencies
        return dependencies?.stateModel
        
    }

    

    private func timelineAt(index :Int) -> Timeline? {
        
        guard let timelines = dataModel()?.selectedGroup?.timelines else {return nil}
        guard 0..<timelines.count ~= index else {return nil}
        
        return timelines.object(at: index) as? Timeline
        
    }
    
    private func indexOf(timeline :Timeline) -> Int {
        guard let timelines = dataModel()?.selectedGroup?.timelines else {return NSNotFound}
         
        return timelines.index(of: timeline)
    }
    
    private func configureCell(tableViewCell :NSTableCellView, atRow row :Int) {
        
        guard let timeline = timelineAt(index: row) else {return}
        guard let timelineTableCellView = tableViewCell as? TimelineTableCellView else {return}

        timelineTableCellView.nameTextField.stringValue = timeline.name ?? ""
        timelineTableCellView.colorView.backgroundColor = timeline.color ?? NSColor.white
        timelineTableCellView.colorView.setNeedsDisplay(timelineTableCellView.colorView.bounds)
    }

    deinit {
        MOCHandler.deregisterForMOCNotifications()
    }
    
    //MARK: View life cycle
    override func viewDidAppear() {
        
        timelineTableView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: TIMELINE_DRAG_TYPE)])
        updateButtons()

        MOCHandler.registerForNotificationsOn(moc: dataModel()?.managedObjectContext)
        MOCHandler.delegate = self
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        guard let segueID = segue.identifier?.rawValue else { return }
        guard let  destinationViewController = segue.destinationController as? TimelineViewController  else { return }
        
        let timelineModel = TimelineModel()
        timelineModel.moc = dataModel()?.managedObjectContext
        destinationViewController.representedObject = timelineModel

        switch segueID {
        case "AddTimelineSegue":
            
            timelineModel.activeGroup = dataModel()?.selectedGroup
            
        case "EditTimelineSegue":
            
            guard let selectedTimelines = dataModel()?.selectedTimelines else {return}

            if selectedTimelines.count > 0 {
                
                timelineModel.timeline = selectedTimelines[0]
            }
            
        default:
            break
        }
    }
    
    
    //MARK: UI Callbacks & more

    private func updateButtons() {
        
        if (dataModel()?.selectedGroup == nil) {
            addTimelineButton.isEnabled = false

        } else {
            addTimelineButton.isEnabled = true
        }
        
        let numberOfSelectedTimelines = dataModel()?.selectedTimelines.count ?? 0

        switch numberOfSelectedTimelines {
        case 1:
            removeTimelineButton.isEnabled = true
        default:
            removeTimelineButton.isEnabled = false
            
        }
    }
    
    private func dialogDeleteYesOrNo() -> Bool {
        
        
        let newAlert = NSAlert()
        newAlert.messageText = "Timeline entfernen?"
        newAlert.informativeText = "Die Timeline wird von der Gruppe entfernt."
        newAlert.alertStyle = .warning
        newAlert.addButton(withTitle: "Entfernen")
        newAlert.addButton(withTitle: "Abbrechen")
                
        return newAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
        
    @IBAction func onEnterInTimelineTextField(_ sender: NSTextField) {
        
        let rowNumber = timelineTableView.selectedRow
        guard let timeline = dataModel()?.selectedGroup?.timelines?[rowNumber] as? Timeline else {return}

        timeline.name = sender.stringValue
    }

    @IBAction func onClickOfAddTimeLineButton(_ sender: NSButton) {
  
        guard let moc = dataModel()?.managedObjectContext else {return}
        
        if let activeGroup = dataModel()?.selectedGroup {
            let newTimeline = NSEntityDescription.insertNewObject(forEntityName: "Timeline", into: moc) as! Timeline
            newTimeline.name = "Neue Timeline"
            newTimeline.addGroup(aGroup: activeGroup)
            moc.processPendingChanges()
            dataModel()?.selectedTimelines = [newTimeline]
        }
    }

    @IBAction func onClickOfRemoveTimeLineButton(_ sender: NSButton) {

        guard let selectedTimelines = dataModel()?.selectedTimelines else {return}
        if selectedTimelines.count <= 0 {
            return
        }
        
        guard let selectedTimeline = dataModel()?.selectedTimelines [0] else {return}

        let doDelete = dialogDeleteYesOrNo()
        if doDelete {

            dataModel()?.selectedGroup?.removeTimeline(aTimeline: selectedTimeline)
        }
    }

    //MARK: TableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        var timelines = [Timeline]()
        let indeces = timelineTableView.selectedRowIndexes
        
        for anIndex in indeces {

            if let selectedTimeline  = timelineAt(index: anIndex) {
                
                timelines.append(selectedTimeline)
            }
        }

        dataModel()?.selectedTimelines = timelines
        updateButtons()
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        return 50
    }

    //MARK: TableView DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {

        guard let numberOfRows = dataModel()?.selectedGroup?.timelines?.count else {return 0}
        return numberOfRows
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var configuredView: NSView?
        
        if let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TimelineRow"), owner: self) as? NSTableCellView {
            configureCell(tableViewCell: view, atRow: row)
            configuredView = view
        }
        
        return configuredView
    }
    
    //MARK: Timeline Dragging
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: NSPasteboard.PasteboardType(rawValue: TIMELINE_DRAG_TYPE))
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        tableView.setDropRow(row, dropOperation: NSTableView.DropOperation.above)
        return NSDragOperation.move
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        guard let activeGroup = dataModel()?.selectedGroup else { return false }
        guard let timelines = activeGroup.timelines else { return false }
        
        var movedObjectsIndexes = IndexSet()
        
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:], using: {
            (draggingItem :NSDraggingItem, index :Int, stop :UnsafeMutablePointer<ObjCBool>) in
            
            if let pasteboardItem = draggingItem.item as? NSPasteboardItem, let rowAsString = pasteboardItem.string(forType: NSPasteboard.PasteboardType(rawValue: self.TIMELINE_DRAG_TYPE)){
                
                if let sourceRowNumber = Int(rowAsString){
                    
                    movedObjectsIndexes.insert(sourceRowNumber)
                }
            }
        })
        
        let indexSet = timelineTableView.selectedRowIndexes
        var numberOfObjectsToMoveBeforeTargetRow = 0
        
        for index in indexSet {
            if (index < row){
                numberOfObjectsToMoveBeforeTargetRow += 1
            }
        }
        
        
        //The index of where the moved objects are to be inserted needs to be corrected due to the way
        //moveObjects(at: --- as IndexSet, to: ---) works
        let targetIndex = row - numberOfObjectsToMoveBeforeTargetRow
        
        //This seems to be a a safer way to change a Core Data relationship
        let newTimelineOrder = NSMutableOrderedSet(orderedSet: timelines)
        newTimelineOrder.moveObjects(at: movedObjectsIndexes as IndexSet, to: targetIndex)
        activeGroup.timelines = newTimelineOrder
        
        self.timelineTableView.reloadData()
        
        return true
    }

    //MARK: DataObserverProtocol
    func didChangeSelectedGroup(_ group: Group?) {
        timelineTableView.reloadData()
        updateButtons()
        
    }
    
    func didChangeSelectedTimeline(_ selectedTimelines: [Timeline]) {

        if selectedTimelines.count == 1 {
            let timeline = selectedTimelines[0]
            if let index = dataModel()?.selectedGroup?.timelines?.index(of: timeline) {
                if index != NSNotFound {
                    timelineTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                }
            }
        }
    }
    
    func didChangeSelectedMilestone(_ milestone: Milestone?){

    }

    //MARK: CoreDataNotificationDelegate
    func handleInsertion(ofObjects: NSSet) {
        for anObject in ofObjects{
            
            if (anObject is Timeline) {
                timelineTableView.reloadData()
                updateButtons()
            }
        }
    }
    
    func handleUpdate(ofObjects: NSSet) {
        for anObject in ofObjects {
            
            if (anObject is Timeline) {
                
                if let timeline = anObject as? Timeline {
                    let indexOfTimeline = indexOf(timeline: timeline)
                    if indexOfTimeline ==  NSNotFound{
                        
                        timelineTableView.reloadData()
                    } else {
                        
                        timelineTableView.reloadData(forRowIndexes: IndexSet(integer: indexOfTimeline),
                                                     columnIndexes: IndexSet(integer: 0))
                    }
                }
                updateButtons()
                
            } else if (anObject is Group) {
                
                timelineTableView.reloadData()
                /*
                 //A change in a group might be a simple rename or a change of timelines
                 //This is (too) simple way, to ensure that for e.g. no Milestone is displayed for a just removed timeline
                 
                 //ToDo: Improve this
                 dataModel()?.selectedTimelines = [CTimeline]()
                 timelineTableView.reloadData()
                 */
                
            }
        }
    }
    
    func handleRemoval(ofObjects: NSSet) {
        for anObject in ofObjects {
            
            if let _ = anObject as? Timeline {
                timelineTableView.reloadData()
                updateButtons()
            }
        }
    }
}

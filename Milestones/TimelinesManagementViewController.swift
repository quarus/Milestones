//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  TimelineManagementViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class TimelinesManagementViewController :NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var timelineTableView :NSTableView!
    @IBOutlet weak var addTimelineButton: NSButton!
    @IBOutlet weak var removeTimelineButton: NSButton!
    @IBOutlet weak var editTimelineButton: NSButton!

    private var frc :NSFetchedResultsController<Timeline>?
    private var hasKVO = false

    deinit {

        deregisterKVO()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {

        guard let segueID = segue.identifier?.rawValue else { return }
        guard let  destinationViewController = segue.destinationController as? TimelineViewController  else { return }

        let timelineModel = TimelineModel()
        timelineModel.moc = dataModel()?.managedObjectContext
        destinationViewController.representedObject = timelineModel

        switch segueID {
        case "AddTimelineSegue":
            break
        case "EditTimelineSegue":

            guard let selectedTimeline = fetchedResultsController()?.fetchedObjects?[timelineTableView.selectedRow] else {return}

            timelineModel.timeline = selectedTimeline

        default:
            break
        }

    }

    //MARK: Helper functions
    
    private func configure(view: NSView, inColumn column :String, onRow row :Int) {
        
        guard let timeline = fetchedResultsController()?.fetchedObjects?[row] else {return}
        
        switch column {
            
        case "Color_Column":
            
            guard let timelineColor = timeline.color else {return}
            guard let colorWell = view as? NSColorWell else {return}
            
            colorWell.color = timelineColor
            
            
        case "Member_Column":

            guard let button = view as? NSButton else {return}
            guard let selectedGroup = dataModel()?.selectedGroup else {
                //Disable member selection button if there is no group selected
                button.state = NSControl.StateValue(rawValue: 0)
                button.isEnabled = false
                return

            }
            guard let timelinesOfSelectedGroup = selectedGroup.timelines else {return}

            var isMember = 0
            if timelinesOfSelectedGroup.contains(timeline) {
                
                isMember = 1
            
            } else {
            
                isMember = 0
            
            }
            button.isEnabled = true
            button.state = NSControl.StateValue(rawValue: isMember)

            
        case "Name_Column":

            guard let name = timeline.name else {return}
            guard let cellView = view as? NSTableCellView else {return}
            
            cellView.textField?.stringValue = name
            
            
        case "Orphan_Column":
            
            guard let cellView = view as? NSTableCellView else {return}
            
            var text = " "
            if timeline.groups?.count == 0 {
                
                text = "(Keine Gruppe)"
            }
            cellView.textField?.stringValue = text

        default:
            break
            
        }
    }

    func configureTableRowView(atIndex index :Int) {

        guard let rowView = timelineTableView.rowView(atRow: index, makeIfNecessary: false)  else {return}

        if let cellView = rowView.view(atColumn: 0) as? NSView {
            configure(view: cellView, inColumn: "Color_Column", onRow: index)
        }

        if let cellView = rowView.view(atColumn: 1) as? NSView {
            configure(view: cellView, inColumn: "Member_Column", onRow: index)
        }

        if let cellView = rowView.view(atColumn: 2) as? NSView {
            configure(view: cellView, inColumn: "Name_Column", onRow: index)
        }

        if let cellView = rowView.view(atColumn: 3) as? NSView {
            configure(view: cellView, inColumn: "Orphan_Column", onRow: index)
        }

    }

    private func dataModel() -> GroupsManagementModel? {
        
        return representedObject as? GroupsManagementModel
    }

    
    private func fetchedResultsController() -> NSFetchedResultsController<Timeline>? {
        
        guard let moc = dataModel()?.managedObjectContext else {return nil}

        if frc == nil {

            let fetchRequest = NSFetchRequest<Timeline>(entityName: "Timeline")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                       managedObjectContext: moc,
                                                       sectionNameKeyPath: nil,
                                                       cacheName: nil)


            frc?.delegate = self
        }
        
        return frc
        
    }


    //MARK: View life cycle 
    override func viewDidAppear() {

        if dataModel()?.selectedGroup == nil {
            
        }

        try? fetchedResultsController()?.performFetch()
        timelineTableView.reloadData()
        registerKVO()

        timelineTableView.target = self
        timelineTableView.doubleAction = #selector(TimelinesManagementViewController.onDoubleClickOfRow)

    }

    //MARK: KVO Handling
    func registerKVO() {

        if !hasKVO {

            hasKVO = true

            let KVOOptions = NSKeyValueObservingOptions([.new, .old])
            dataModel()?.addObserver(self,
                               forKeyPath: "selectedGroup",
                               options: KVOOptions,
                               context: nil)

        }
    }

    func deregisterKVO() {

        if hasKVO {

            hasKVO = false

            dataModel()?.removeObserver(self, forKeyPath: "selectedGroup")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

            if keyPath == "selectedGroup" {

                timelineTableView.reloadData()
            }
    }


    //MARK: UI Callbacks & more
    @objc public func onDoubleClickOfRow(_sender :AnyObject?) {
        if timelineTableView.selectedRow != -1 {
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "EditTimelineSegue"), sender: self)
        }
    }

    private func updateButtons() {
        
        if timelineTableView.selectedRow == -1 {
            editTimelineButton.isEnabled = false
            removeTimelineButton.isEnabled = false
        } else {

            editTimelineButton.isEnabled = true
            removeTimelineButton.isEnabled = true
        }
        
    }
    
    private func dialogDeleteYesOrNo() -> Bool {

        let newAlert = NSAlert()
        newAlert.messageText = "Timeline entfernen?"
        newAlert.informativeText = "Die Time wird gelöscht!"
        newAlert.alertStyle = .warning
        newAlert.addButton(withTitle: "Entfernen")
        newAlert.addButton(withTitle: "Abbrechen")

        return newAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }

    @IBAction func onRemoveTimelineButtonClicked(_ sender: Any) {

        let indexOfCurrentlySelectedTimeline = timelineTableView.selectedRow
        guard indexOfCurrentlySelectedTimeline >= 0 else {return}


        let doDelete = dialogDeleteYesOrNo()

        if doDelete {

            if indexOfCurrentlySelectedTimeline >= 0 {

                if let timelineToDelete = fetchedResultsController()?.fetchedObjects?[indexOfCurrentlySelectedTimeline] {

                    dataModel()?.managedObjectContext?.delete(timelineToDelete)
                    dataModel()?.managedObjectContext?.processPendingChanges()
                    updateButtons()
                    
                }
            }
        }
    }

    @IBAction func onClickOfGroupMembershipButton(_ sender: NSButton) {

        let rowNumber = timelineTableView.row(for: sender)
        guard let currentlySelectedGroup = dataModel()?.selectedGroup else { return }
        guard let currentlySelectedTimeline = fetchedResultsController()?.fetchedObjects?[rowNumber] else { return }

        if (sender.state.rawValue == 0) {

            currentlySelectedGroup.removeTimeline(aTimeline: currentlySelectedTimeline)

        } else {

            currentlySelectedGroup.addTimeline(aTimeline: currentlySelectedTimeline)
        }

        timelineTableView.reloadData(forRowIndexes: IndexSet(integer: rowNumber), columnIndexes: IndexSet([0,1,2,3]))
    }

    //MARK: TableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
    
        let rowNumber = timelineTableView.selectedRow
        if rowNumber >= 0 {
            if let currentlySelectedTimeline = fetchedResultsController()?.fetchedObjects?[rowNumber] {
                dataModel()?.selectedTimeline = currentlySelectedTimeline
            }
        } else {
            dataModel()?.selectedTimeline = nil
        }
        updateButtons()
    }

    //MARK: TableView DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {

        let numberOfRows = fetchedResultsController()?.fetchedObjects?.count ?? 0
        return numberOfRows
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let timelines = fetchedResultsController()?.fetchedObjects else { return nil }
        guard timelines.count > 0 else { return nil }
        guard let tableColumnIdentifier = tableColumn?.identifier.rawValue  else {return nil}

        var view :NSView?
        
        switch tableColumnIdentifier {

        case "Color_Column":

            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Color_Column"), owner: self) as? NSColorWell
        
        case "Member_Column":

            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MemberCell"), owner: self) as? NSButton

        case "Name_Column":

            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView

        case "Orphan_Column":

            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "OrphanCell"), owner: self) as? NSTableCellView

        default:
            return nil
        }
        
        if view != nil{
            configure(view: view!, inColumn: tableColumnIdentifier, onRow: row)
        }

        return view
    }
    
    //MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timelineTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:

//          indexPath / newIndexPath contains two entries. The first one for the the section the second for row
//          ToDo: Check why newIndexPath?.row is unknown

            guard let row = newIndexPath?.last else {return}
            timelineTableView.insertRows(at: IndexSet(integer: row), withAnimation: NSTableView.AnimationOptions.effectFade)

        case .delete:
            
            guard let row = indexPath?.last else {return}
            timelineTableView.removeRows(at: IndexSet(integer: row), withAnimation: NSTableView.AnimationOptions.effectFade)
            
        case .update:
            
            guard let row = newIndexPath?.last else {return}
            configureTableRowView(atIndex: row)

        case .move:

            guard let oldRow = indexPath?.last else {return}
            guard let newRow = newIndexPath?.last else {return}

            timelineTableView.moveRow(at: oldRow, to: newRow)
            configureTableRowView(atIndex: newRow)

            break

        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timelineTableView.endUpdates()
    }
    

}

//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MilestonesViewController.swift
//  Milestones
//
//  Copyright © 2016 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class MilestonesViewController :
    NSViewController,
    NSTableViewDataSource,
    NSTableViewDelegate,
    NSFetchedResultsControllerDelegate,
    StateObserverProtocol
{
    @IBOutlet private weak var milestonesTableView: NSTableView!
    @IBOutlet private weak var addMilestoneButton: NSButton!
    @IBOutlet private weak var removeMilestoneButton: NSButton!

    private var hasNotificationObserving = false
    private var calendarWeekDateFormatter :DateFormatter = DateFormatter()
    private var dateFormatter :DateFormatter = DateFormatter()

    private var frc :NSFetchedResultsController<Milestone>?


    override var representedObject: Any? {
        
        willSet {
            dataModel()?.remove(dataObserver: self)
        }
        
        didSet {
            milestonesTableView.reloadData()
            dataModel()?.add(dataObserver: self)
            
        }
    }
    
    private func dataModel() -> StateProtocol? {
        
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        let dependencies = representedObject as? AnyObject as? Dependencies
        return dependencies?.stateModel
    }

    deinit {
        dataModel()?.remove(dataObserver: self)
    }
    
    //MARK: Helper functions
    var fetchRequest = NSFetchRequest<Milestone>(entityName: "Milestone")
    
    private func fetchedResultsController() -> NSFetchedResultsController<Milestone>? {
       
        guard let moc = dataModel()?.managedObjectContext else {return nil}
        guard let selectedTimelines = dataModel()?.selectedTimelines else {return nil}
        
        if frc == nil {
            
            let fetchPredicate = NSPredicate(format: "timeline IN %@",  selectedTimelines)
            fetchRequest.predicate = fetchPredicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
                
                frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                 managedObjectContext: moc,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
            
                frc?.delegate = self
        }

        return frc
        
    }
    
    private func milestoneCellModelFor(row: Int) -> MilestoneTableCellModel? {
        guard let fetchedObjects = fetchedResultsController()?.fetchedObjects else {return nil}
        
        let milestone = fetchedObjects[row]
        var nextMilestone :Milestone?
        if (row + 1) < fetchedObjects.count {
            nextMilestone = fetchedObjects[row + 1]
        }
        
        let milestoneCellModel = MilestoneTableCellModel(milestone: milestone,
                                                    nextMilestone: nextMilestone)        
        return milestoneCellModel
    }
    
    func configureCell(tableViewCell: NSTableCellView, forMilestoneCellModel model: MilestoneTableCellModel) {
        guard let milestoneTableCellView = tableViewCell as? MilestoneTableCellView else {return}
        milestoneTableCellView.configureUsing(dataSource: model)
    }
    
    //MARK: View Lifecycle
    override func viewDidAppear() {

        calendarWeekDateFormatter.dateFormat = "w.e/yyyy"
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        updateButtons()

    }

    //MARK: UI Callbacks & more
    func updateButtons() {
        
        if dataModel()?.selectedGroup == nil {
            addMilestoneButton.isEnabled = false
        } else {
            addMilestoneButton.isEnabled = true
        }
        
        let numberOfSelectedTimelines = dataModel()?.selectedTimelines.count
        if numberOfSelectedTimelines == 1 {
            addMilestoneButton.isEnabled = true
        } else {
            addMilestoneButton.isEnabled = false
        }
        
        let numberOfMilestones = fetchedResultsController()?.fetchedObjects?.count ?? 0
        if numberOfMilestones == 0 {
            
            removeMilestoneButton.isEnabled = false
        } else {
            
            if milestonesTableView.selectedRow != -1 {
                
                removeMilestoneButton.isEnabled = true
                
            } else {
                
                removeMilestoneButton.isEnabled = false
            }
        }
    }
    
    private func dialogDeleteYesOrNo() -> Bool {
        
        let newAlert = NSAlert()
        newAlert.messageText = "Meilenstein löschen?"
        newAlert.informativeText = "Der Meilenstein wird von der Timeline entfernt."
        newAlert.alertStyle = .warning
        newAlert.addButton(withTitle: "Löschen")
        newAlert.addButton(withTitle: "Abbrechen")
        
        return newAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    private func createNewMilestone() -> Milestone?{

        guard let moc = dataModel()?.managedObjectContext else {return nil}
        guard let selectedTimelines = dataModel()?.selectedTimelines else {return nil}

        var newMilestone: Milestone?
        
        if (selectedTimelines.count > 0) {
            newMilestone = (NSEntityDescription.insertNewObject(forEntityName: "Milestone", into: moc) as! Milestone)
            newMilestone?.name = "Neuer Meilenstein"
            
            let newAdjustment = newMilestone?.markAdjustment()
            newAdjustment?.name = "Init"
            newAdjustment?.reason = "Meilenstein wurde erstellt"
            
            let timeline = dataModel()?.selectedTimelines[0]
            newMilestone?.timeline = timeline
            moc.processPendingChanges()
            dataModel()?.selectedMilestone = newMilestone
        }
        
        return newMilestone
    }
    
    @IBAction func onClickOfAddButton(_ sender: Any) {
        
      let _ = createNewMilestone()
    }
    
    @IBAction func onClickOfRemoveButton(_ sender: Any) {
        
        guard let moc = dataModel()?.managedObjectContext else {return}
        
        let doDelete = dialogDeleteYesOrNo()
        if doDelete {
            
            if let milestoneToDelete = dataModel()?.selectedMilestone {
            
                moc.delete(milestoneToDelete)

            }
        }
    }

    //MARK: TableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {

        var selectedMilestone :Milestone? = nil

        if milestonesTableView.selectedRow != -1 {
            
            if let milestone = fetchedResultsController()?.fetchedObjects?[milestonesTableView.selectedRow] {
                selectedMilestone = milestone
            }
            
            dataModel()?.selectedMilestone = selectedMilestone
        }

        updateButtons()
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        guard let milestoneCellModel = milestoneCellModelFor(row: row) else {return 0.0}
        
        if milestoneCellModel.needsExpandedCell {
            return 105
        }
        return 40
    }

    //MARK: TableView DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {

        let count = fetchedResultsController()?.fetchedObjects?.count ?? 0
        return count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let milestoneCellModel = milestoneCellModelFor(row: row) else {return nil}
        
        var view :NSTableCellView?
        
        if (milestoneCellModel.needsExpandedCell) {
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MilestoneRow-Expanded"), owner: self) as? NSTableCellView
        } else {
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MilestoneRow"), owner: self) as? NSTableCellView
        }
        
        if view != nil {
            configureCell(tableViewCell: view!, forMilestoneCellModel: milestoneCellModel)
        }
        
        return view
    }

    //MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            
            guard let row = newIndexPath?.last else {return}
            milestonesTableView.insertRows(at: IndexSet(integer: row), withAnimation: NSTableView.AnimationOptions.effectFade)
            
        case .delete:
            
            guard let row = indexPath?.last else {return}
            milestonesTableView.removeRows(at: IndexSet(integer: row), withAnimation: NSTableView.AnimationOptions.effectFade)
        
        case .update:
            
            guard let row = newIndexPath?.last else {return}
            
            //FIXME: Order of these rows seem to matter!
            let relevantRowsIndices = IndexSet([row, row - 1, row + 1])
            
            milestonesTableView.reloadData(forRowIndexes: IndexSet(relevantRowsIndices), columnIndexes: IndexSet([0]))
            milestonesTableView.noteHeightOfRows(withIndexesChanged: IndexSet(relevantRowsIndices))
        
        case .move:

            guard let oldRow = indexPath?.last else {return}
            guard let newRow = newIndexPath?.last else {return}

            //FIXME: Order of these rows seem to matter!
            let relevantRowsIndices = IndexSet([newRow, newRow - 1, newRow + 1])
            milestonesTableView.moveRow(at: oldRow, to: newRow)
            milestonesTableView.reloadData(forRowIndexes: relevantRowsIndices, columnIndexes: IndexSet([0]))
            milestonesTableView.noteHeightOfRows(withIndexesChanged: relevantRowsIndices)

            milestonesTableView.reloadData(forRowIndexes: relevantRowsIndices, columnIndexes: IndexSet([0]))
            milestonesTableView.noteHeightOfRows(withIndexesChanged: relevantRowsIndices)
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }

    //MARK: DataObserverProtocol    
    func didChangeZoomLevel(_ level: ZoomLevel) {}

    func didChangeSelectedGroup(_ group: Group?) {
        updateButtons()
    }
    
    func didChangeSelectedTimeline(_ selectedTimelines :[Timeline]) {
        
        do {
            if let frc = fetchedResultsController() {
                
                let fetchPredicate = NSPredicate(format: "timeline IN %@", selectedTimelines)
                fetchRequest.predicate = fetchPredicate
                
                try frc.performFetch()
            }
        } catch {
            
        }
        
        updateButtons()
        milestonesTableView.reloadData()
 
    }

    func didChangeSelectedMilestone(_ milestone: Milestone?) {

        guard let milestones = fetchedResultsController()?.fetchedObjects else {return}
        guard let milestone = milestone else {
            milestonesTableView.deselectAll(nil)
            return
        }

        if milestones.contains(milestone) {
            if let index = milestones.index(of: milestone) {
                milestonesTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                milestonesTableView.scrollRowToVisible(index)
                self.view.window?.makeKeyAndOrderFront(nil)
            }
        }
    }
}

//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  GroupsViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class GroupsViewController :NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet private weak var groupsTableView :NSTableView!

    private var frc :NSFetchedResultsController<Group>?

    @IBOutlet weak var addGroupButton: NSButton!
    @IBOutlet weak var removeGroupButton: NSButton!
    @IBOutlet weak var editGroupButton: NSButton!
    
    //MARK: Helper functions
    func configureCell(tableViewCell :NSTableCellView, atRow row :Int) {
        
        guard let group = fetchedResultsController()?.fetchedObjects?[row] else {return}
        
        if let groupName = group.name {
            
            tableViewCell.textField?.stringValue = groupName
        }
    }
    
    private func dataModel() -> GroupsManagementModel? {
        
        return representedObject as? GroupsManagementModel
    }

    private func fetchedResultsController() -> NSFetchedResultsController<Group>? {

        guard let moc = dataModel()?.managedObjectContext else {return nil}

        if frc == nil {
            
            let fetchRequest = NSFetchRequest<Group>(entityName: "Group")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: moc,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
            
            frc?.delegate = self
        }
        
        return frc
    }

    fileprivate func currentlySelectedGroup() -> Group? {

        let index = groupsTableView.selectedRow
        var selectedGroup :Group?
        if index >= 0 {
            selectedGroup = fetchedResultsController()?.fetchedObjects?[index]
        }

        return selectedGroup
    }
    
    deinit {
    }

    //MARK: View life cycle
    override func viewDidAppear() {

        try? fetchedResultsController()?.performFetch()
        groupsTableView.reloadData()
        updateButtons()

        groupsTableView.target = self
        groupsTableView.doubleAction = #selector(GroupsViewController.onDoubleClickOfRow)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        guard let segueID = segue.identifier else { return }
        guard let  destinationViewController = segue.destinationController as? GroupViewController  else { return }
        
        let groupModel = GroupViewControllerModel()
        groupModel.moc = dataModel()?.managedObjectContext
        destinationViewController.representedObject = groupModel
        
        switch segueID {
        case "AddGroupSegue":
            
            groupModel.group = nil
            
        case "EditGroupSegue":
            
            groupModel.group = currentlySelectedGroup()
            
        default:
            break
        }
    }

    //MARK: UI Callbacks & more
    @objc public func onDoubleClickOfRow(_sender :AnyObject?) {
        if groupsTableView.selectedRow != -1 {
            self.performSegue(withIdentifier: "EditGroupSegue", sender: self)
        }
    }

    private func updateButtons() {
        
        if currentlySelectedGroup() == nil {
            
            removeGroupButton.isEnabled = false
            editGroupButton.isEnabled = false
        
        } else {
            
            removeGroupButton.isEnabled = true
            editGroupButton.isEnabled = true
        }
    }
    
    private func dialogDeleteYesOrNo() -> Bool {
    
        let newAlert = NSAlert()
        newAlert.messageText = "Gruppe entfernen?"
        newAlert.informativeText = "Die Gruppe wird gelöscht!"
        newAlert.alertStyle = .warning
        newAlert.addButton(withTitle: "Entfernen")
        newAlert.addButton(withTitle: "Abbrechen")
        
        return newAlert.runModal() == NSAlertFirstButtonReturn
    }
    
    @IBAction func onClickOfRemoveGroupButton(_ sender: NSButton) {
        
        let indexOfCurrentlySelectedGroup = groupsTableView.selectedRow
        guard indexOfCurrentlySelectedGroup >= 0 else {return}
        
        
        let doDelete = dialogDeleteYesOrNo()
        
        if doDelete {
            
            if indexOfCurrentlySelectedGroup >= 0 {
                
                if let groupToDelete = fetchedResultsController()?.fetchedObjects?[indexOfCurrentlySelectedGroup] {
                    
                    dataModel()?.managedObjectContext?.delete(groupToDelete)
                    dataModel()?.managedObjectContext?.processPendingChanges()

                }
            }
        }
    }

    //MARK: TableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {

        dataModel()?.selectedGroup = currentlySelectedGroup()
        updateButtons()
    }

    //MARK: TableView DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {

        return fetchedResultsController()?.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let groupTableCellView = tableView.make(withIdentifier: "GroupTableCellView", owner: self) as? NSTableCellView else {return nil}
            
        configureCell(tableViewCell: groupTableCellView, atRow: row)
        
        return groupTableCellView
    }
    
    //MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        groupsTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            
//          indexPath / newIndexPath contains two entries. The first one for the the section the second for row
//          ToDo: Check why newIndexPath?.row is unknown
            guard let row = newIndexPath?.last else {return}
            groupsTableView.insertRows(at: IndexSet(integer: row), withAnimation: NSTableViewAnimationOptions.effectFade)
            
        case .delete:
            
            guard let row = indexPath?.last else {return}
            groupsTableView.removeRows(at: IndexSet(integer: row), withAnimation: NSTableViewAnimationOptions.effectFade)

            //Check if the deletion caused a seletecd group to be deleted
            if (groupsTableView.selectedRow == -1) {
                Swift.print("\(groupsTableView.selectedRow)")
                dataModel()?.selectedGroup = nil

            }


        case .update:
            guard let row = newIndexPath?.last else {return}
            guard let rowView = groupsTableView.rowView(atRow: row, makeIfNecessary: false)  else {return}
            guard let cellView = rowView.view(atColumn: 0) as? NSTableCellView else {return}
            
            configureCell(tableViewCell: cellView, atRow: row)
            
        case .move:

            guard let oldRow = indexPath?.last else {return}
            guard let newRow = newIndexPath?.last else {return}

            groupsTableView.moveRow(at: oldRow, to: newRow)
            
            guard let rowView = groupsTableView.rowView(atRow: newRow, makeIfNecessary: false)  else {return}
            guard let cellView = rowView.view(atColumn: 0) as? NSTableCellView else {return}
            configureCell(tableViewCell: cellView, atRow: newRow)
            
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        groupsTableView.endUpdates()
    }
    

}

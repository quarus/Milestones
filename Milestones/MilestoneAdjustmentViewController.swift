//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MilestoneAdjustmentViewController.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class MilestoneAdjustmentViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, StateObserverProtocol, CoreDataNotificationManagerDelegate {
    
    
    private let MOCManager: CoreDataNotificationManager = CoreDataNotificationManager()
    private var fetchRequest = NSFetchRequest<Adjustment>(entityName: "Adjustment")
    private var cwDateFormatter: DateFormatter = DateFormatter()
    private var selectedAdjustment: Adjustment? {
        didSet {
            if let reason = selectedAdjustment?.reason {
                adjustmentReasonTextView?.string = reason
            } else {
                adjustmentReasonTextView?.string = ""
            }
        }
    }
    
    @IBOutlet weak var adjustmentsTableView: NSTableView?
    @IBOutlet weak var adjustmentReasonTextView: NSTextView?
    @IBOutlet weak var removeAdjustementButton: NSButton?
    
    override var representedObject: Any? {
        
        willSet {
            dataModel()?.remove(dataObserver: self)
        }
        
        didSet {
            dataModel()?.add(dataObserver: self)
        }
    }
    
    //MARK: Helper functions
    private func dataModel() -> StateProtocol? {
        
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        let dependencies = representedObject as? AnyObject as? Dependencies
        return dependencies?.stateModel
    }
    
    private func adjustment(at index:Int) -> Adjustment?{
        
        guard let milestone = dataModel()?.selectedMilestone else {return nil}
        guard let adjustments =  milestone.adjustments else {return nil}
        
        var foundAdjustment :Adjustment?
        
        if 0..<adjustments.count ~= index {
            foundAdjustment = adjustments.object(at: index) as? Adjustment
        }
        return foundAdjustment
    }
    
    func adjustmentContainedInObjects(_ objects: NSSet) -> Bool{
        
        for anObject in objects {
            if anObject is Adjustment {
                return true
            }
        }
        return false
    }

    private func configureCell(tableViewCell :NSTableCellView, atRow row :Int) {
        
        guard let adjustment = adjustment(at: row) else {return}
        
        if let adjustmentDate = adjustment.date {
            let dateString = cwDateFormatter.string(from: adjustmentDate)
            tableViewCell.textField?.stringValue = dateString
        }
    }
    
    private func update() {
        
        guard let adjustments = dataModel()?.selectedMilestone?.adjustments?.array else {return}
        
        adjustmentsTableView?.reloadData()

        if adjustments.count == 0 {
            removeAdjustementButton?.isEnabled = false
        } else {
            removeAdjustementButton?.isEnabled = true
        }
    }
    
    
    //MARK: View Life Cycle
    override func viewDidLoad() {

        cwDateFormatter.calendar = Calendar.defaultCalendar()
        cwDateFormatter.dateFormat = "w.e/yyyy"
        
        MOCManager.registerForNotificationsOn(moc: dataModel()?.managedObjectContext)
        MOCManager.delegate = self
        
    }
    
    override func viewWillAppear() {
        update()
    }
    
    override func viewDidAppear() {
        
    }
    
    //MARK: UI Callbacks
    @IBAction func onEnterInCWTextField(_ sender: NSTextField) {
        
    }
    
    @IBAction func onEnterInReasonTextField(_ sender: NSTextField) {
        
    }
    
    @IBAction func onClickOfRemoveAdjustmentButton(_ sender: NSButton) {
        
        let indexOfSelectedEntry = adjustmentsTableView?.selectedRow ?? -1
    
        if (indexOfSelectedEntry >= 0) {
            if let selectedAdjustment = adjustment(at: indexOfSelectedEntry) {
                selectedAdjustment.managedObjectContext?.delete(selectedAdjustment)
            }
        }
    }
    
    //NSTextDelegate (used for NSTextView)
    func textDidEndEditing(_ notification: Notification) {
        if let reason = adjustmentReasonTextView?.string {
            selectedAdjustment?.reason = reason
        }
    }
    
    //MARK: DataObserverProtocol
    func didChangeSelectedGroup(_ group :Group?){}
    func didChangeSelectedTimeline(_ selectedTimelines :[Timeline]){}
    
    func didChangeSelectedMilestone(_ milestone :Milestone?){
        selectedAdjustment = nil
        update()
    }

    
    //MARK: CoreDataNotificationManagerDelegate
    func managedObjectContext(_ moc: NSManagedObjectContext, didInsertObjects objects: NSSet) {
        if adjustmentContainedInObjects(objects) {
            update()
        }
    }
    
    func managedObjectContext(_ moc: NSManagedObjectContext, didUpdateObjects objects: NSSet) {
        if adjustmentContainedInObjects(objects) {
            update()
        }
    }
    
    func managedObjectContext(_ moc: NSManagedObjectContext, didRemoveObjects objects: NSSet) {
        if adjustmentContainedInObjects(objects) {
            selectedAdjustment = nil
            update()
        }
    }
    
    //MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let index = adjustmentsTableView?.selectedRow ?? -1
        if (index >= 0) {
            selectedAdjustment = adjustment(at: index)
        }
    }
    
    //MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let milestone = dataModel()?.selectedMilestone else {return 0}
        guard let numberOfRows = milestone.adjustments?.count else {return 0}
        return numberOfRows
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let adjustmentTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AdjustmentTableViewCell"), owner: self) as? NSTableCellView else {return nil}
        configureCell(tableViewCell: adjustmentTableCellView, atRow: row)
        return adjustmentTableCellView
    }
}

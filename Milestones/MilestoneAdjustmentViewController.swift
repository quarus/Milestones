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
    
    
    private var MOCManager: CoreDataNotificationManager?
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
        
        guard let milestone = dataModel()?.selectedMilestone else { return nil }
        guard let adjustments =  milestone.adjustments else { return nil }
        
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

    private func update() {
        
        guard let adjustments = dataModel()?.selectedMilestone?.adjustments?.array else {return}
        
        adjustmentsTableView?.reloadData()

        if adjustments.count == 0 {
            removeAdjustementButton?.isEnabled = false
        } else {
            removeAdjustementButton?.isEnabled = true
        }
    }
    
    private func milestoneCellModelFor(row: Int) -> MilestoneTableCellModel? {
        
        guard let currentAdjustment = adjustment(at: row) else {return nil}
        let nextAdjustment = adjustment(at: row + 1)
        
        let milestoneCellModel = MilestoneTableCellModel(adjustment: currentAdjustment, nextDate: nextAdjustment?.date)
        return milestoneCellModel
    }
    
    func configureCell(tableViewCell: NSTableCellView, forMilestoneCellModel model: MilestoneTableCellModel) {
        guard let milestoneTableCellView = tableViewCell as? MilestoneTableCellView else {return}
        milestoneTableCellView.configureUsing(dataSource: model)
    }
    
    //MARK: View Life Cycle
    override func viewDidLoad() {

        cwDateFormatter.calendar = Calendar.defaultCalendar()
        cwDateFormatter.dateFormat = "w.e/yyyy"
        
        if let moc = dataModel()?.managedObjectContext {
            MOCManager = CoreDataNotificationManager(managedObjectContext: moc)
            MOCManager?.delegate = self

        }
        
    }
    
    override func viewWillAppear() {
        update()
    }
    
    //MARK: UI Callbacks
    @IBAction func onEnterInCWTextField(_ sender: NSTextField) {
        
    }
    
    @IBAction func onEnterInReasonTextField(_ sender: NSTextField) {
        
    }
    
    @IBAction func onClickOfRemoveAdjustmentButton(_ sender: NSButton) {
        guard let indexOfSelectedEntry = adjustmentsTableView?.selectedRow else { return }
    
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
    func didChangeZoomLevel(_ level: ZoomLevel) {}

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
        guard let index = adjustmentsTableView?.selectedRow else { return }
        if (index >= 0) {
            selectedAdjustment = adjustment(at: index)
        }
    }
   
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        guard let milestoneCellModel = milestoneCellModelFor(row: row) else {return 0.0}
        
        if milestoneCellModel.needsExpandedCell {
            return MilestoneTableCellView.heightOfExpandedTableViewCell
        }
        
        return MilestoneTableCellView.heightOfRegularTableViewCell
    }
    
    //MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let milestone = dataModel()?.selectedMilestone else { return 0 }
        guard let numberOfRows = milestone.adjustments?.count else { return 0 }
        return numberOfRows
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
}

//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  AdjustmentViewController.swift
//  Milestones
//
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class AddAdjustmentViewController: NSViewController {
    
    @IBOutlet weak var adjustmentLabel: NSTextField!
    @IBOutlet var descriptionTextView: NSTextView!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var confirmButton: NSButton!
    
    //MARK: View life cycle
    override func viewWillAppear() {
        
        if let milestone = dataModel()?.selectedMilestone {
            let milestoneName = milestone.name ?? ""
            adjustmentLabel.stringValue = "Verschiebung von \(milestoneName)"
        }
    }
    
    //MARK: UI Button Callbacks
    @IBAction func onConfirmButtonClick(_ sender: Any) {
        addNewAdjustment()
        self.dismiss(self)
    }
    
    @IBAction func onCancelButtonClick(_ sender: Any) {
        self.dismiss(self)
    }
    
    private func dataModel() -> StateProtocol? {
        
        //This casting chain is a workaround (?): https://bugs.swift.org/browse/SR-3871
        let dataModel = representedObject as? AnyObject as? StateModel
        return dataModel
    }


    private func addNewAdjustment() {
        
       guard let moc = dataModel()?.managedObjectContext else {return}

        //1. create an adjustemnt
        let newAdjustment = NSEntityDescription.insertNewObject(forEntityName: "Adjustment", into: moc) as! Adjustment
        newAdjustment.creationDate = Date()
        newAdjustment.trackedMilestone = dataModel()?.selectedMilestone
        newAdjustment.date = dataModel()?.selectedMilestone?.date
        newAdjustment.reason = descriptionTextView.string
        
        //2. add it to the milestones adjustments
        newAdjustment.trackedMilestone?.addAdjustment(anAdjustment: newAdjustment)
        
        //3. update the context
        dataModel()?.managedObjectContext.processPendingChanges()
    }
}

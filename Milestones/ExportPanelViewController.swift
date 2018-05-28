//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
// ExportViewController.swift
// Milestones
// Copyright (c) 2016 Altay Cebe
//


import Foundation
import Cocoa

class ExportPanelViewController :NSViewController {

    @IBOutlet private weak var nameTextField: NSTextField?
    @IBOutlet private weak var infoTextField: NSTextView?
    @IBOutlet private weak var startDatePopUpButton: NSPopUpButton?
    @IBOutlet private weak var endDatePopUpButton: NSPopUpButton?

    private(set) var milestones: [Milestone] = [Milestone]()

    private(set) var selectedStartMilestone: Milestone?
    private(set) var selectedEndMilestone: Milestone?
    
    
    var titleForExport: String {
        get {
            return nameTextField?.stringValue ?? ""
        }
        set {
            nameTextField?.stringValue = newValue
        }
    }

    var descriptionForExport: String {
        get {
            return infoTextField?.string ?? ""
        }
        set {
            infoTextField?.string = newValue
        }
    }
    
    func setMilestones(milestones: [Milestone], withStartMilestone startMilestone: Milestone?, endMilestone endMilestone: Milestone?) {
        
        self.milestones = milestones
        
        selectedStartMilestone = startMilestone
        selectedEndMilestone = endMilestone
        
        if let startMS = self.selectedStartMilestone {
        
            if self.milestones.contains(startMS) {
                selectedStartMilestone = startMS
            }
        }
        
        if let endMS = self.selectedEndMilestone {
            if self.milestones.contains(endMS) {
                selectedEndMilestone = endMS
            }
        }
        
        populateDatePopOverButtons()
    }
    
    override func viewDidLoad() {
    }
    
    override func awakeFromNib() {
        
    }

    private func populateDatePopOverButtons() {

        startDatePopUpButton?.removeAllItems()
        endDatePopUpButton?.removeAllItems()

        let calendarWeekAndDayFormatter = DateFormatter()
        calendarWeekAndDayFormatter.dateFormat = "w.e/YY"


        var idx = 1
        for aMilestone in milestones {

            let milestoneName = aMilestone.name ?? "No Name"
            var  milestoneDateString = ""
            if let date = aMilestone.date {
                milestoneDateString = calendarWeekAndDayFormatter.string(from: date)
            }

            let menuEntryString = "\(idx):  " + milestoneDateString + " - " + milestoneName
            startDatePopUpButton?.addItem(withTitle: menuEntryString)
            endDatePopUpButton?.addItem(withTitle: menuEntryString)
            idx += 1
        }
        
        var startIndex = 0
        var endIndex = milestones.count - 1
        
        if let startMS = selectedStartMilestone {
            startIndex = self.milestones.index(of: startMS) ?? 0
        }
        
        if let endMS = selectedEndMilestone {
            endIndex = self.milestones.index(of: endMS) ?? milestones.count - 1
        }
        
        startDatePopUpButton?.selectItem(at: startIndex)
        endDatePopUpButton?.selectItem(at: endIndex)
    }


    private func showAlertPanelWith(text :String){

        let alertPanel = NSAlert()
        alertPanel.messageText = text
        alertPanel.beginSheetModal(for: self.view.window!, completionHandler: nil)

    }


    //MARK: UI Callbacks
    @IBAction func onClickOfStartDateSelectionButton(_ sender: NSPopUpButton) {
        let newlySelectedStartMilestone = milestones[sender.indexOfSelectedItem]

        if let selectedStartDate = newlySelectedStartMilestone.date, let selectedEndDate = selectedEndMilestone?.date {

            if (selectedStartDate > selectedEndDate) {
                showAlertPanelWith(text: "Das Start Datum darf nicht nach dem End Datum liegen")
                if let index = milestones.index(of: selectedStartMilestone!) {
                    startDatePopUpButton?.selectItem(at: index)
                }
            } else {
                selectedStartMilestone = newlySelectedStartMilestone
            }
        }
    }

    @IBAction func onClickOfEndDateSelectionButton(_ sender: NSPopUpButton) {
        let newlySelectedEndMilestone = milestones[sender.indexOfSelectedItem]

        if let selectedStartDate = selectedStartMilestone?.date, let selectedEndDate = newlySelectedEndMilestone.date {

            if (selectedEndDate < selectedStartDate) {
                showAlertPanelWith(text: "Das End Datum darf nicht vor dem Start Datum liegen")

                if let index = milestones.index(of: selectedEndMilestone!) {
                    endDatePopUpButton?.selectItem(at: index)
                }
            } else {
                selectedEndMilestone = newlySelectedEndMilestone
            }
        }
    }
    
    
    

}

//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Protocols.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa


typealias Dependencies = HasStateModel & HasCalculators


protocol GroupsManagementModelProtocol {
    
    var selectedGroup: Group? {get set}
    var selectedTimeline: Timeline? {get set}
    var managedObjectContext: NSManagedObjectContext? {get set}
}


protocol StateProtocol: class {

    var selectedGroup: Group? {get set}
    var selectedTimelines: [Timeline] {get set}
    var selectedMilestone: Milestone? {get set}

    var managedObjectContext: NSManagedObjectContext {get set}

    func add(dataObserver: StateObserverProtocol)
    func remove(dataObserver: StateObserverProtocol)
    
    func allGroups() -> [Group]

}

protocol StateObserverProtocol {

    func didChangeSelectedGroup(_ group: Group?)
    func didChangeSelectedTimeline(_ selectedTimelines: [Timeline])
    func didChangeSelectedMilestone(_ milestone: Milestone?)
}

protocol HasStateModel {
    var stateModel:  StateProtocol {get}
}

protocol HasCalculators {
    var xCalculator: HorizontalCalculator {get set}
    var yCalculator: VerticalCalculator {get set}
}


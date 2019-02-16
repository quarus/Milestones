//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  MilestoneProtocol.swift
//  Milestones
//
//  Created by Altay Cebe on 15.02.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation

protocol MilestoneProtocol {

    var type: IconType {get set}
    var name: String {get set}
    var info: String? {get set}
    var date: Date {get set}
}

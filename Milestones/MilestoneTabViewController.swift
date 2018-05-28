//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
//  MilestoneTabViewController.swift
//  Milestones
//
//  Copyright © 2018 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa

class MilestoneTabViewController: NSTabViewController {
    
    override var representedObject: Any? {
        
        didSet {
            for anItem in tabViewItems {
                
                if let vc = anItem.viewController {
                    vc.representedObject = representedObject
                }
            }
        }
    }
}

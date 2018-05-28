//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//
//  File.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa


class SplitViewController: NSSplitViewController {
    
    override var representedObject: Any? {
        
        didSet {
            for anItem in splitViewItems {
                
                let vc = anItem.viewController
                vc.representedObject = representedObject
            }
        }
    }
}

class MainSplitViewController :NSSplitViewController, StateObserverProtocol {
    
    enum ViewType {
        case None
        case Timeline
        case Milestone
    }
    
    var timelineInfoSplitViewItem: NSSplitViewItem?
    var milestoneInfoSplitViewItem: NSSplitViewItem?
    
    override var representedObject: Any? {
        
        willSet {
            dependency()?.stateModel.remove(dataObserver: self)
        }
        
        didSet {
            for anItem in splitViewItems {
                
                let vc = anItem.viewController
                vc.representedObject = dependency()
            }
            //            FIXME: this is crappy
            milestoneInfoSplitViewItem?.viewController.representedObject = dependency()
            timelineInfoSplitViewItem?.viewController.representedObject = dependency()
            
            dependency()?.stateModel.add(dataObserver: self)
        }
    }
    
    func dependency() -> Dependencies? {
        
        let dc = representedObject as? AnyObject as? Dependencies
        return dc
    }

    private func displayView(viewType: ViewType) {
        
        guard let milestoneItem = milestoneInfoSplitViewItem else {return}
        guard let timelineItem = timelineInfoSplitViewItem else {return}

        switch viewType {
            
        case .Timeline:
            if splitViewItems.contains(milestoneItem) {
                
                removeSplitViewItem(milestoneItem)
                addSplitViewItem(timelineItem)
            }
            break
        case .Milestone:
           
            if splitViewItems.contains(timelineItem) {
                
                removeSplitViewItem(timelineItem)
                addSplitViewItem(milestoneItem)
            }
            break

        default:
            break
        }
    }
    
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyBoard = NSStoryboard(name: "MainStoryboard", bundle: nil)
        
        if let timelineInfoViewController = storyBoard.instantiateController(withIdentifier: "TimelineInfoViewController") as? NSViewController {
            timelineInfoViewController.representedObject = dependency()
            timelineInfoSplitViewItem = NSSplitViewItem(viewController: timelineInfoViewController)
        }
        
        if let milestoneTabViewController = storyBoard.instantiateController(withIdentifier: "MilestoneTabBar") as? MilestoneTabViewController {
            milestoneTabViewController.representedObject = dependency()
            milestoneInfoSplitViewItem = NSSplitViewItem(viewController: milestoneTabViewController)
        }
        
        
        
        if let item = milestoneInfoSplitViewItem {
            addSplitViewItem(item)
        }
        // Setting the splitview autosavename with the Storyboard somehow doesn't work. Setting the autosavename programmatically however restores
        // the window to its proper size
        splitView.autosaveName = "MainSplitView"

    }
    
    override func viewDidAppear() {
    
        
    }
    
    //MARK: DataObserverProtocol
    func didChangeSelectedGroup(_ group :Group?) {
        
    }
    
    func didChangeSelectedTimeline(_ selectedTimelines: [Timeline]){
        displayView(viewType: .Timeline)
    }
    
    func didChangeSelectedMilestone(_ milestone: Milestone?){
        displayView(viewType: .Milestone)
    }
}

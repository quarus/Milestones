//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  ClipView.swift
//  Milestones
//
//  Copyright © 2017 Altay Cebe. All rights reserved.
//

import Foundation
import Cocoa


protocol ClipViewDelegate {
    func clipViewDidMove(_ clipView: ClipView)
    func clipViewPassedEdgeTreshold(_ clipView: ClipView)
}

class ClipView: NSClipView {
    
    var handlesBoundsChangeNotifications = false
    var delegate :ClipViewDelegate?
    
    private var recentering = false

    private var previousMinXPosition: CGFloat = 0.0
    private var previousMaxXPosition: CGFloat = 0.0
    
    override func awakeFromNib() {
        postsBoundsChangedNotifications = true
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
    func registerForBoundsChangedNotifications() {
        
        if !handlesBoundsChangeNotifications {
            
            handlesBoundsChangeNotifications = true
        
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(viewGeometryChanged),
                                                   name: NSView.frameDidChangeNotification,
                                                   object: self)
        
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(viewGeometryChanged),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: self)
        }
    }

    @objc private func viewGeometryChanged() {
        guard let documentFrame = self.documentView?.frame else {return}

        let lowerTreshold = bounds.size.width / 2.0
        let upperTreshold = documentFrame.size.width - (bounds.size.width / 2.0)
        
        delegate?.clipViewDidMove(self)
    
        if (bounds.minX < lowerTreshold) && (previousMinXPosition > lowerTreshold) {
            if !recentering {
                delegate?.clipViewPassedEdgeTreshold(self)
                recentering = false
            }
        }
        
        if (bounds.maxX > upperTreshold) && (previousMaxXPosition < upperTreshold) {
            if !recentering {
                delegate?.clipViewPassedEdgeTreshold(self)
                recentering = false
            }
        }
        
        previousMinXPosition = bounds.minX
        previousMaxXPosition = bounds.maxX
    }
}


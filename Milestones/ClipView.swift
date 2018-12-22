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
    func clipViewFrameDidChange(_ clipView: ClipView)
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
        
            //called when the window is resized and resizing effects the containing scrolliew
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(frameGeometryChanged),
                                                   name: NSView.frameDidChangeNotification,
                                                   object: self)
        
            //called when the clipview is moved
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(boundsGeometryChanged),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: self)
        }
    }
    @objc private func frameGeometryChanged(){
        delegate?.clipViewFrameDidChange(self)
    }

    @objc private func boundsGeometryChanged() {
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


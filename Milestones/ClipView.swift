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
    func clipViewWillRecenter(_ clipView: ClipView)
    func clipViewDidRecenter(_ clipView: ClipView)
    func clipViewDidMove(_ clipView: ClipView)
    func clipViewNeedsRecentering(_ clipView: ClipView)
}

class ClipView: NSClipView {
    
    var handlesBoundsChangeNotifications = false
    var delegate :ClipViewDelegate?
    
    private var recentering = false;
    
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

    private func calculateRepositionOffset() -> CGPoint {
        
        let recenterTreshold: CGFloat = 1500
        
        guard let documentFrame = self.documentView?.frame else {return CGPoint.zero}
        let clipBounds = self.bounds
        
        let minHorizontalDistance = clipBounds.minX - documentFrame.minX
        let maxHoritontalDistance = documentFrame.maxX - clipBounds.maxX
        
        
        if ((minHorizontalDistance < recenterTreshold) ||
            (maxHoritontalDistance < recenterTreshold)) {
            
            var recenterOffset = CGPoint.zero
            recenterOffset.x = documentFrame.minX + round((documentFrame.width - bounds.width) / 2.0);
            recenterOffset.y = documentFrame.maxY + round((documentFrame.height - bounds.height) / 2.0);
            return recenterOffset
            
        }
        return CGPoint.zero
    }
    
    @objc private func viewGeometryChanged() {
        
        delegate?.clipViewDidMove(self)
        
        if !recentering {
            recentering = true
            let offset = calculateRepositionOffset()
        
            if !CGPoint.zero.equalTo(offset) {
                
/*                delegate?.clipViewWillRecenter(self)
                bounds.origin.x = offset.x
                delegate?.clipViewDidRecenter(self)
 */
                delegate?.clipViewNeedsRecentering(self)

                
            }
            
            recentering = false
        }
    }
    
    
    //MARK: View life cycle
}


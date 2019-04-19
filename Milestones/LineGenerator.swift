//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  File.swift
//  Milestones
//
//  Created by Altay Cebe on 19.04.19.
//  Copyright © 2019 Altay Cebe. All rights reserved.
//

import Foundation

protocol LineGeneratorProtocol {
    var position: CGPoint {get}
}

class LineGenerator {
    
    func graphicsForStartPoints(_ startPoints: [LineGeneratorProtocol], endPoints: [LineGeneratorProtocol]) -> [Graphic]? {
        
        var graphics: [Graphic] = [Graphic]()

        if startPoints.count != endPoints.count {
            return nil
        }
        
        for idx in 0..<startPoints.count {
            
            let lineGraphic = LineGraphic.lineGraphicWith(startPoint: startPoints[idx].position,
                                                      endPoint: endPoints[idx].position,
                                                      thickness: 1.0)
            graphics.append(lineGraphic)
        }

        return graphics
    }
}

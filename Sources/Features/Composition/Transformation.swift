//
//  Transformation.swift
//  Rayz
//
//  Created by Josh on 4/3/23.
//

import Foundation
import SwiftUI

struct Transformation: Equatable {
    var size: CGSize = CGSize.zero
    var offset: CGSize = CGSize.zero
    var offsetStart: CGSize?
    var magification = CGFloat(1.0)
    var magificationStart: CGFloat?
    var rotation = Angle(degrees: 0)
    var rotationStart: Angle?
    
    var rotationAnchor: UnitPoint {
        let w = size.width
        let h = size.height
        guard w != 0 && h != 0 else { return .center }
        let x = w/2.0 + offset.width/w
        let y = h/2.0 + offset.height/h
        return UnitPoint(x: x, y: y)
    }
    
    var isTransforming: Bool {
        return offsetStart != nil || magificationStart != nil || rotationStart != nil
    }
    
    mutating func updateOffet(_ offsetUpdate: CGSize) {
        if offsetStart == nil {
            offsetStart = offset
        }
        
        guard let offsetStart else {
            return
        }

        // Is there a nicer way to do this? probably..
        self.offset = CGSize(width: offsetStart.width + offsetUpdate.width,
                             height: offsetStart.height + offsetUpdate.height)

    }
    
    mutating func updateMagnification(_ magnificationUpdate: CGFloat) {
        
        if magificationStart == nil {
            magificationStart = magification
        }

        guard let magificationStart else {
            return
        }
        magification = magificationStart * magnificationUpdate

    }
    
    mutating func updateRotation(_ rotationUpdate: Angle) {
        if rotationStart == nil {
            rotationStart = rotation
        }

        guard let rotationStart else {
            return
        }
        rotation = rotationStart + rotationUpdate
    }
    
    mutating func endUpdate() {
        offsetStart = nil
        magificationStart = nil
        rotationStart = nil
    }
}

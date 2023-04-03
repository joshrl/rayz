//
//  MaskedImage.swift
//  Rayz
//
//  Created by Josh on 4/3/23.
//

import Foundation
import SwiftUI

struct MaskedImage: Equatable, Identifiable {
    
    var id: UUID
    
    // Mutable
    var transformation: Transformation
    
    let orientation: UIImage.Orientation
    var image: CGImage {
        didSet {
            // reset transformation everytime image is set
            transformation = Transformation(size: CGSize(width: image.width, height: image.height))
        }
    }
    let mask: CGImage
    var maskedImage: CGImage {
        Self.createMaskedImage(image: image, mask: mask)
    }
    
    init(orientation: UIImage.Orientation, image: CGImage, mask: CGImage, uuid: UUID = UUID()) {
        
        self.orientation = orientation
        let maskCrop: CGRect
        let imageCrop: CGRect
        (maskCrop, imageCrop) = Self.createTrimingRects(image: image, mask: mask)
        
        let imageCropped = image.cropping(to: imageCrop) ?? image
        let maskCropped = mask.cropping(to: maskCrop) ?? mask
        self.image = imageCropped
        self.mask = maskCropped
        self.transformation = Transformation(size: CGSize(width: imageCrop.width, height: imageCrop.height))
        self.id = uuid
    }
    
    private static func createMaskedImage(image: CGImage, mask: CGImage) -> CGImage {
        // Create a mask image
        guard let dataProvider = mask.dataProvider else {
            return image
        }
        guard let mask = CGImage(
            maskWidth: mask.width,
            height: mask.height,
            bitsPerComponent: mask.bitsPerComponent,
            bitsPerPixel: mask.bitsPerPixel,
            bytesPerRow: mask.bytesPerRow,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: true) else {
            return image
        }
        return image.masking(mask) ?? image
        
    }
    
    private static func createTrimingRects(image: CGImage, mask: CGImage) -> (CGRect, CGRect) {
        
        let maskTrimmedRect = mask.trimmedRect()
        
        // normalize...
        let normalized = CGRect(x: maskTrimmedRect.origin.x / CGFloat(mask.width),
                                y: maskTrimmedRect.origin.y / CGFloat(mask.height),
                                width: maskTrimmedRect.width / CGFloat(mask.width),
                                height: maskTrimmedRect.height / CGFloat(mask.height))
        
        // Apply to image rect
        let imageTrimmeedRect = CGRect(x: normalized.origin.x * CGFloat(image.width),
                                       y: normalized.origin.y * CGFloat(image.height),
                                       width: normalized.width * CGFloat(image.width),
                                       height: normalized.height * CGFloat(image.height))
        return (maskTrimmedRect, imageTrimmeedRect)
        
    }
    
}

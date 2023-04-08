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
    let image: CGImage
    let mask: CGImage
    let maskedImage: UIImage
    
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
        self.maskedImage = Self.createMaskedUIImage(orientation: orientation, image: image, mask: mask)
    }
    
    private static func createMaskedUIImage(orientation: UIImage.Orientation, image: CGImage, mask: CGImage) -> UIImage {
        
        // First create CGImage iwth mask
        let maskedImage = createMaskedCGImage(image: image, mask: mask)
        
        // Now create a UIImage that we will draw into
        let img = UIImage(cgImage: maskedImage,
                          scale: UIScreen.main.nativeScale,
                          orientation: orientation)
        
        UIGraphicsBeginImageContext(img.size)
        img.draw(in: .init(origin: .zero, size: img.size))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage ?? UIImage()
    }
    
    private static func createMaskedCGImage(image: CGImage, mask: CGImage) -> CGImage {
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

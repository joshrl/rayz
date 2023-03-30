//
//  MaskMaker.swift
//  Rayz
//
//  Created by Josh on 3/18/23.
//

import Foundation
import CoreImage
import OSLog


struct MaskMaker {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "👻")

    enum MaskError: Error {
        case failedToInvert
        case failedToCreateCoreGraphicsImage
    }

    static func createMask(from input: CGImage) async throws -> CGImage {
        logger.debug("starting bg removal")
        let model = try await DIS08.load()

        logger.debug("model loaded")
        let result = try model.prediction(input: DIS08Input(x_1With: input))
        logger.debug("prediction made")
        
        guard let inverted = inverted(from: result.activation_out) else {
            throw MaskError.failedToInvert
        }
        
        let context = CIContext()
        guard let mask = context.createCGImage(inverted, from: inverted.extent) else {
            throw MaskError.failedToCreateCoreGraphicsImage
        }
        
        return mask
    }
    
    
    private static func inverted(from pixelBuffer: CVPixelBuffer) -> CIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }
    
}



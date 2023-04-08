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
        logger.info("starting bg removal")
        let model = try await DIS08.load()

        logger.info("model loaded")
        let result = try model.prediction(input: DIS08Input(x_1With: input))
        logger.info("prediction made")
        
        let output0 = inverted(from: result.activation_out)
        let output1 =  increaseContrast(image: output0)
        let processed = sharpen(image: output1)
        
        let context = CIContext()
        guard let mask = context.createCGImage(processed, from: processed.extent) else {
            throw MaskError.failedToCreateCoreGraphicsImage
        }
        
        return mask
    }
    
    
    private static func inverted(from pixelBuffer: CVPixelBuffer) -> CIImage {
        CIImage(cvPixelBuffer: pixelBuffer).applyingFilter("CIColorInvert", parameters: [:])
    }
    
    private static func increaseContrast(image: CIImage) -> CIImage {
        image.applyingFilter("CIColorControls", parameters: ["inputContrast": 2.0])
    }
    
    private static func sharpen(image: CIImage) -> CIImage {
        image.applyingFilter("CIUnsharpMask", parameters: [:])
    }
    
    
}



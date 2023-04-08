//
//  MaskMaker.swift
//  Rayz
//
//  Created by Josh on 3/18/23.
//

import Foundation
import CoreImage
import OSLog


actor MaskMaker {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "👻")
    private var model: DIS08?
    
    enum MaskError: Error {
        case notLoaded
        case failedToCreateCoreGraphicsImage
    }
    
    func preheat() async -> Void {
        logger.info("preheating bg removal start")
        model = try? await DIS08.load()
        logger.info("preheating bg removal done")
    }

    func createMask(from input: CGImage) async throws -> CGImage {
        
        logger.info("creating mask")
        let resolved: DIS08
        
        // Because we are an actor, access to self.model will be serialized and preheat will happen first..(if called)
        if let model {
            resolved = model
        } else {
            resolved = try await DIS08.load()
        }
        logger.info("starting bg removal")
        let result = try resolved.prediction(input: DIS08Input(x_1With: input))
        logger.info("prediction made")
        
        let output0 = Self.inverted(from: result.activation_out)
        let output1 =  Self.increaseContrast(image: output0)
        let processed = Self.sharpen(image: output1)
        
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



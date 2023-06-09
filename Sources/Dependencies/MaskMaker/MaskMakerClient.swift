//
//  MaskMakerClient.swift
//  Rayz
//
//  Created by Josh on 3/18/23.
//

import AVFoundation
import Foundation
import CoreImage
import ComposableArchitecture

struct MaskMakerClient {
    var preheat: @Sendable () async -> Void
    var createMask: @Sendable (CGImage) async throws -> CGImage
}

extension MaskMakerClient: DependencyKey {
    
    static var liveValue: Self {
        let maskMaker = MaskMaker()
        return Self(
            preheat: {
                await maskMaker.preheat()
            },
            createMask: { input in
                return try await maskMaker.createMask(from: input)
            }
        )
    }
    
    static var previewValue: Self {
        return Self(
            preheat: { },
            createMask: { input in
                return input
            }
        )
    }
    
    static var testValue: Self {
        return Self(
            preheat: { },
            createMask: { input in
                return input
            }
        )
    }
    
}


extension DependencyValues {
  var maskMaker: MaskMakerClient {
    get { self[MaskMakerClient.self] }
    set { self[MaskMakerClient.self] = newValue }
  }
}

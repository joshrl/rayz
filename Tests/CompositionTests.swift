//
//  CompositionTests.swift
//  RayzTests
//
//  Created by Josh on 4/9/23.
//

import ComposableArchitecture
import XCTest
@testable import Rayz

@MainActor
final class CompositionTests: XCTestCase {
    
    let img = UIImage.image(withColor: .red)
    var cgimage: CGImage {  img.cgImage! }
    
    func testMaskImage() async {
        
        let store = TestStore(initialState: Composition.State(), reducer: Composition()) {
            $0.uuid = .incrementing
          }
        
        // TODO: MaskedImage applies a side effect we can't control
        // Should move that logic out of there and into a dependency
        store.exhaustivity = .off
        
        await store.send(.maskImageAndAdd(img)) {
            $0.isMasking = true
        }
        
        await store.receive(.addMaskedImage(image: cgimage, mask: cgimage, orientation: img.imageOrientation)) {
            $0.isMasking = false
        }
        
    }

    func testTransform() async {
        
        let layer = MaskedImage(orientation: img.imageOrientation, image: cgimage, mask: cgimage)
        
        let store = TestStore(initialState: Composition.State(maskedImageLayers: [layer]),
                              reducer: Composition()) {
            $0.uuid = .incrementing
          }
        
        // Transform the layer...
        var transform = layer.transformation
        await store.send(.transformMaskedImage(id: layer.id,
                                               offset: .init(width: 10, height: 10),
                                               magification: 0.6,
                                               rotation: .init(degrees: 30))) {
            $0.isTransforming = true
            transform.updateOffet(.init(width: 10, height: 10))
            transform.updateRotation(.init(degrees: 30))
            transform.updateMagnification(0.6)
            $0.maskedImageLayers[id: layer.id]?.transformation = transform
        }
        
        // Complete transformation
        transform.endUpdate()
        await store.send(.transformMaskedImageDone(id: layer.id)) {
            $0.isTransforming = false
            $0.maskedImageLayers[id: layer.id]?.transformation = transform
        }
        
    }
    
    func testSetColorTheme() async {
        let store = TestStore(initialState: Composition.State(colorTheme: .blues), reducer: Composition()) {
            $0.uuid = .incrementing
        }
        
        await store.send(.setColorTheme(.pride)) {
            $0.colorTheme = .pride
        }
        
    }

}

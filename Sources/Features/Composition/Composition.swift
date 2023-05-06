//
//  Composition.swift
//  Rayz
//
//  Created by Josh on 3/27/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct Composition: Reducer {
    
    @Dependency(\.maskMaker) var maskMaker
    @Dependency(\.uuid) var uuid
    enum CancelId {
        case masking
    }

    struct State: Equatable {
        var isMasking: Bool = false
        var isTransforming: Bool = false
        var colorTheme: ColorTheme = .blues
        var maskedImageLayers: IdentifiedArrayOf<MaskedImage> = []
        // Future: BG
        // Future: Text
        
    }
    
    enum Action: Equatable {
        case maskImageAndAdd(UIImage)
        case cancelMasking
        case addMaskedImage(image: CGImage, mask: CGImage, orientation: UIImage.Orientation)
        case transformMaskedImage(id: UUID, offset: CGSize?, magification: CGFloat?, rotation: Angle?)
        case transformMaskedImageDone(id: UUID)
        case setColorTheme(ColorTheme)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch (action) {
                
            case .maskImageAndAdd(let image):
                
                state.isMasking = true
                return
                    .run { send in
                    if let cgImage = image.cgImage {
                        let mask = try await maskMaker.createMask(cgImage)
                        await send(.addMaskedImage(image: cgImage,
                                                   mask: mask,
                                                   orientation: image.imageOrientation))
                    } else {
                        await send(.cancelMasking)
                    }
                }.cancellable(id: CancelId.masking)
            case .cancelMasking:
                state.isMasking = false
                return .cancel(id: CancelId.masking)
            case .addMaskedImage(image: let image, mask: let mask, orientation: let orientation):
                let layer = MaskedImage(orientation: orientation,
                                        image: image,
                                        mask: mask,
                                        uuid: uuid())
                state.maskedImageLayers.append(layer)
                state.isMasking = false
                return .none.animation()
            case .transformMaskedImage(id: let image,
                                       offset: let offset,
                                       magification: let magification,
                                       rotation: let rotation):
  
                if let magification {
                    state.maskedImageLayers[id: image]?.transformation.updateMagnification(magification)
                }
                if let offset {
                    state.maskedImageLayers[id: image]?.transformation.updateOffet(offset)
                }
                if let rotation {
                    state.maskedImageLayers[id: image]?.transformation.updateRotation(rotation)
                }
                state.isTransforming = true
                return .none
            case .transformMaskedImageDone(let image):
                state.maskedImageLayers[id: image]?.transformation.endUpdate()
                state.isTransforming = false
                return .none
            case .setColorTheme(let theme):
                state.colorTheme = theme
                return .none
            }
        }
    }
    
}

struct CompositionView: View {
    
    let store: StoreOf<Composition>
    
    var body: some View {
        
        ZStack {
            godrays
            GlowGroup(store) {
                maskedImages
            }
            loading
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    private var loading: some View {
        WithViewStore(self.store, observe: \.isMasking) { viewStore in
            if viewStore.state {
                LoaderView()
            }
        }
    }
    
    struct GodRayState: Equatable {
        let colors: [Color]
        let isLoading: Bool
        
        init(state: Composition.State) {
            colors = state.colorTheme.rayColors
            isLoading = state.isMasking
        }
    }
    
    private var godrays: some View {

        WithViewStore(self.store, observe: { GodRayState(state: $0) }) { viewStore in
            GodRays(colors: viewStore.state.colors,
                    rotationStyle: viewStore.state.isLoading ? .ticking : .smooth)
        }
    }
    
    private var maskedImages: some View {
        WithViewStore(self.store, observe: \.maskedImageLayers) { viewStore in
            
            ForEach(viewStore.state) { layer in
                MaskedImageView(layer: layer) {
                    viewStore.send(.transformMaskedImageDone(id: layer.id))
                } transformUpdated: { offset, angle, scale in
                    viewStore.send(.transformMaskedImage(id: layer.id, offset: offset, magification: scale, rotation: angle))
                }
                .padding(30)
            }

        }
    }
    
    struct GlowGroup<Content: View>: View {
        
        let content: () -> Content
        let store: StoreOf<Composition>

        private struct ViewState: Equatable {
            let theme: ColorTheme
            let isTransforming: Bool
        }
        
        init(_ store: StoreOf<Composition>, @ViewBuilder content: @escaping () -> Content) {
            self.content = content
            self.store = store
        }
        
        var body: some View {
            WithViewStore(self.store, observe: {
                ViewState(
                    theme: $0.colorTheme,
                    isTransforming: $0.isTransforming
                )
            }) { viewStore in

                Group {
                    content()
                }.compositingGroup().glow(color: viewStore.theme.glowColor)

            }
            
        }
    }
    
}

struct CompositionView_Previews: PreviewProvider {
    static var previews: some View {
        
        if let image1 =
            UIImage(named: "switch-controller")?.cgImage,
           let mask1 = UIImage(named: "switch-controller-mask")?.cgImage
        {
            //let image2 = UIImage(named: "image")!.cgImage!
            //let mask2 = UIImage(named: "mask")!.cgImage!
            let layer1 = MaskedImage(orientation: .up, image: image1, mask: mask1)
            //let layer2 = Composition.MaskedImage(orientation: .right, image: image2, mask: mask2)

            let store = Store(initialState: Composition.State(
                maskedImageLayers: [layer1]
            ), reducer: Composition())
            CompositionView(store: store)
        } else {
            Text("Preview Images Not Found")
        }

    }
}


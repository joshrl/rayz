//
//  LayerControls.swift
//  Rayz
//
//  Created by Josh on 4/5/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct LayerControls: View {
   
    var store: StoreOf<CompositionEditor>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            let menuState = viewStore.state.expandedMenu
            let layers = viewStore.state.composition.maskedImageLayers
            ExpandableGroup(menuState == .layerControls) {
                CircularIconButton(source: .system(name: "square.stack.3d.up")) {
                    viewStore.send(.toggleLayerControls,
                                   animation:.spring(dampingFraction: 0.5))
                }
            } expanded: {
                CircularIconButton(source: .custom(name: "icon.camera.plus"),
                                   imageOffset: .init(width: 4, height: 0)) {
                    viewStore.send(.startCapture, animation: .easeOut)
                }
                
                // Add button for each layer here...
                ForEach(layers) { layer in
                    CircularIconButton(source: .image(Image(uiImage: layer.maskedImage))) {
                        
                    }
                }
                
            }
        }

    }
}

struct LayerControls_Previews: PreviewProvider {
    
    static let initialState = CompositionEditor
        .State(composition: Composition.State())
    
    static var previews: some View {
        
        LayerControls(store:Store(initialState: initialState,
                                  reducer: CompositionEditor())
        )
    }
}

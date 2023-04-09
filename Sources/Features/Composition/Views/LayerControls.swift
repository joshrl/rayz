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
    
    @Binding var isExpanded: Bool
    @Binding var composition: Composition.State
    var didTapAddImage: () -> Void
    
    var body: some View {
        ExpandableGroup($isExpanded) {
            CircularIconButton(source: .system(name: "square.stack.3d.up")) {
                withAnimation(.spring(dampingFraction: 0.5)) {
                    isExpanded.toggle()
                }
            }
        } expanded: {
            CircularIconButton(source: .custom(name: "icon.camera.plus"),
                               imageOffset: .init(width: 4, height: 0)) {
                withAnimation(.spring(dampingFraction: 0.5)) {
                    isExpanded = false
                }
                didTapAddImage()
            }
            
            // Add button for each layer here...
            ForEach(composition.maskedImageLayers) { layer in
                CircularIconButton(source: .image(Image(uiImage: layer.maskedImage))) {
                    
                }
            }
            
        }
    }
}

struct LayerControls_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper((false, Composition.State())) { value in
            LayerControls(isExpanded: value.0,
                          composition: value.1
            ) { }
        }
    }
}

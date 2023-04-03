//
//  MaskedImageView.swift
//  Rayz
//
//  Created by Josh Rooke-Ley on 3/28/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct MaskedImageView: View {
    
    let layer: MaskedImage
    let transformCompleted: () -> Void
    let transformUpdated: (CGSize?, Angle?, CGFloat?) -> Void

    
    var body: some View {
            
        Image(uiImage: UIImage(cgImage: layer.maskedImage,
                               scale: UIScreen.main.nativeScale,
                               orientation: layer.orientation))
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipped()
        .rotationEffect(layer.transformation.rotation)
        .scaleEffect(layer.transformation.magification)
        .offset(layer.transformation.offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    transformUpdated(gesture.translation, nil, nil)
                }
                .onEnded { _ in
                    transformCompleted()
                }
        )
        .simultaneousGesture(
            RotationGesture()
                .onChanged { rotation in
                    transformUpdated(nil, rotation, nil)

                }
                .onEnded { _ in
                    transformCompleted()
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { scale in
                    transformUpdated(nil, nil, scale)
                }
                .onEnded { _ in
                    transformCompleted()
                }
        )

    }
    
}

struct MaskedImageView_Previews: PreviewProvider {
    
    static var previews: some View {
        if let image =
            UIImage(named: "switch-controller")?.cgImage,
           let mask = UIImage(named: "switch-controller-mask")?.cgImage
        {
            let layer = MaskedImage(orientation: .up, image: image, mask: mask)
            
            ZStack {
                Color.blue
                MaskedImageView(layer: layer) {} transformUpdated: { _, _, _ in }
            }
        } else {
            Spacer()
        }

    }
}

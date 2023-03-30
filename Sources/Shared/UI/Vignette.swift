//
//  Vignette.swift
//  
//
//  Created by Josh Rooke-Ley on 1/8/23.
//

import SwiftUI

extension View {
    public func vignetted(softness: CGFloat = 0.2) -> some View {
        mask {
            GeometryReader { dimensions in
                let side = min(dimensions.size.width, dimensions.size.height)
                
                Ellipse()
                    .inset(by: side * (softness*2))
                    .blur(radius: side * softness/2)
            }
        }
    }
}


struct Vignette_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            ZStack {
                Rectangle().foregroundColor(.purple).vignetted()
                Image("cake")
            }.previewDisplayName("Vignetted (Default")
            ZStack {
                Rectangle().foregroundColor(.purple).vignetted(softness: 0.0)
                Image("cake")
            }.previewDisplayName("Vignetted (Hard)")
            ZStack {
                Rectangle().foregroundColor(.purple).vignetted(softness: 0.3)
                Image("cake")
            }.previewDisplayName("Vignetted (Soft)")
        }
    }
}


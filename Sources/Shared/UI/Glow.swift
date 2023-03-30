//
//  Glow.swift
//  Godrays
//
//  Created by Josh Rooke-Ley on 1/8/23.
//

import SwiftUI
import UIKit

extension View {
    
    public func glow(uicolor: UIColor, radius: CGFloat = 5) -> some View {
        glow(color: Color(uicolor), radius: radius)
    }
    
    public func glow(color: Color, radius: CGFloat = 5) -> some View {
        shadow(color: color, radius: radius)
        .shadow(color: color, radius: radius)
        .shadow(color: color, radius: radius)
        .shadow(color: color, radius: radius)
    }
    
}

struct Glow_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            ZStack {
                Image("cake").glow(uicolor: .systemGreen, radius: 5)
            }.previewDisplayName("Green 5")
            ZStack {
                Image("cake").glow(uicolor: .systemBlue, radius: 20)
            }.previewDisplayName("Blue 20")
        }
    }
}

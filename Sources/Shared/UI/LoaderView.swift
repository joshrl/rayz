//
//  LoaderView.swift
//  Rayz
//
//  Created by Josh on 4/8/23.
//

import Foundation
import SwiftUI


struct LoaderView: View {
    
    let startDate = Date()
    
    var body: some View {
        ZStack {
            
            Capsule()
                .stroke(.white, lineWidth: 6)
                .frame(width: 200, height: 60.0)
                .glow(color: .white)
            
            Capsule()
                .foregroundColor(.white.opacity(0.95))
                .rainbowAnimation()
                //.blur(radius: 5)
                .frame(width: 200, height: 60.0)
            
//            ProgressView()
//                .tint(.black)
//                .scaleEffect(x: 2, y: 2, anchor: .center)
                
            Text("loading...").font(.system(.body, design: .monospaced)).glow(color: .white)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
           LoaderView()
        }.background(.red)
    }
}

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
        TimelineView(.animation) { context in
            
            let seconds = seconds(for: context.date)
            ZStack {
                LoadingText(tick: seconds)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func seconds(for date: Date) -> Double {
        let seconds = Calendar.current.component(.second, from: date)
        return Double(seconds) / 60
    }
    
}

private struct LoadingText: View {
    
    var tick: Double
    @State var scale: CGFloat =  1.0
    var body: some View {
            
        Group {
            Image("image.loading-bg")
                .rainbowAnimation()
            Image("image.loading-fg")
                .foregroundColor(.black)
        }.onChange(of: tick) { _ in
            Task {
                scale = 1.5
                try? await Task.sleep(for:.milliseconds(100))
                scale = 1.3
            }
        }
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.3), value: scale)
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GodRays(colors: ColorTheme.pride.rayColors,
                    rotationStyle:.ticking)
            LoaderView()
        }
    }
}

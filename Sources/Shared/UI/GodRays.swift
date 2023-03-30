//
//  GodRays.swift
//  Godrays
//
//  Created by Josh on 8/26/19.
//  Copyright © 2019 Josh Rooke-Ley. All rights reserved.
//

import SwiftUI

public struct GodRays: View {
    
    let rayColors: [Color]
    let arcSize: Angle
    let speed: Double
    let blurRadius: CGFloat
    
    @State var update = Double(0)
    @State var animateIn = Double(0)
    
    public init(rayColor: Color, arcSize: Angle = .degrees(20), speed: Double = 1, blurRadius: CGFloat = 0) {
        self.rayColors = [Color(.systemBackground).opacity(0.3), rayColor]
        self.arcSize = arcSize
        self.speed = speed
        self.blurRadius = blurRadius
    }
    
    public init(rayColors: (Color, Color), arcSize: Angle = .degrees(20), speed: Double = 1, blurRadius: CGFloat = 0) {
        self.rayColors = [rayColors.0, rayColors.1]
        self.arcSize = arcSize
        self.speed = speed
        self.blurRadius = blurRadius
    }
    
    public init(colors: [Color], arcSize: Angle = .degrees(20), speed: Double = 1, blurRadius: CGFloat = 0) {
        self.rayColors = colors
        self.arcSize = arcSize
        self.speed = speed
        self.blurRadius = blurRadius
    }
    
    
    var animation: Animation {
        Animation.linear(duration: 120).repeatForever(autoreverses: false)
    }
    
    public var body: some View {
        
        ZStack {
            
            RaysView(angleSize: arcSize, colors: rayColors)
                .blur(radius: blurRadius)
                .rotationEffect(.degrees(update * speed))
            
        }
        .onAppear() {
            withAnimation(self.animation) {
                update = 360
            }
        }

    }
    

}


struct RaysView: View {
    let angleSize: Angle
    let colors: [Color]
    
    private struct Wedge: Identifiable {
        let start: Angle
        let color: Color
        var id: Angle { start }
    }
    
    private var wedges: [Wedge] {
        guard colors.count > 0 else {
            return []
        }
        var colorIndex = 0
        var result = [Wedge]()
        for startDegrees in stride(from: 0, to: 360, by: angleSize.degrees) {
            result += [Wedge(start: Angle(degrees: startDegrees), color: colors[colorIndex])]
            colorIndex = (colorIndex + 1) % colors.count
        }
        return result
    }
    
    public var body: some View {
        ForEach (wedges) { wedge in
            ArcShape(size: angleSize, start: wedge.start).foregroundColor(wedge.color)
        }
    }
}

struct RaysShape: Shape {
    
    var angleSize: Int
    
    init(sections: Int = .max, angleSize: Int) {
        self.angleSize = max (0, min(360, angleSize))
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.size.width/2, y: rect.size.height/2)

            for i in stride(from: 0, to: 360, by: angleSize*2) {
                path.move(to: center)

                path.addArc(center: center,
                            radius: rect.size.height,
                            startAngle: .degrees(Double(i)),
                            endAngle: .degrees(Double(i + angleSize)),
                            clockwise: false)
            }
            
        }
    }
    
}

struct ArcShape: Shape {
    
    let size: Angle
    let start: Angle

    func path(in rect: CGRect) -> Path {
        
        Path { path in
            let center = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
            path.move(to: center)

            path.addArc(center: center,
                        radius: rect.size.height,
                        startAngle: start,
                        endAngle: start + size,
                        clockwise: false)
        }
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

struct GodRays_Previews: PreviewProvider {
    static var previews: some View {

        ZStack {
  
            let colors = [
                Color(hex: 0xFF0018),
                Color(hex: 0xFFA52C),
                Color(hex: 0xFFFF41),
                Color(hex: 0x008018),
                Color(hex: 0x0000F9),
                Color(hex: 0x86007D),

            ]
            GodRays(colors: colors)
//            GodRays(rayColor: Color(.systemGreen))
//            GodRays(rayColor: Color(.systemGreen).opacity(0.7),
//                    arcSize: Angle(degrees: 45),
//                    speed: 2,
//                    blurRadius: 6)
//            .opacity(0.6)
//            GodRays(rayColor: Color(.systemGreen).opacity(0.1),
//                    arcSize: Angle(degrees: 45),
//                    speed: 4,
//                    blurRadius: 12)
        }
        .edgesIgnoringSafeArea(.all)

    }
}

//
//  GodRays.swift
//  Godrays
//
//  Created by Josh on 8/26/19.
//  Copyright © 2019 Josh Rooke-Ley. All rights reserved.
//

import SwiftUI

public struct GodRays: View {
    
    public enum RotationStyle {
        case smooth
        case ticking
    }
    let rayColors: [Color]
    let arcSize: Angle
    let period: Double
    let rotationStyle: RotationStyle
    private var smooth: Bool {
        rotationStyle == .smooth
    }
    @State var tick: Double? = nil
    @State var rotation: Double = 0
    
    public init(colors: [Color], arcSize: Angle = .degrees(20), periodSeconds: Double = 3, rotationStyle: RotationStyle = .smooth) {
        if (360.truncatingRemainder(dividingBy: Double(colors.count)) != 0) {
            print("warning: color count of \(colors.count) won't evenly cycle in period")
        }
        self.rayColors = colors
        self.arcSize = arcSize
        self.period = periodSeconds
        self.rotationStyle = rotationStyle
    }
    
    public var body: some View {
        
        TimelineView(.animation(minimumInterval: 1.0/30.0)) { context in
            let date = context.date
            
            let update = self.smooth ?
                secondHandWithNanoResolution(for: date) :
                secondsHandWithSecondResolution(for: date)
            
            let _ = Task {
                tick = update
            }
            
            let angle: Double = tick != nil ? rotation : cycle() * update

            RaysView(angleSize: arcSize,
                     colors: rayColors,
                     rotation: Angle(degrees: angle),
                     animate: self.rotationStyle != .smooth)
        }.onChange(of: tick) { tick in
            guard let tick = tick else { return }
            
            let cycle = cycle()
            let unitRotation = cycle * tick

            var update: Double = rotation
            
            // Prevent a counter clockwise rotation on cycle
            if unitRotation == 0 {
                update = update + cycle
            }
            
            update = (update - update.truncatingRemainder(dividingBy: cycle)) + unitRotation
            
            rotation = update
        }
        
    }
    
    private func cycle() -> Double {
        // How much of the circle do we need per cycle?
        let minRepeatingArc = Double(rayColors.count) * arcSize.degrees
        
        // Period in seconds, is the time to do a repeating arc
        // divide into 60 because update is a full minute
        let minutePeriod = 60 / period
        
        return minRepeatingArc * minutePeriod
    }
    
    // Vary with second resolution
    private func secondsHandWithSecondResolution(for date: Date) -> Double {
        let seconds = Calendar.current.component(.second, from: date)
        return Double(seconds) / 60
    }
    
    // Vary with nanosecond resolution
    private func secondHandWithNanoResolution(for date: Date) -> Double {
        let seconds = Calendar.current.component(.second, from: date)
        let nanos = Calendar.current.component(.nanosecond, from: date)
        return Double(seconds * 1_000_000_000 + nanos) / 60_000_000_000
    }
    

}

struct RaysView: View {
    let angleSize: Angle
    let colors: [Color]
    var rotation: Angle = .zero
    var animate: Bool = false

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
        
        ZStack {
            ForEach (wedges) { wedge in
                ArcShape(size: angleSize, start: wedge.start).foregroundColor(wedge.color)
            }
            .rotationEffect(rotation)
            .animation(animate ? .spring(response: 0.3, dampingFraction: 0.6) : nil,
                       value: rotation)
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
            GodRays(colors: colors,
                    periodSeconds: 6,
                    rotationStyle: .smooth)
        }
        .edgesIgnoringSafeArea(.all)

    }
}

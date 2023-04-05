//
//  ColorTheme.swift
//  Rayz
//
//  Created by Josh on 3/30/23.
//

import Foundation
import SwiftUI

struct ColorTheme: Equatable, Identifiable {
    var id: String { iconImageName }
    var iconImageName: String
    var glowColor: Color
    var rayColors: [Color]
    
    static let `default` = ColorTheme(iconImageName: "icon.colors.purple.orange",
                                      glowColor: .yellow,
                                      rayColors: [.yellow, .purple])
    
    static let blues = ColorTheme(iconImageName: "icon.colors.indigo.blue",
                                  glowColor: .white,
                                  rayColors: [.indigo, .blue])
    
    static let greens = ColorTheme(iconImageName: "icon.colors.green.yellow",
                                   glowColor: .yellow,
                                   rayColors: [.green, .yellow])
    
    static let pride = ColorTheme(iconImageName: "icon.colors.pride",
         glowColor: .white,
         rayColors: [
            Color("color.pride.red"),
            Color("color.pride.orange"),
            Color("color.pride.yellow"),
            Color("color.pride.green"),
            Color("color.pride.blue"),
            Color("color.pride.purple")
        ])
    
    static let nonbinary = ColorTheme(iconImageName: "icon.colors.nonbinary",
         glowColor: .white,
         rayColors: [
            Color("color.nonbinary.yellow"),
            Color("color.nonbinary.white"),
            Color("color.nonbinary.purple"),
            Color("color.nonbinary.black"),
        ])
    
    static let all = [`default`, blues, greens, pride, nonbinary]
    
}

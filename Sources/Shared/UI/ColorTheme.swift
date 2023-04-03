//
//  ColorTheme.swift
//  Rayz
//
//  Created by Josh on 3/30/23.
//

import Foundation
import SwiftUI

struct ColorTheme: Equatable {
    var iconImageName: String
    var glowColor: Color
    var rayColors: [Color]
    
    static let `default` = ColorTheme(iconImageName: "icon.colors.purple.orange",
                                      glowColor: .orange,
                                      rayColors: [.yellow, .purple])
    static let blues = ColorTheme(iconImageName: "icon.colors.indigo.blue",
                                  glowColor: .white,
                                  rayColors: [.indigo, .blue])
    static let greens = ColorTheme(iconImageName: "icon.colors.green.yellow",
                                   glowColor: .white,
                                   rayColors: [.green, .yellow])
    
    static let all = [`default`, blues, greens]
    
}

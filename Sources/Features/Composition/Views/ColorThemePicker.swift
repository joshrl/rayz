//
//  ColorThemePicker.swift
//  Rayz
//
//  Created by Josh on 4/5/23.
//

import Foundation
import SwiftUI

struct ColorThemePicker: View {
    
    @Binding var isOpen: Bool
    @Binding var selectedTheme: ColorTheme
    
    var body: some View {
        ExpandableGroup($isOpen) {
            button(selectedTheme.iconImageName) {
                withAnimation(.spring(dampingFraction: 0.5)) {
                    isOpen.toggle()
                }
            }
        } expanded: {
            ForEach(ColorTheme.all) { item in
                if (item != selectedTheme) {
                    button(item.iconImageName) {
                        withAnimation(.spring(dampingFraction: 0.5)) {
                            isOpen = false
                        }
                        
                        selectedTheme = item
                    }
                }
            }
        }
    }
    
    private func button(_ named: String, action: @escaping () -> Void) -> some View {
        CircularIconButton(source:
                .custom(name: named, renderingMode: .original), action: action)
    }
    
}

struct ColorThemePicker_Previews: PreviewProvider {
    static var previews: some View {
       
        StatefulPreviewWrapper((false, ColorTheme.default)) { value in
            ColorThemePicker(isOpen: value.0, selectedTheme: value.1)
        }
    }
}


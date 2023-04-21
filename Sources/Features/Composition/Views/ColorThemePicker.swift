//
//  ColorThemePicker.swift
//  Rayz
//
//  Created by Josh on 4/5/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct ColorThemePicker: View {
    
    var store: StoreOf<CompositionEditor>
    
    private struct ViewState: Equatable {
        let selectedTheme: ColorTheme
        let expandedMenu: CompositionEditor.ExpandedMenu
    }

    var body: some View {
        WithViewStore(store, observe: {
            ViewState(selectedTheme: $0.composition.colorTheme,
                      expandedMenu: $0.expandedMenu)
        }) { viewStore in
            
            let selectedTheme = viewStore.selectedTheme
            ExpandableGroup(viewStore.expandedMenu == .colorThemePicker) {
                button(selectedTheme.iconImageName) {
                    viewStore.send(.toggleColorThemePicker,
                                   animation:.spring(dampingFraction: 0.5))
                }
            } expanded: {
                ForEach(ColorTheme.all) { item in
                    if (item != selectedTheme) {
                        button(item.iconImageName) {
                            viewStore.send(.setTheme(item),
                                           animation:.easeOut)
                        }
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
    
    static let initialState = CompositionEditor
        .State(composition: Composition.State())
    
    static var previews: some View {
        
        ColorThemePicker(store:Store(initialState: initialState,
                                     reducer: CompositionEditor())
        )
    }
}


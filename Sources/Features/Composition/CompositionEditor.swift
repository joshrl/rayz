//
//  CompositionEditor.swift
//  Rayz
//
//  Created by Josh on 4/4/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct CompositionEditor: Reducer {
    
    struct State: Equatable {
        @BindingState var isColorThemePickerOpen: Bool = false
        var composition: Composition.State
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setTheme(ColorTheme)
        case toggleColorThemePicker
        case compositionUpdated
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch (action) {
            case .setTheme(let theme):
                state.composition.colorTheme = theme
                state.isColorThemePickerOpen = false
                return .task { .compositionUpdated }
            case .toggleColorThemePicker:
                state.isColorThemePickerOpen.toggle()
                return .none
            case .binding:
                return .none
            case .compositionUpdated:
                return .none
            }
        }
    }
    
}

struct CompositionEditorView: View {
    
    var store: StoreOf<CompositionEditor>
    
    var body: some View {
        BottomBar {
            Spacer()
            colorThemePicker
            Spacer()
        }
    }
    
    private func button(_ named: String, action: @escaping () -> Void) -> some View {
        CircularIconButton(source:
                .custom(name: named, renderingMode: .original), action: action)
    }
    
    private var colorThemePicker: some View {
        WithViewStore(self.store, observe: { $0 } ) { viewStore in
            
            ExpandableGroup(viewStore.binding(\.$isColorThemePickerOpen)) {
                button(viewStore.composition.colorTheme.iconImageName) {
                    viewStore.send(.toggleColorThemePicker, animation: .spring(dampingFraction: 0.5))
                }
            } expanded: {
                ForEach(ColorTheme.all) { item in

                    if (item != viewStore.composition.colorTheme) {
                        button(item.iconImageName) {
                            viewStore.send(.setTheme(item), animation: .spring(dampingFraction: 0.6))
                        }
                    }

                }
            }
            
        }
        
    }
    
}

struct CompositionEditorView_Previews: PreviewProvider {
    
    static let initialState = CompositionEditor
        .State(composition: Composition.State())
    
    static var previews: some View {
        
        
        CompositionEditorView(store: Store(
            initialState: initialState,
            reducer: CompositionEditor())
        )
    }
}

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
        @BindingState var composition: Composition.State
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
            CircularIconButton(source: .system(name: "square")) {}.hidden()
            Spacer()
            colorThemePicker
            Spacer()
            layerControls
        }
    }
    
    private var colorThemePicker: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ColorThemePicker(
                isOpen: viewStore.binding(\.$isColorThemePickerOpen),
                selectedTheme: viewStore.binding(\.$composition.colorTheme))
        }
    }
    
    private var layerControls: some View {
       
        CircularIconButton(source: .system(name: "square.stack.3d.up")) {
            
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

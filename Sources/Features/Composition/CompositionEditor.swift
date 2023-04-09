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
        @BindingState var isLayerControlsOpen: Bool = false
        @BindingState var composition: Composition.State
        @PresentationState var capture: Capture.State? = nil
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case composition(Composition.Action)
        case setTheme(ColorTheme)
        case toggleColorThemePicker
        case startCapture
        case capture(PresentationAction<Capture.Action>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch (action) {
                
            // Binding
            case .binding:
                return .none
                
            // Set Color Theme
            case .setTheme(let theme):
                state.composition.colorTheme = theme
                state.isColorThemePickerOpen = false
                return .none
            case .toggleColorThemePicker:
                state.isColorThemePickerOpen.toggle()
                return .none
                
            // Capture
            case .startCapture:
                state.capture = Capture.State()
                return .none
            case let .capture(.presented(.delegate(.setImage(image)))):
                return .send(.composition(.maskImageAndAdd(image)))
            case .capture(.dismiss):
                state.capture = nil
                return .none
            case .capture:
                return .none
            
            // Composition
            case .composition:
                return .none
            }
        }.ifLet(\.$capture, action: /Action.capture) {
            Capture()
        }
        
        Scope(state: \.composition, action: /Action.composition) {
            Composition()
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
        .fullScreenCover(
          store: self.store.scope(
            state: \.$capture,
            action: CompositionEditor.Action.capture)
        ) { store in
          CaptureView(store: store)
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
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            LayerControls(isExpanded: viewStore.binding(\.$isLayerControlsOpen),
                          composition: viewStore.binding(\.$composition)
            ) {
                viewStore.send(.startCapture)
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

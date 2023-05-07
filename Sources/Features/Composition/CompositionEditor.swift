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
    
    enum ExpandedMenu {
        case colorThemePicker
        case layerControls
        case none
    }
    
    struct State: Equatable {
        @BindingState var composition: Composition.State
        @PresentationState var capture: Capture.State? = nil
        @BindingState var expandedMenu: ExpandedMenu = .none
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case composition(Composition.Action)
        case setTheme(ColorTheme)
        case toggleColorThemePicker
        case toggleLayerControls
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
                state.expandedMenu = .none
                return .none
            case .toggleColorThemePicker:
                state.expandedMenu = state.expandedMenu == .colorThemePicker ? .none : .colorThemePicker
                return .none
                
            // Layer Controls
            case .toggleLayerControls:
                state.expandedMenu = state.expandedMenu == .layerControls ? .none : .layerControls
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
        
        ZStack {
            BottomBar {
                shareMenu
                Spacer()
                colorMenu
                Spacer()
                layerMenu
            }
            .fullScreenCover(
              store: self.store.scope(
                state: \.$capture,
                action: CompositionEditor.Action.capture)
            ) { store in
              CaptureView(store: store)
            }
        }


    }
    
    private var colorMenu: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ColorThemePicker(store: store)
        }
    }
    
    private var layerMenu: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            LayerControls(store: self.store)
        }
    }

    @MainActor
    private var shareMenu: some View {
        
        // Share Button
        CircularIconButton(source: .system(name: "square.and.arrow.up"), imageOffset: .init(width: 0, height: -3)) {
            
            let exporter = ExporterView(content: exportedComposition)
            
            Task {
                await exporter.capture()
            }
        }
    }
    
    private var exportedComposition: some View {
        WithViewStore(self.store, observe: \.composition) { viewStore in
            
            let size = UIScreen.main.bounds.size

            CompositionView(store:
                                Store(initialState: viewStore.state,
                                      reducer: Composition()))
            // Clip to bounds
            .frame(width: size.width, height: size.height)
            .clipped()
            // Clip to square
            .frame(width: size.width, height: size.width)
            .clipped()
        }
    }
    
}

@MainActor
class ExporterView<Content: View> {
    
    var renderer: ImageRenderer<Content>
    
    init(content: Content) {
        self.renderer = ImageRenderer(content: content)
    }

    func capture() async {
        
        print("\(Date()): Start")

        let _ = renderer.uiImage
        
        let handle = renderer.objectWillChange.receive(on: DispatchQueue.main).sink { [renderer = renderer] _ in
            print("\(Date.timeIntervalSinceReferenceDate): Rendered image changed")
            let _ = renderer.uiImage
        }
        
        try? await Task.sleep(for: .seconds(1))
        handle.cancel()
        print("\(Date()): Done")
        
        
    }
    
    
//    var body: some View {
//        HStack {
//            renderer.content
//        }
//        .onReceive(renderer.objectWillChange) {
//            _ = renderer.uiImage
//            print("\(Date()): Rendered image changed")
//        }
//        .onAppear {
//            _ = renderer.uiImage
//        }
//    }
    

}


struct CompositionEditorView_Previews: PreviewProvider {
    
    static let initialState = CompositionEditor
        .State(composition: Composition.State())
    
    static var previews: some View {
        CompositionEditorView(store:
                                Store(initialState: initialState,
                                      reducer: CompositionEditor())
        )
    }
}

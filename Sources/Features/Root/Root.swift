//
//  Root.swift
//  Rayz
//
//  Created by Josh on 3/30/23.
//

import ComposableArchitecture
import Foundation
import OSLog
import SwiftUI

/**
 The Root!
*/
struct Root: Reducer {
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "-", category: "🦷")
    
    struct State: Equatable {
        var start: Start.State? = Start.State()
        
        // This is a bit of a bait and switch here.
        // The source of truth for the composition is the editor...
        var composition: Composition.State? {
            get {
                editor?.composition
            }
            set {
                guard let newValue else {
                    editor = nil
                    return
                }
                editor = CompositionEditor.State(composition: newValue)
            }
        }
        var editor: CompositionEditor.State? = nil
        
        @PresentationState var capture: Capture.State? = nil
    }
    
    enum Action: Equatable {
        case start(Start.Action)
        case composition(Composition.Action)
        case editor(CompositionEditor.Action)
        case capture(PresentationAction<Capture.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch (action) {
                
            // Start
            case .start(.delegate(.captureButtonTapped)):
                state.capture = Capture.State()
                return .none
            case .start:
                return .none
            
            // Capture
            case let .capture(.presented(.delegate(.setImage(image)))):
                state.start = nil
                let composition = Composition.State()
                state.composition = composition
                return .send(.composition(.maskImageAndAdd(image)))
            case .capture(.dismiss):
                state.capture = nil
                return .none
            case .capture:
                return .none
                
            // Composition
            case .composition:
                return .none
                
            // Editor
            case .editor:
                return .none
            }
        }.ifLet(\.start, action: /Action.start) {
            Start()
        }.ifLet(\.composition, action: /Action.composition) {
            Composition()
        }.ifLet(\.editor, action: /Action.editor) {
            CompositionEditor()
        }.ifLet(\.$capture, action: /Action.capture) {
            Capture()
        }
    }
    
}

struct RootView: View {
    
    let store: StoreOf<Root>
    
    var body: some View {

        ZStack {
            // Start
            IfLetStore(self.store.scope(
                state: \.start, action: Root.Action.start
            )) { start in
                StartView(store: start)
            }
            .fullScreenCover(
              store: self.store.scope(
                state: \.$capture,
                action: Root.Action.capture)
            ) { store in
              CaptureView(store: store)
            }
                   
            // Composition
            IfLetStore(self.store.scope(
                state: \.composition, action: Root.Action.composition
            )) { composition in
                CompositionView(store: composition)
            }
            
            // Editor
            IfLetStore(self.store.scope(
                state: \.editor, action: Root.Action.editor
            )) { editor in
                CompositionEditorView(store: editor)
            }
        }
        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: Store(initialState: Root.State(),
                              reducer: Root()))
    }
}

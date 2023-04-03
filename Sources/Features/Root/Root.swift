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
        var composition: Composition.State? = nil
        @PresentationState var capture: Capture.State? = nil
    }
    
    enum Action: Equatable {
        case start(Start.Action)
        case composition(Composition.Action)
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
                state.composition = Composition.State()
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
        }.ifLet(\.start, action: /Action.start) {
            Start()
        }.ifLet(\.composition, action: /Action.composition) {
            Composition()
        }.ifLet(\.$capture, action: /Action.capture) {
            Capture()
        }
    }
    
}

struct RootView: View {
    
    let store: StoreOf<Root>
    
    var body: some View {

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
        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: Store(initialState: Root.State(),
                              reducer: Root()))
    }
}

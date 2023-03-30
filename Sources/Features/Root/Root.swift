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
        @PresentationState var capture: Capture.State? = nil
    }
    
    enum Action: Equatable {
        case start(Start.Action)
        case capture(PresentationAction<Capture.Action>)

    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch (action) {
                
            // Start delegate
            case .start(.delegate(.captureButtonTapped)):
                // Need to do something hre...
                state.capture = Capture.State()
                return .none
            case .start:
                return .none
                
            // Capture delegate
            case let .capture(.presented(.delegate(.setImage(image)))):
                logger.debug("Got image: \(image)")
                return .run { send in
                    await send(.capture(.dismiss))
                }
            case .capture:
                return .none
            }
        }.ifLet(\.start, action: /Action.start) {
            Start()
        }.ifLet(\.$capture, action: /Action.capture) {
            Capture()
        }
    }
    
}

struct RootView: View {
    
    let store: StoreOf<Root>
    
    var body: some View {

        IfLetStore(self.store.scope(
            state: \.start,
            action: Root.Action.start
        ), then: { start in
            StartView(store: start)
        }, else: {
            self
        })
        .fullScreenCover(
          store: self.store.scope(state: \.$capture, action: Root.Action.capture)
        ) { store in
          CaptureView(store: store)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: Store(initialState: Root.State(),
                              reducer: Root()))
    }
}

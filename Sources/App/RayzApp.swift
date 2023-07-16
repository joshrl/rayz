//
//  RayzApp.swift
//  Rayz
//
//  Created by Josh on 3/30/23.
//

import ComposableArchitecture
import SwiftUI
import OSLog
import SwiftUI

@main
struct RayzApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store: Store(
                initialState: Root.State(),
                reducer: Root().signpost()._printChanges())
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

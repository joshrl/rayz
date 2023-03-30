//
//  Capture.swift
//  Rayz
//
//  Created by Josh on 3/30/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

/**
 Image capture feature
 */
struct Capture: Reducer {
    
    struct State: Equatable {
        var image: UIImage?
    }
    
    enum Action: Equatable {
        case delegate(DelegateAction)
    }
    
    enum DelegateAction: Equatable {
        case setImage(UIImage?)
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
}

struct CaptureView: View {
    
    let store: StoreOf<Capture>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            let binding = viewStore.binding(get: \.image,
                                            send: { Capture.Action.delegate(.setImage($0)) })
            ImagePicker(selectedImage:binding).edgesIgnoringSafeArea(.all)
            
        }
    }
}

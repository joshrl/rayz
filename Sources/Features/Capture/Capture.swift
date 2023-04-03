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
        var image: UIImage = UIImage()
    }
    
    enum Action: Equatable {
        case delegate(DelegateAction)
    }
    
    enum DelegateAction: Equatable {
        case setImage(UIImage)
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
}

struct CaptureView: View {
    
    let store: StoreOf<Capture>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            // Bind to delegate action
            let binding = viewStore.binding(get: \.image,
                                            send: { image in
                Capture.Action.delegate(.setImage(image))
            })
            
            ImagePicker(selectedImage: binding).edgesIgnoringSafeArea(.all)
            
        }
    }
}

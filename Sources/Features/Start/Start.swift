//
//  Start.swift
//  Rayz
//
//  Created by Josh on 3/30/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

/**
Feature for the starting view of the application
*/
struct Start: Reducer {
    
    //private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "-", category: "🏁")

    enum CancelID {
        case animation
    }

    struct State: Equatable {
        var glowAppearAnimation: Animation = .start
        var textAppearAnimation: Animation = .start
        var buttonAppearAnimation: Animation = .start
    }
    
    enum Action: Equatable {
        case onAppear
        case setTextAnimation(Animation)
        case setGlowAnimation(Animation)
        case setButtonAnimation(Animation)
        case delegate(DelegateAction)
    }
    
    struct Animation: Equatable {
        var scale: CGFloat
        var opacity: CGFloat
        
        static var start = Animation(scale: 0.6, opacity: 0)
        static var end = Animation(scale: 1, opacity: 1)
    }
    
    enum DelegateAction: Equatable {
        case captureButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch (action) {
            case .onAppear:
                return .run { send in
                    await send(.setGlowAnimation(.end),
                               animation: .spring(dampingFraction: 0.4))
                    await send(.setTextAnimation(.end),
                               animation: .spring(dampingFraction: 0.4))
                    try await Task.sleep(for: .milliseconds(300))
                    await send(.setButtonAnimation(.end),
                               animation: .spring(dampingFraction: 0.4))
                    
                }
                
                .cancellable(id: CancelID.animation)
            case .setTextAnimation(let anim):
                state.textAppearAnimation = anim
                return .none
            case .setGlowAnimation(let anim):
                state.glowAppearAnimation = anim
                return .none
            case .setButtonAnimation(let anim):
                state.buttonAppearAnimation = anim
                return .none
            case .delegate:
                return .none
            }
        }
    }
    
}

struct StartView: View {
    
    let store: StoreOf<Start>
    
    var body: some View {
        
        ZStack {
            GodRays(colors: ColorTheme.default.rayColors)
            
            WithViewStore(store, observe: \.glowAppearAnimation) { viewStore in
                Particles(color: Color(.white))
                Circle()
                    .frame(minWidth: 200, minHeight: 200)
                    .fixedSize()
                    .foregroundColor(Color(.white))
                    .blur(radius: 40)
                    .scaleEffect(viewStore.state.scale)
                    .opacity(0.8)
            }
            
            WithViewStore(store, observe: \.textAppearAnimation) { viewStore in
                Group {
                    Image("image.putarayonit-bg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .rainbowAnimation()
                    Image("image.putarayonit-fg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.black)
                }
                .opacity(viewStore.state.opacity)
                .scaleEffect(viewStore.state.scale)
                .onAppear() {
                    viewStore.send(.onAppear)
                }
            }
            
            WithViewStore(store, observe: \.buttonAppearAnimation) { viewStore in
                BottomBar {
                    CapsuleIconButton(source: .system(name: "camera.fill")) {
                        viewStore.send(.delegate(.captureButtonTapped))
                    }.opacity(viewStore.state.opacity)
                    .scaleEffect(viewStore.state.scale)
                }
            }
            
        }
        
    }
    
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        
        StartView(store:
                    Store(initialState: Start.State(),
                          reducer: Start())
        )
        
    }
}


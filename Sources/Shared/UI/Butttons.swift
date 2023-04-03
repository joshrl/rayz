//
//  Butttons.swift
//  Rayz
//
//  Created by Josh on 3/30/23.
//

import Foundation
import SwiftUI

struct CircularIconButton: View {
    let source: CircleIcon.Source
    var variableValue: Double? = nil
    var fillColor: Color? = nil
    var imageOffset: CGSize = .zero
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            CircleIcon(source: source,
                       variableValue: variableValue,
                       fillColor: fillColor,
                       imageOffset: imageOffset)
        }.buttonStyle(GrowingButton())
    }
    
}

struct CapsuleIconButton: View {
    
    let source: CircleIcon.Source
    var variableValue: Double? = nil
    var fillColor: Color? = nil
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            
            ZStack {
                CapsuleIcon(source: source,
                            variableValue: variableValue,
                            fillColor: fillColor)
                
            }
        }
        .buttonStyle(GrowingButton())
        
        
    }
    
}


struct CapsuleIcon: View {
    
    let source: CircleIcon.Source
    var variableValue: Double? = nil
    var fillColor: Color? = nil
    var imageOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            
            Capsule()
                .foregroundColor(fillColor ?? .black.opacity(0.3))
                //.frame(width: .infinity)
                .frame(height: 80.0)
            
            Capsule()
                .strokeBorder(.white, lineWidth: 4)
                .frame(height: 80.0)
                
            Group {
                
                switch(source) {
                case .system(let name, let renderingMode):
                    Image(systemName: name, variableValue: variableValue)
                        .renderingMode(renderingMode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(imageOffset)
                case .custom(let name, let renderingMode, let bundle):
                    Image(name, variableValue: variableValue, bundle: bundle)
                        .renderingMode(renderingMode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(imageOffset)
                case .image(let name):
                    Image(name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(imageOffset)
                        .glow(color: .white)
                }
            }
            .foregroundColor(.white.opacity(0.95))
            //.frame(width: .infinity)
            .frame(height: 42.0)
            .padding()
            .opacity(0.95)
        }
    }
}

struct CircleIcon: View {
    
    enum Source {
        case system(name: String, renderingMode: Image.TemplateRenderingMode = .template)
        case custom(name: String, renderingMode: Image.TemplateRenderingMode = .template, bundle: Bundle? = nil)
        case image(name: String)
    }
    
    let source: Source
    var variableValue: Double? = nil
    var fillColor: Color? = nil
    var imageOffset: CGSize = .zero
    var foregroundColor: Color = .white
    
    var body: some View {
        ZStack {
            
            Circle()
                .foregroundColor(fillColor ?? .black.opacity(0.3))
                .frame(width: 80.0, height: 80.0)
            
            Circle()
                .strokeBorder(foregroundColor, lineWidth: 4)
                .frame(width: 80.0, height: 80.0)
            Group {
                
                switch(source) {
                case .system(let name, let renderingMode):
                    Image(systemName: name, variableValue: variableValue)
                        .renderingMode(renderingMode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(imageOffset)
                case .custom(let name, let renderingMode, let bundle):
                    Image(name, variableValue: variableValue, bundle: bundle)
                        .renderingMode(renderingMode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(imageOffset)
                case .image(let name):
                    Image(name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(imageOffset)
                        .glow(color: .white)
                }
            }
            .frame(width: 42.0 , height: 42.0)
            .foregroundColor(foregroundColor)
            .opacity(0.95)

        }
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .scaleEffect(configuration.isPressed ? 1.08 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct BottomBar<Content: View>: View {
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 5) {
                content()
            }
        }
        .padding(.leading)
        .padding(.trailing)
        .padding(.bottom, 20)
        
    }
}


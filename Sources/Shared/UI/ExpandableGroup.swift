//
//  ExpandableGroup.swift
//  Rayz
//
//  Created by Josh on 3/12/23.
//

import Foundation
import SwiftUI

struct ExpandableGroup<Toggle: View, Views>: View {
    
    @State var isExpanded = false
    
    let direction: ExpandDirection
    let spacing: CGFloat
    let toggle: (Binding<Bool>) -> Toggle
    let expandedContent: (Binding<Bool>) -> TupleView<Views>
    
    enum ExpandDirection {
        case up, right, down, left
    }
    
    init(
        direction: ExpandDirection = .up,
        spacing: CGFloat = 95,
        @ViewBuilder toggle: @escaping (Binding<Bool>) -> Toggle,
        @ViewBuilder expanded: @escaping (Binding<Bool>) -> TupleView<Views>) {
            self.direction = direction
            self.spacing = spacing
            self.toggle = toggle
            self.expandedContent = expanded
    }
    
    var body: some View {
        
        let expandedContent = expandedContent($isExpanded).views
        
        ZStack {
            Group {
                ForEach (Array(expandedContent.enumerated()), id: \.offset) { index, view in
                    view
                        .opacity(isExpanded ? 1 : 0)
                        .offset(offset(at: index))
                }
                
                toggle($isExpanded)
            }
            
        }
    }
    
    private func offset(at index: Int) -> CGSize {
        guard isExpanded else {
            return .zero
        }
        
        switch (direction) {
        case .down:
            return .init(width: 0,
                         height: spacing * CGFloat(index) + spacing)
        case .up:
            return .init(width: 0,
                         height: -spacing * CGFloat(index) - spacing)
        case .left:
            return .init(width: -spacing * CGFloat(index) - spacing,
                         height: 0)
        case .right:
            return .init(width: spacing * CGFloat(index) + spacing,
                         height: 0)
            
        }
        
    }
    
    
}


// See https://stackoverflow.com/questions/64238485/how-to-loop-over-viewbuilder-content-subviews-in-swiftui
extension TupleView {
    fileprivate var views: [AnyView] {
        makeArray(from: value)
    }
    
    private struct GenericView {
        let body: Any
        
        var anyView: AnyView? {
            AnyView(_fromValue: body)
        }
    }
    
    private func makeArray<Tuple>(from tuple: Tuple) -> [AnyView] {
        func convert(child: Mirror.Child) -> AnyView? {
            withUnsafeBytes(of: child.value) { ptr -> AnyView? in
                let binded = ptr.bindMemory(to: GenericView.self)
                return binded.first?.anyView
            }
        }
        
        let tupleMirror = Mirror(reflecting: tuple)
        return tupleMirror.children.compactMap(convert)
    }
}


struct ExpandableGroup_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            Spacer()
            HStack {
                Spacer()
                ExpandableGroup { isExpanded in
                    Button(action: {
                        withAnimation(.spring(dampingFraction: isExpanded.wrappedValue ? 0.8 : 0.5)) {
                            isExpanded.wrappedValue = !isExpanded.wrappedValue
                        }
                        
                    }) {
                        Text("Fred").font(.largeTitle)

                    }
                } expanded: { isExpanded in
                    Button(action: {
                        isExpanded.wrappedValue.toggle()
                    }) {
                        Text("Wilma").font(.largeTitle)
                    }
                    Button(action: {
                        isExpanded.wrappedValue.toggle()
                    }) {
                        Text("Wilma").font(.largeTitle)
                    }
                    Button(action: {
                        isExpanded.wrappedValue.toggle()
                    }) {
                        Text("Wilma").font(.largeTitle)
                    }
                }.background(Color.white)
                
                Spacer()
            }
        }
        .padding()
        .background(.white)
        .tint(Color.gray.opacity(0.9))
        
    }
}




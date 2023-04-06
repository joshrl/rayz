//
//  ExpandableGroup.swift
//  Rayz
//
//  Created by Josh on 3/12/23.
//

import Foundation
import SwiftUI


enum ExpandDirection {
    case up, right, down, left
}

struct ExpandableGroup<Toggle: View, ExpandedView: View>: View {
    
    @Binding var isExpanded: Bool
    let direction: ExpandDirection
    let cellSize: CGFloat
    let toggle: () -> Toggle
    let expandedContent: () -> ExpandedView
    
    init(
        _ isExpanded: Binding<Bool>,
        direction: ExpandDirection = .up,
        cellSize: CGFloat = 95,
        @ViewBuilder toggle: @escaping () -> Toggle,
        @ViewBuilder expanded: @escaping () -> ExpandedView) {
            self._isExpanded = isExpanded
            self.direction = direction
            self.cellSize = cellSize
            self.toggle = toggle
            self.expandedContent = expanded
    }
    
    var body: some View {
        
        let expandedContent = expandedContent()
        
        Extract(expandedContent) { views in

            ZStack(alignment: .bottom) {

                ForEach (Array(views.enumerated()), id: \.offset) { index, view in
                    view
                        .opacity(isExpanded ? 1 : 0)
                        .offset(offset(at: index))
                        
                }
                toggle()

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
                         height: cellSize * CGFloat(index) + cellSize)
        case .up:
            return .init(width: 0,
                         height: -cellSize * CGFloat(index) - cellSize)
        case .left:
            return .init(width: -cellSize * CGFloat(index) - cellSize,
                         height: 0)
        case .right:
            return .init(width: cellSize * CGFloat(index) + cellSize,
                         height: 0)
            
        }
    }
}

struct ExpandableGroup_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            
            Spacer()
            
            BottomBar {
                Spacer()
                testExpando(.left, cellSize: 130)
            }
            
            
            Spacer()
            BottomBar {
                testExpando(.down)
                Spacer()
            }
            
            Spacer()
            BottomBar {
                testExpando(.right, cellSize: 130)
                Spacer()
            }
            
            BottomBar {
                testExpando(.up)
                Spacer()
            }
        }.overlay {
            
        }
        
        
    }
    
    static func testExpando(_ dir: ExpandDirection, cellSize: CGFloat = 95) -> some View {
        
        StatefulPreviewWrapper(false) { isOpen in
            
            ExpandableGroup(isOpen, direction: dir, cellSize: cellSize) {
                Button(action: {
                    withAnimation {
                        isOpen.wrappedValue.toggle()
                    }
                }) {
                    Text("Fred")
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(Color.red)
                    
                }
            } expanded: {
                Button(action: {
                }) {
                    Text("Wilma")
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(Color.red)
                }
                Button(action: {
                }) {
                    Text("Wilma")
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(Color.red)
                }
                Button(action: {
                }) {
                    Text("Wilma")
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(Color.red)
                }
            }
        }
    }
    
    
}




//
//  Extract.swift
//  
//
//  Created by George Elsham on 17/11/2022.
//
// https://github.com/GeorgeElsham/ViewExtractor
// https://stackoverflow.com/questions/64238485/how-to-loop-over-viewbuilder-content-subviews-in-swiftui
import SwiftUI

public struct Extract<Content: View, ViewsContent: View>: Extractable {
    let content: () -> Content
    let views: (Views) -> ViewsContent

    public init(_ content: Content, @ViewBuilder views: @escaping (Views) -> ViewsContent) {
        self.content = { content }
        self.views = views
    }

    public init(@ViewBuilder _ content: @escaping () -> Content, @ViewBuilder views: @escaping (Views) -> ViewsContent) {
        self.content = content
        self.views = views
    }

    public var body: some View {
        _VariadicView.Tree(
            UnaryViewRoot(views: views),
            content: content
        )
    }
}

fileprivate struct UnaryViewRoot<Content: View>: _VariadicView_UnaryViewRoot {
    let views: (Views) -> Content

    func body(children: Views) -> some View {
        views(children)
    }
}

//
//  View.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/28/24.
//

import SwiftUI
import Foundation

fileprivate struct EditorSectionHeaderModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.caption2)
            .underline()
            .bold()
    }
}

fileprivate struct BlurModifier: ViewModifier {
    let active: Bool
    
    public func body(content: Content) -> some View {
        content
            .blur(radius: active ? 5 : 0)
    }
}

extension View {
    func editorSectionHeaderStyle() -> some View {
        modifier(EditorSectionHeaderModifier())
    }
    
    func conditionalBlurStyle(_ active: Bool) -> some View {
        modifier(BlurModifier(active: active))
    }
}

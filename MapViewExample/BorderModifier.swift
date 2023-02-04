//
//  BorderModifier.swift
//  MapViewExample
//
//  Created by Yuta Ogawa on 2023/02/04.
//

import SwiftUI

struct BorderModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                Capsule(style: .continuous)
                    .stroke(color, lineWidth: 2)
            )
    }
}

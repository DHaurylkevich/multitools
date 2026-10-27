//
//  RadialMenuView.swift
//  multitools
//
//  Created by Mac on 27/10/2026.
//

import SwiftUI

enum RadialMenuAction {
    case translate
    case askAI
}

struct RadialMenuView: View {
    let onSelect: (RadialMenuAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Multitools")
                .font(.headline)
                .padding(.bottom, 4)

            Button {
                onSelect(.translate)
            } label: {
                Label("Translate", systemImage: "character.bubble")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button {
                onSelect(.askAI)
            } label: {
                Label("Ask AI", systemImage: "sparkles")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(width: 220)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

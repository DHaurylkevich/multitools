//
//  QuickContextBar.swift
//  multitools
//
//  Created by Mac on 30/10/2026.
//

import SwiftUI

struct QuickContextBar: View {

    @Binding var useSelection: Bool
    @Binding var useScreen: Bool
    @Binding var useClipboard: Bool

    var body: some View {
        HStack {

            contextButton(
                title: "Selection",
                icon: "text.cursor",
                isEnabled: $useSelection
            )

            contextButton(
                title: "Screen",
                icon: "display",
                isEnabled: $useScreen
            )

            contextButton(
                title: "Clipboard",
                icon: "doc.on.clipboard",
                isEnabled: $useClipboard
            )
        }
    }

    private func contextButton(
        title: String,
        icon: String,
        isEnabled: Binding<Bool>
    ) -> some View {

        Button {
            isEnabled.wrappedValue.toggle()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)

                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(
                isEnabled.wrappedValue
                    ? Color.blue.opacity(0.2)
                    : Color.gray.opacity(0.1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

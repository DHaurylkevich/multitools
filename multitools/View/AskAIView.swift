//
//  AskAIView.swift
//  multitools
//
//  Created by Mac on 26/10/2026.
//

import SwiftUI

struct AskAIView: View {
    let dispatcher: ActionDispatcher

    @State private var inputText = ""
    @State private var result = ""
    @State private var errorMessage: String?
    @State private var isProcessing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ask AI")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Ask a question or enter a concept to explain.")
                .foregroundStyle(.secondary)

            TextEditor(text: $inputText)
                .frame(minHeight: 140)
                .border(.secondary.opacity(0.3))

            Button {
                Task {
                    await explainText()
                }
            } label: {
                if isProcessing {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Explain", systemImage: "sparkles")
                }
            }
            .disabled(
                inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || isProcessing
            )

            if !result.isEmpty {
                Divider()

                Text("Answer")
                    .font(.headline)

                ScrollView {
                    Text(result)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @MainActor
    private func explainText() async {
        isProcessing = true
        errorMessage = nil
        result = ""

        defer {
            isProcessing = false
        }

        do {
            result = try await dispatcher.explain(inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
